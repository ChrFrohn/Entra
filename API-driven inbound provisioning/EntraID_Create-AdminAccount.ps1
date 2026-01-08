<#
.SYNOPSIS
    Creates an admin account in Entra ID using API-driven provisioning and SCIM bulk upload.

.DESCRIPTION
    This script uses Microsoft Graph SCIM API-driven provisioning to create a new admin account in 
    Entra ID based on an existing Entra ID user. The script:
    - Authenticates using Managed Identity
    - Retrieves the current user information from the Microsoft via REST API
    - Uses SCIM bulk upload to create a new admin account with "Admin" prefix
    - Creates the account in Entra ID with appropriate admin settings
    
    Designed for execution in Azure environments with Managed Identity configured.
    The admin account will be created with proper naming conventions in Entra ID.

.PARAMETER UserPrincipalNameOrObjectId
    The User Principal Name (UPN) or Entra ID Object ID of the user to create an admin account for.
    Example: "user@christianfrohn.dk" or "12345678-1234-1234-1234-123456789012"

.EXAMPLE
    .\EntraID_Create-AdminAccount.ps1 -UserPrincipalNameOrObjectId "user@christianfrohn.dk"
    Creates an admin account based on the specified user

.EXAMPLE
    .\EntraID_Create-AdminAccount.ps1 -UserPrincipalNameOrObjectId "12345678-1234-1234-1234-123456789012"
    Creates an admin account based on the user with the specified Object ID

.NOTES
    Author: Christian Frohn
    https://www.linkedin.com/in/frohn/
    Version: 1.0
    
    Prerequisites:
    - Managed Identity with appropriate permissions
    - API-driven inbound provisioning configured for Entra ID
    
    Required Microsoft Graph API Permissions (managed identity):
    - User.Read.All: Read user profile information from Microsoft Graph
    - SynchronizationData-User.Upload: Required for SCIM bulk upload operations

.LINK
    https://github.com/ChrFrohn/Entra-Lifecycle-Workflows
    https://www.christianfrohn.dk
#>

param (
    [Parameter(Mandatory = $true)] 
    [string]$UserPrincipalNameOrObjectId
)

# API-driven provisioning configuration
$InboundProvisioningAPIEndpoint = ""

# Get access token for Microsoft Graph using managed identity
try {
    $GraphTokenUri = $env:IDENTITY_ENDPOINT + "?resource=https://graph.microsoft.com/&api-version=2019-08-01"
    $ManagedIdentityHeaders = @{ 'X-IDENTITY-HEADER' = $env:IDENTITY_HEADER }
    
    $GraphTokenResponse = Invoke-RestMethod -Uri $GraphTokenUri -Method Get -Headers $ManagedIdentityHeaders -ErrorAction Stop
    $GraphAccessToken = $GraphTokenResponse.access_token
    $GraphApiHeaders = @{ 'Authorization' = "Bearer $GraphAccessToken" }
    
    Write-Output "SUCCESS: Authenticated to Microsoft Graph using managed identity"
}
catch {
    Write-Output "ERROR: Failed to authenticate to Microsoft Graph: $($_.Exception.Message)"
    Exit 1
}

# Determine if input is ObjectId (GUID) or UPN and construct URL
if ($UserPrincipalNameOrObjectId -match '^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$') {
    # Input is ObjectId
    $UserInfoApiUrl = "https://graph.microsoft.com/v1.0/users/${UserPrincipalNameOrObjectId}?`$select=userPrincipalName,surname,givenName,displayName,employeeId,id"
} else {
    # Input is UPN
    $UserInfoApiUrl = "https://graph.microsoft.com/v1.0/users/${UserPrincipalNameOrObjectId}?`$select=userPrincipalName,surname,givenName,displayName,employeeId,id"
}

try {
    $UserResponse = Invoke-RestMethod -Uri $UserInfoApiUrl -Headers $GraphApiHeaders -Method Get -ErrorAction Stop
    $UserPrincipalName = $UserResponse.userPrincipalName
    $UserObjectId = $UserResponse.id
    $employeeId = $UserResponse.employeeId # Raw Employee ID of the existing user
    
    Write-Output "SUCCESS: Retrieved user information for $($UserResponse.displayName) ($UserPrincipalName)"
}
catch {
    Write-Output "ERROR: Failed to retrieve user information for $UserPrincipalNameOrObjectId - $($_.Exception.Message)"
    Exit 1
}


# Prepare SCIM JSON values
$ExternalId = $UserPrincipalName.Split("@")[0].ToUpper()
$JSONexternalId = "Admin" + $ExternalId

$JSONNamegivenName = $UserResponse.givenName
$JSONNamefamilyName = $UserResponse.surname

$UserDisplayName = $UserResponse.displayName
$JSONNAMEdisplayName = $UserDisplayName + " - Admin account"

$employeeId = $UserResponse.employeeId
$JSONemployeeNumber = "AA" + $employeeId

# Generate unique bulk request IDs for SCIM operations
$ManagerBulkRequestId = [System.Guid]::NewGuid().ToString()
$AdminBulkRequestId = [System.Guid]::NewGuid().ToString()

# Create SCIM JSON payload for Entra ID admin user creation
# First operation: Register the manager with the provisioning engine so it can resolve the reference
# This is required when the manager is an on-prem synced user who was never processed by this API-driven app
# Second operation: Create the admin account with manager reference
        $json = @"
    {
        "schemas": ["urn:ietf:params:scim:api:messages:2.0:BulkRequest"],
        "Operations": [
        {
            "method": "POST",
            "bulkId": "$ManagerBulkRequestId",
            "path": "/Users",
            "data": {
                "schemas": ["urn:ietf:params:scim:schemas:core:2.0:User",
                "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User"],
                "externalId": "$employeeId",
                "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User": {
                    "employeeNumber": "$employeeId"
                },
                "active": true
            }
        },
        {
            "method": "POST",
            "bulkId": "$AdminBulkRequestId",
            "path": "/Users",
            "data": {
                "schemas": ["urn:ietf:params:scim:schemas:core:2.0:User",
                "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User"],
                "externalId": "$JSONemployeeNumber",
                "userName": "$JSONexternalId",
                "name": {
                    "familyName": "$JSONNamefamilyName",
                    "givenName": "$JSONNamegivenName"
                },
                "displayName": "$JSONNAMEdisplayName",
                "active": true,
                "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User": {
                    "employeeNumber": "$JSONemployeeNumber",
                    "manager": {
                        "value": "$employeeId",
                        "displayName": "$UserDisplayName"
                    }
                }
            }
        }
        ],
        "failOnErrors": null
    }
"@

$ScimJsonPayload = $json

# SCIM bulk upload operation
try {
    # Add Content-Type header for SCIM operation
    $ScimHeaders = $GraphApiHeaders.Clone()
    $ScimHeaders['Content-Type'] = 'application/scim+json'
    
    # Define the SCIM upload parameters using managed identity token
    $ScimUploadParameters = @{
        Uri         = $InboundProvisioningAPIEndpoint
        Method      = 'POST'
        Headers     = $ScimHeaders
        Body        = ([System.Text.Encoding]::UTF8.GetBytes($ScimJsonPayload))
        ErrorAction = 'Stop'
    }

    # Send the SCIM bulk upload request
    Invoke-RestMethod @ScimUploadParameters | Out-Null
    Write-Output "SUCCESS: SCIM bulk upload completed for user: $UserPrincipalName"
}
catch {
    Write-Output "ERROR: SCIM bulk upload failed for user $UserPrincipalName - $($_.Exception.Message)"
    
    # Provide additional error details if available
    if ($_.Exception.Response) {
        Write-Output "ERROR: HTTP Status Code: $($_.Exception.Response.StatusCode)"
        try {
            $errorResponse = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($errorResponse)
            $errorContent = $reader.ReadToEnd()
            Write-Output "ERROR: Response Content: $errorContent"
        } catch {
            Write-Output "ERROR: Unable to read error response content"
        }
    }
    
    Exit 1
}

Write-Output "SUCCESS: Admin account '$JSONexternalId' queued for creation in Entra ID based on user '$UserPrincipalName'"

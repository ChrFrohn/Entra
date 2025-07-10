# API-driven user provisioning infomation
$TenantId = ""
$ClientId = ""
$ClientSecret = ""
$ServicePrincipalId = ""
$ProvisioningApiEndpoint = "" 

# Sample user data - replace with your actual data source
$UserData = @{
    EmployeeId = "SAMPLE001" # Usally this would be a unique identifier like an employee ID or SamAAccountName
    LocationId = "LOC-A" # This can be anything, I used the users Location
}

# Define location mapping
$LocationMapping = @{
    "LOC-A" = "OU=Users,OU=Organization - LocationA,OU=Organization,DC=DOMAIN,DC=COM"
    "LOC-B" = "OU=Users,OU=Organization - LocationB,OU=Organization,DC=DOMAIN,DC=COM"
    "LOC-C" = "OU=Users,OU=Organization - LocationC,OU=Organization,DC=DOMAIN,DC=COM"
}

$ExternalId = $UserData.EmployeeId
$OrganizationalUnit = $LocationMapping[$UserData.LocationId]

$json = @"
{
	"schemas": ["urn:ietf:params:scim:api:messages:2.0:BulkRequest"],
    "Operations": [
    {
        "method": "POST",
        "bulkId": "701984",
        "path": "/Users",
        "data": {
            "schemas": ["urn:ietf:params:scim:schemas:core:2.0:User",
            "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User"],
            "externalId": "$ExternalId",
            "userName": "$ExternalId",
            "urn:ietf:params:scim:schemas:extension:CustomExtensionName:2.0:User": {
                "OU": "$OrganizationalUnit"
            }
        }
    }
],
    "failOnErrors": null
}

"@

$RequestBody = $json

# Authentication parameters
$AuthParams = @{
    Uri         = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"
    Method      = 'POST'
    Body        = @{
        client_id     = $ClientId
        scope         = 'https://graph.microsoft.com/.default'
        client_secret = $ClientSecret
        grant_type    = 'client_credentials'
    }
    ContentType = 'application/x-www-form-urlencoded'
}
$response = Invoke-RestMethod @AuthParams

$BulkUploadParams = @{
    Uri         = $ProvisioningApiEndpoint
    Method      = 'POST'
    Headers     = @{
        'Authorization' = "Bearer " + $response.access_token
        'Content-Type'  = 'application/scim+json'
    }
    Body        = ([System.Text.Encoding]::UTF8.GetBytes($RequestBody))
    Verbose     = $true
}

# Send the request
$response = Invoke-RestMethod @BulkUploadParams

# Display the response
$response

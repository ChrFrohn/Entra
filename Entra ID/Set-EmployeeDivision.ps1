<#
.SYNOPSIS
    Sets the Division property in employeeOrgData for an Entra ID user.

.DESCRIPTION
    Uses the Microsoft Graph API to update the employeeOrgData.division property
    of an Entra ID user. Authenticates via a service principal using the
    client credentials flow. Supports both UPN and Object ID as user identifier.

.PARAMETER UserPrincipalNameOrObjectId
    The User Principal Name (UPN) or Entra ID Object ID of the user.
    Example: "user@christianfrohn.dk" or "12345678-1234-1234-1234-123456789012"

.PARAMETER Division
    The Division value to set on the user's employeeOrgData.
    Example: "Finance" or "Engineering"

.EXAMPLE
    .\Set-EmployeeDivision.ps1 -UserPrincipalNameOrObjectId "user@christianfrohn.dk" -Division "Finance"
    Sets the employeeOrgData.division to "Finance" for the specified user.

.EXAMPLE
    .\Set-EmployeeDivision.ps1 -UserPrincipalNameOrObjectId "12345678-1234-1234-1234-123456789012" -Division "Engineering"
    Same operation using Object ID.

.NOTES
    Author: Christian Frohn
    https://www.linkedin.com/in/frohn/
    Version: 1.0

    Prerequisites:
    - Azure AD App Registration with a client secret

    Required Microsoft Graph API Permissions (Application):
    - User.ReadWrite.All: Required to update user properties in Entra ID

.LINK
    https://learn.microsoft.com/en-us/graph/api/user-update
    https://www.christianfrohn.dk
#>

param (
	[Parameter(Mandatory = $true)]
	[string]$UserPrincipalNameOrObjectId,

	[Parameter(Mandatory = $true)]
	[string]$Division
)

# Service Principal authentication details - replace with your own values
$ClientID = ""
$TenantID = ""
$ClientSecret = ""

try
{
	$TokenBody = @{
		Grant_Type    = "client_credentials"
		Scope         = "https://graph.microsoft.com/.default"
		Client_Id     = $ClientID
		Client_Secret = $ClientSecret
	}

	$Connection = Invoke-RestMethod `
		-Uri "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token" `
		-Method POST `
		-Body $TokenBody `
		-ContentType "application/x-www-form-urlencoded" `
		-ErrorAction Stop

	$Headers = @{
		"Authorization" = "Bearer $($Connection.access_token)"
		"Content-Type"  = "application/json"
	}

	if ($UserPrincipalNameOrObjectId -match '^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$')
	{
		$UserIdentifier = $UserPrincipalNameOrObjectId
	}
	else
	{
		$UserIdentifier = [System.Web.HttpUtility]::UrlEncode($UserPrincipalNameOrObjectId)
	}

	$GraphUrl = "https://graph.microsoft.com/v1.0/users/$UserIdentifier"
	$PatchBody = @{
		employeeOrgData = @{
			division = $Division
		}
	} | ConvertTo-Json

	Invoke-RestMethod -Uri $GraphUrl -Method PATCH -Headers $Headers -Body $PatchBody -ErrorAction Stop | Out-Null
	Write-Output ("SUCCESS: employeeOrgData.division set to '{0}' for {1}" -f $Division, $UserPrincipalNameOrObjectId)
}
catch
{
	Write-Output "ERROR: $($_.Exception.Message)"
	Exit 1
}

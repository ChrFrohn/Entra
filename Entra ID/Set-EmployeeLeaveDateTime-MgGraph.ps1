<#
.SYNOPSIS
    Sets the employeeLeaveDateTime attribute for a user in Entra ID.

.DESCRIPTION
    Connects to Microsoft Graph using the Microsoft Graph PowerShell SDK and updates the
    employeeLeaveDateTime property on the specified user via the beta Graph API.

.PARAMETER UserPrincipalNameOrObjectId
    The User Principal Name (UPN) or Entra ID Object ID of the user.
    Example: "user@christianfrohn.dk" or "12345678-1234-1234-1234-123456789012"

.PARAMETER EmployeeLeaveDateTime
    The leave date to set, in dd-MM-yyyy format.
    Example: "26-08-2026"

.PARAMETER TenantId
    Optional. The Entra ID Tenant ID to connect to. If omitted, the default tenant is used.
    Example: "12345678-1234-1234-1234-123456789012"

.EXAMPLE
    .\Set-EmployeeLeaveDateTime-MgGraph.ps1 -UserPrincipalNameOrObjectId "user@christianfrohn.dk" -EmployeeLeaveDateTime "26-08-2026"
    Sets the leave date/time using UPN

.EXAMPLE
    .\Set-EmployeeLeaveDateTime-MgGraph.ps1 -UserPrincipalNameOrObjectId "12345678-1234-1234-1234-123456789012" -EmployeeLeaveDateTime "26-08-2026"
    Sets the leave date/time using Object ID

.NOTES
    Author: Christian Frohn
    https://www.linkedin.com/in/frohn/
    Version: 1.0

    Prerequisites:
    - Microsoft Graph PowerShell SDK (Microsoft.Graph.Authentication module)

    Required Microsoft Graph API Permissions:
    - User.Read.All: Read user profiles
    - User-LifeCycleInfo.ReadWrite.All: Read and write user lifecycle information

.LINK
    https://github.com/ChrFrohn/Entra
    https://www.christianfrohn.dk
#>

param (
	[Parameter(Mandatory = $true)]
	[string]$UserPrincipalNameOrObjectId,

	[Parameter(Mandatory = $true)]
	[string]$EmployeeLeaveDateTime,

	[Parameter(Mandatory = $false)]
	[string]$TenantId
)

try
{
	if ($TenantId)
	{
		Connect-MgGraph -TenantId $TenantId -Scopes "User.Read.All", "User-LifeCycleInfo.ReadWrite.All" -NoWelcome -ErrorAction Stop
	}
	else
	{
		Connect-MgGraph -Scopes "User.Read.All", "User-LifeCycleInfo.ReadWrite.All" -NoWelcome -ErrorAction Stop
	}

	# Convert dd-MM-yyyy input to ISO 8601 for the Graph API
	$ParsedLeaveDate = [datetime]::ParseExact($EmployeeLeaveDateTime, "dd-MM-yyyy", [System.Globalization.CultureInfo]::InvariantCulture)
	$EmployeeLeaveDateTimeIso = $ParsedLeaveDate.ToString("yyyy-MM-ddTHH:mm:ssZ")

	if ($UserPrincipalNameOrObjectId -match '^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$')
	{
		$UserIdentifier = $UserPrincipalNameOrObjectId
	}
	else
	{
		$UserIdentifier = [System.Web.HttpUtility]::UrlEncode($UserPrincipalNameOrObjectId)
	}

	$GraphUrl = "https://graph.microsoft.com/beta/users/$UserIdentifier"
	$PatchBody = @{
		employeeLeaveDateTime = $EmployeeLeaveDateTimeIso
	} | ConvertTo-Json

	Invoke-MgGraphRequest -Uri $GraphUrl -Method PATCH -Body $PatchBody -ContentType "application/json" -ErrorAction Stop | Out-Null
	Write-Output ("SUCCESS: employeeLeaveDateTime set to {0} for {1}" -f $EmployeeLeaveDateTimeIso, $UserPrincipalNameOrObjectId)
}
catch
{
	Write-Output "ERROR: $($_.Exception.Message)"
	Exit 1
}

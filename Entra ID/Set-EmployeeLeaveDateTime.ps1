param (
	[Parameter(Mandatory = $true)]
	[string]$UserPrincipalNameOrObjectId,

	[Parameter(Mandatory = $true)]
	[string]$EmployeeLeaveDateTime
)

# Service Principal authentication details - replace with your own values
$ClientID = ""
$TenantID = ""
$ClientSecret = ""


try
{
	$TokenBody = @{
		Grant_Type = "client_credentials"
		Scope = "https://graph.microsoft.com/.default"
		Client_Id = $ClientID
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
		"Content-Type" = "application/json"
	}

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
		employeeLeaveDateTime = $EmployeeLeaveDateTime
	} | ConvertTo-Json

	Invoke-RestMethod -Uri $GraphUrl -Method PATCH -Headers $Headers -Body $PatchBody -ErrorAction Stop | Out-Null
	Write-Output ("SUCCESS: employeeLeaveDateTime set to {0} for {1}" -f $EmployeeLeaveDateTime, $UserPrincipalNameOrObjectId)
}
catch
{
	Write-Output "ERROR: $($_.Exception.Message)"
	Exit 1
}
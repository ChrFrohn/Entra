<#
.SYNOPSIS
	Report on service principals eligible for Workload Identities Premium licensing.

.DESCRIPTION
	Inventories all single-tenant service principals in the tenant that are eligible
	for Conditional Access policies under the Workload Identities Premium license.
	Exports the results to a CSV file for review before purchasing licenses.

	Workload Identities Premium CA policies can only be applied to:
	- Single-tenant service principals registered in YOUR tenant

	The following are excluded and do NOT need a license:
	- Managed identities (not supported by CA for workload identities)
	- Microsoft first-party apps (out of scope)
	- Third-party SaaS / multi-tenant apps (out of scope)

	Important licensing notes:
	- License assignment is NOT required per service principal. One license in
	  the tenant unlocks all premium features for all workload identities.
	- You only need licenses for the service principals you actually target
	  with CA policies. If you only protect a subset, you need fewer licenses.

.PARAMETER TenantId
	The Tenant ID of the Entra ID tenant to connect to.
	Example: "christianfrohn.onmicrosoft.com" or "12345678-1234-1234-1234-123456789012"

.PARAMETER OutputCsvPath
	The path for the exported CSV file.
	Default: ".\WorkloadIdentityLicenseReport.csv"

.EXAMPLE
	.\Get-WorkloadIdentityLicenseReport.ps1 -TenantId "christianfrohn.onmicrosoft.com"

.EXAMPLE
	.\Get-WorkloadIdentityLicenseReport.ps1 -TenantId "christianfrohn.onmicrosoft.com" -OutputCsvPath "C:\Reports\WI-Report.csv"

.NOTES
	Author: Christian Frohn
	https://www.linkedin.com/in/frohn/
	Version: 1.0

	Prerequisites:
	- Microsoft Graph PowerShell SDK

	Required Microsoft Graph API Permissions:
	- Application.Read.All

.LINK
	https://learn.microsoft.com/entra/identity/conditional-access/workload-identity
	https://learn.microsoft.com/entra/workload-id/workload-identities-faqs
#>

param(
	[Parameter(Mandatory = $true)]
	[string]$TenantId,

	[Parameter(Mandatory = $false)]
	[string]$OutputCsvPath = ".\WorkloadIdentityLicenseReport.csv"
)

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Application.Read.All" -TenantId $TenantId -NoWelcome

$ResolvedTenantId = (Get-MgContext).TenantId
Write-Host ("Connected to tenant: {0}" -f $ResolvedTenantId) -ForegroundColor Green

# Fetch all service principals with pagination
Write-Host "Fetching all service principals..." -ForegroundColor Yellow

$AllServicePrincipals = @()
$Uri = "https://graph.microsoft.com/v1.0/servicePrincipals?`$select=id,appId,displayName,servicePrincipalType,appOwnerOrganizationId,accountEnabled,signInAudience,tags,notes&`$top=999"

do
{
	$Response = Invoke-MgGraphRequest -Method GET -Uri $Uri
	$AllServicePrincipals += $Response.value
	$Uri = $Response.'@odata.nextLink'
} while ($Uri -ne $null)

Write-Host ("Total service principals in tenant: {0}" -f $AllServicePrincipals.Count) -ForegroundColor Cyan

# Filter: Single-tenant service principals owned by this tenant (eligible for WI Premium)
$MicrosoftTenantId = "f8cdef31-a31e-4b4a-93e4-5f571e91255a"

$SingleTenantSPs = $AllServicePrincipals | Where-Object {
	$_.servicePrincipalType -eq "Application" -and
	$_.appOwnerOrganizationId -eq $ResolvedTenantId
}

$ManagedIdentities = $AllServicePrincipals | Where-Object { $_.servicePrincipalType -eq "ManagedIdentity" }
$MultiTenantSPs = $AllServicePrincipals | Where-Object {
	$_.servicePrincipalType -eq "Application" -and
	$_.appOwnerOrganizationId -ne $ResolvedTenantId -and
	$_.appOwnerOrganizationId -ne $null
}
$MicrosoftFirstParty = $AllServicePrincipals | Where-Object { $_.appOwnerOrganizationId -eq $MicrosoftTenantId }

# Build report
Write-Host "Building report..." -ForegroundColor Yellow

$Results = @()
Foreach ($SP in $SingleTenantSPs)
{
	$Results += [PSCustomObject]@{
		DisplayName    = $SP.displayName
		AppId          = $SP.appId
		ObjectId       = $SP.id
		Enabled        = $SP.accountEnabled
		SignInAudience = $SP.signInAudience
		Tags           = ($SP.tags -join "; ")
		Notes          = $SP.notes
	}
}

# Export to CSV
$Results | Sort-Object DisplayName | Export-Csv -Path $OutputCsvPath -NoTypeInformation -Encoding UTF8
Write-Host ("Report exported to: {0}" -f $OutputCsvPath) -ForegroundColor Green

# Summary
$EnabledCount = ($SingleTenantSPs | Where-Object { $_.accountEnabled -eq $true }).Count
$DisabledCount = ($SingleTenantSPs | Where-Object { $_.accountEnabled -eq $false }).Count

Write-Host ""
Write-Host "=== Workload Identities Premium License Summary ===" -ForegroundColor Cyan
Write-Host ("  Total service principals:                 {0}" -f $AllServicePrincipals.Count) -ForegroundColor White
Write-Host ("  Managed identities (excluded):            {0}" -f $ManagedIdentities.Count) -ForegroundColor DarkGray
Write-Host ("  Microsoft first-party apps (excluded):    {0}" -f $MicrosoftFirstParty.Count) -ForegroundColor DarkGray
Write-Host ("  Multi-tenant / external apps (excluded):  {0}" -f $MultiTenantSPs.Count) -ForegroundColor DarkGray
Write-Host ""
Write-Host ("  Eligible single-tenant service principals: {0}" -f $SingleTenantSPs.Count) -ForegroundColor Green
Write-Host ("    Enabled:  {0}" -f $EnabledCount) -ForegroundColor Green
Write-Host ("    Disabled: {0}" -f $DisabledCount) -ForegroundColor DarkGray
Write-Host ""
Write-Host ("  Minimum licenses needed for full coverage: {0}" -f $EnabledCount) -ForegroundColor Yellow
Write-Host ""

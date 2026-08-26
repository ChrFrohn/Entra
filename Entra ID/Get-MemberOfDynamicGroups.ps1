<#
.SYNOPSIS
	Report on dynamic membership groups that use the memberOf operator in their membership rule.

.DESCRIPTION
	Lists all dynamic membership groups in a Microsoft Entra tenant whose membership rule
	contains the memberOf operator, and exports the result to a CSV file.

	The public preview of the memberOf rule operator is ending. After November 3, 2026,
	dynamic membership groups, dynamic administrative units, and entitlement management
	auto-assignment policies that use the memberOf operator stop updating and remain in
	their last known state. That can lead to stale access and enforcement gaps, including
	outdated Teams and SharePoint access, Conditional Access targeting, group-based
	licensing, and access package assignments.

	Use this script to build the inventory needed before replacing the memberOf rules with
	supported rule operators or converting the groups to assigned membership.

	For each group the script reports:
	- Display name, object ID and group type
	- The full membership rule and the rule processing state (On / Paused)
	- The source groups referenced by the memberOf rule, resolved to display names

.PARAMETER TenantId
	The Tenant ID of the Entra ID tenant to connect to.
	Example: "christianfrohn.onmicrosoft.com" or "12345678-1234-1234-1234-123456789012"

.PARAMETER OutputCsvPath
	The path for the exported CSV file.
	Default: ".\MemberOfDynamicGroups.csv"

.EXAMPLE
	.\Get-MemberOfDynamicGroups.ps1 -TenantId "christianfrohn.onmicrosoft.com"

.EXAMPLE
	.\Get-MemberOfDynamicGroups.ps1 -TenantId "12345678-1234-1234-1234-123456789012" -OutputCsvPath "C:\Reports\MemberOf-Groups.csv"

.NOTES
	Author: Christian Frohn
	https://www.linkedin.com/in/frohn/
	Version: 1.0

	Prerequisites:
	- Microsoft Graph PowerShell SDK (Microsoft.Graph.Groups)
	- Microsoft Entra ID P1 or P2 license in the tenant

	Required Microsoft Graph API Permissions:
	- Group.Read.All

	The script is read-only and does not change any group or membership rule.

.LINK
	https://learn.microsoft.com/entra/identity/users/groups-dynamic-rule-member-of
	https://learn.microsoft.com/entra/identity/users/groups-dynamic-rule-more-efficient
	https://learn.microsoft.com/graph/api/group-list
#>

param(
	[Parameter(Mandatory = $true)]
	[string]$TenantId,

	[Parameter(Mandatory = $false)]
	[string]$OutputCsvPath = ".\MemberOfDynamicGroups.csv"
)

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Group.Read.All" -TenantId $TenantId -NoWelcome

$ResolvedTenantId = (Get-MgContext).TenantId
Write-Host ("Connected to tenant: {0}" -f $ResolvedTenantId) -ForegroundColor Green

# Fetch all dynamic membership groups
Write-Host "Fetching dynamic membership groups..." -ForegroundColor Yellow

$DynamicGroupParameters = @{
	All              = $true
	Filter           = "groupTypes/any(c:c eq 'DynamicMembership')"
	Property         = "id,displayName,description,groupTypes,membershipRule,membershipRuleProcessingState,securityEnabled,mailEnabled,createdDateTime,onPremisesSyncEnabled"
	ConsistencyLevel = "eventual"
	CountVariable    = "DynamicGroupCount"
}

$DynamicGroups = Get-MgGroup @DynamicGroupParameters

Write-Host ("Dynamic membership groups found: {0}" -f $DynamicGroups.Count) -ForegroundColor Cyan

# Keep only groups where the membership rule uses the memberOf operator
$MemberOfGroups = $DynamicGroups | Where-Object { $_.MembershipRule -match "memberof" }

# Build report
$GuidPattern = "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"
$SourceGroupCache = @{} # Cache of resolved source group names to avoid repeated Graph calls

$Results = @()
Foreach ($Group in $MemberOfGroups)
{
	$SourceGroupIds = [regex]::Matches($Group.MembershipRule, $GuidPattern) | ForEach-Object { $_.Value } | Sort-Object -Unique

	$SourceGroupNames = @()
	Foreach ($SourceGroupId in $SourceGroupIds)
	{
		if (-not $SourceGroupCache.ContainsKey($SourceGroupId))
		{
			try
			{
				$SourceGroup = Get-MgGroup -GroupId $SourceGroupId -Property "id,displayName" -ErrorAction Stop
				$SourceGroupCache[$SourceGroupId] = $SourceGroup.DisplayName
			}
			catch
			{
				$SourceGroupCache[$SourceGroupId] = "<Not found - group deleted?>"
			}
		}

		$SourceGroupNames += $SourceGroupCache[$SourceGroupId]
	}

	if ($Group.MembershipRule -match "device\.memberof")
	{
		$MembershipType = "Dynamic Device"
	}
	else
	{
		$MembershipType = "Dynamic User"
	}

	if ($Group.GroupTypes -contains "Unified")
	{
		$GroupType = "Microsoft 365"
	}
	else
	{
		$GroupType = "Security"
	}

	$Results += [PSCustomObject]@{
		DisplayName            = $Group.DisplayName
		ObjectId               = $Group.Id
		GroupType              = $GroupType
		MembershipType         = $MembershipType
		MembershipRule         = $Group.MembershipRule
		ProcessingState        = $Group.MembershipRuleProcessingState
		SourceGroupCount       = $SourceGroupIds.Count
		SourceGroupNames       = ($SourceGroupNames -join "; ")
		SourceGroupIds         = ($SourceGroupIds -join "; ")
		Description            = $Group.Description
		CreatedDateTime        = $Group.CreatedDateTime
		OnPremisesSyncEnabled  = $Group.OnPremisesSyncEnabled
	}

	Write-Host ("Found memberOf group: {0}" -f $Group.DisplayName) -ForegroundColor Red
}

# Export to CSV
if ($Results.Count -gt 0)
{
	$Results | Sort-Object DisplayName | Export-Csv -Path $OutputCsvPath -NoTypeInformation -Encoding UTF8
	Write-Host ("Report exported to: {0}" -f $OutputCsvPath) -ForegroundColor Green
}

# Summary
Write-Host ""
Write-Host "=== memberOf dynamic membership group summary ===" -ForegroundColor Cyan
Write-Host ("  Dynamic membership groups in tenant:   {0}" -f $DynamicGroups.Count) -ForegroundColor White
Write-Host ("  Groups using the memberOf operator:    {0}" -f $Results.Count) -ForegroundColor Yellow
Write-Host ("  Rule processing paused:                {0}" -f ($Results | Where-Object { $_.ProcessingState -eq "Paused" }).Count) -ForegroundColor DarkGray
Write-Host ""

if ($Results.Count -gt 0)
{
	Write-Host "Groups and rules:" -ForegroundColor Cyan
	Foreach ($Result in ($Results | Sort-Object DisplayName))
	{
		Write-Host ("  {0}" -f $Result.DisplayName) -ForegroundColor White
		Write-Host ("    Rule: {0}" -f $Result.MembershipRule) -ForegroundColor DarkGray
		Write-Host ("    Source groups: {0}" -f $Result.SourceGroupNames) -ForegroundColor DarkGray
	}

}
else
{
	Write-Host "No dynamic membership groups use the memberOf operator in this tenant." -ForegroundColor Green
}

Write-Host ""

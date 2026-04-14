<#
.SYNOPSIS
	Exports access package assignment requests including business justification and question answers.

.DESCRIPTION
	Retrieves all assignment requests for a specific access package using Microsoft Graph API.
	Includes fields not available in the portal Download export: business justification and
	answers to access package questions. Exports the results to a CSV file.

.PARAMETER AccessPackageId
	The ID (GUID) of the access package to export requests for.
	Example: "a914b616-e04e-476b-aa37-91038f0b165b"

.PARAMETER TenantId
	The Tenant ID (GUID) of the Entra ID tenant to connect to.
	Example: "christianfrohn.onmicrosoft.com" or "12345678-1234-1234-1234-123456789012"

.PARAMETER OutputCsvPath
	The path for the exported CSV file.
	Default: ".\AccessPackageRequests-Extended.csv"

.EXAMPLE
	.\Export-AccessPackageRequestsExtended.ps1 -AccessPackageId "a914b616-e04e-476b-aa37-91038f0b165b" -TenantId "christianfrohn.onmicrosoft.com"
	Exports all requests for the specified access package to the default CSV path.

.EXAMPLE
	.\Export-AccessPackageRequestsExtended.ps1 -AccessPackageId "a914b616-e04e-476b-aa37-91038f0b165b" -TenantId "christianfrohn.onmicrosoft.com" -OutputCsvPath "C:\Exports\Requests.csv"
	Exports all requests to a custom file path.

.NOTES
	Author: Christian Frohn
	https://www.linkedin.com/in/frohn/
	Version: 1.0

	Prerequisites:
	- Microsoft Graph PowerShell SDK (Microsoft.Graph.Identity.Governance module)

	Required Microsoft Graph API Permissions:
	- EntitlementManagement.Read.All: Read access package assignment requests

.LINK
	https://learn.microsoft.com/graph/api/entitlementmanagement-list-assignmentrequests
#>

param(
	[Parameter(Mandatory = $true)]
	[string]$AccessPackageId,

	[Parameter(Mandatory = $true)]
	[string]$TenantId,

	[Parameter(Mandatory = $false)]
	[string]$OutputCsvPath = ".\AccessPackageRequests-Extended.csv"
)

# Convert answer objects to readable text
function Convert-AnswersToText
{
	param(
		[Parameter(Mandatory = $false)]
		[object[]]$Answers
	)

	if (-not $Answers)
	{
		return ""
	}

	$Parts = @()

	Foreach ($Answer in $Answers)
	{
		$QuestionText = ""
		if ($Answer.answeredQuestion -and $Answer.answeredQuestion.text)
		{
			$QuestionText = $Answer.answeredQuestion.text
		}
		elseif ($Answer.answeredQuestion -and $Answer.answeredQuestion.id)
		{
			$QuestionText = ("QuestionId:{0}" -f $Answer.answeredQuestion.id)
		}
		else
		{
			$QuestionText = "Question"
		}

		$AnswerText = ""
		if ($Answer.displayValue)
		{
			$AnswerText = $Answer.displayValue
		}
		elseif ($Answer.value)
		{
			$AnswerText = $Answer.value
		}

		$Parts += ("{0}: {1}" -f $QuestionText, $AnswerText)
	}

	return ($Parts -join " | ")
}

# Connect to Microsoft Graph
try
{
	Connect-MgGraph -Scopes "EntitlementManagement.Read.All" -TenantId $TenantId -ErrorAction Stop
}
catch
{
	Write-Host ("ERROR: Failed to connect to Microsoft Graph: {0}" -f $_.Exception.Message) -ForegroundColor Red
	Exit 1
}

# Build request URL for a specific access package
$EscapedFilter = [System.Uri]::EscapeDataString("accessPackage/id eq '$AccessPackageId'")
$Uri = "https://graph.microsoft.com/v1.0/identityGovernance/entitlementManagement/assignmentRequests?`$filter=$EscapedFilter&`$expand=accessPackage,requestor,assignment(`$expand=assignmentPolicy)"

# Read all pages
$AllRequests = @()

try
{
	do
	{
		$Response = Invoke-MgGraphRequest -Method GET -Uri $Uri -ErrorAction Stop
		if ($Response.value)
		{
			Foreach ($Item in $Response.value)
			{
				$AllRequests += $Item
			}
		}

		$Uri = $Response.'@odata.nextLink'
	}
	while ($Uri)
}
catch
{
	Write-Host ("ERROR: Failed to retrieve assignment requests: {0}" -f $_.Exception.Message) -ForegroundColor Red
	Exit 1
}

Write-Host ("Retrieved {0} assignment requests" -f $AllRequests.Count) -ForegroundColor Cyan

# Transform to export rows
$Rows = @()

Foreach ($Request in $AllRequests)
{
	$PolicyDisplayName = ""
	if ($Request.assignment -and $Request.assignment.assignmentPolicy)
	{
		$PolicyDisplayName = $Request.assignment.assignmentPolicy.displayName
	}

	$ScheduleStartDateTime = $null
	$ScheduleEndDateTime = $null
	if ($Request.schedule)
	{
		$ScheduleStartDateTime = $Request.schedule.startDateTime

		if ($Request.schedule.expiration -and $Request.schedule.expiration.endDateTime)
		{
			$ScheduleEndDateTime = $Request.schedule.expiration.endDateTime
		}
		elseif ($Request.schedule.endDateTime)
		{
			$ScheduleEndDateTime = $Request.schedule.endDateTime
		}
	}

	$AnswersReadable = Convert-AnswersToText -Answers $Request.answers
	$AnswersJson = ""
	if ($Request.answers)
	{
		$AnswersJson = $Request.answers | ConvertTo-Json -Depth 10 -Compress
	}

	$Rows += [pscustomobject]@{
		RequestorDisplayName = $Request.requestor.displayName
		RequestorPrincipalName = $Request.requestor.email
		AccessPackagePolicyDisplayName = $PolicyDisplayName
		ScheduleStartDateTime = $ScheduleStartDateTime
		ScheduleEndDateTime = $ScheduleEndDateTime
		RequestType = $Request.requestType
		CreatedDateTime = $Request.createdDateTime
		RequestStatus = $Request.status
		BusinessJustification = $Request.justification
		AnswersReadable = $AnswersReadable
		AnswersJson = $AnswersJson
	}
}

# Export CSV
$Rows | Export-Csv -Path $OutputCsvPath -NoTypeInformation -Encoding UTF8

Write-Host ("Export completed: {0}" -f $OutputCsvPath) -ForegroundColor Green
Write-Host ("Rows exported: {0}" -f $Rows.Count) -ForegroundColor Cyan

# Disconnect session
Disconnect-MgGraph | Out-Null

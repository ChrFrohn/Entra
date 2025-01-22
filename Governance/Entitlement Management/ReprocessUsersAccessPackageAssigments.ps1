param (
    [Parameter(Mandatory = $true)] 
    [string]$ObjectId
)

# Service Principal infomation - Requries EntitlementManagement.ReadWrite.All (Application) permission
$ClientID = ""
$ClientSecret = ""
$TenantID = ""

# Microft Graph Auth. 
$Body = @{
    grant_type    = "client_credentials"
    client_id     = $ClientID
    client_secret = $ClientSecret
    scope         = "https://graph.microsoft.com/.default"
}

$Response = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token" -ContentType "application/x-www-form-urlencoded" -Body $Body
$AccessToken = $Response.access_token

$Headers = @{
    "Authorization" = "Bearer $AccessToken"
    "Content-Type"  = "application/json"
}

# Initialize an empty array to store all access package assignments
$allAssignments = @()
$AssignmentsUri = "https://graph.microsoft.com/beta/identityGovernance/entitlementManagement/accessPackageAssignments"

do {
    $Response = Invoke-RestMethod -Method Get -Uri $AssignmentsUri -Headers $Headers
    $allAssignments += $Response.value
    $AssignmentsUri = $Response.'@odata.nextLink'
} while ($AssignmentsUri -ne $null)

# Filter access package assignments
$FilteredAssignments = $AllAssignments | Where-Object { 
    $_.targetId -eq $($ObjectId) -and 
    $_.assignmentState -eq 'Delivered'
}

# Reprocess the access package assignments
foreach ($Assignment in $FilteredAssignments) 
{
    $AccessPackageAssignmentId = $Assignment.id
    $ReProcessUserURL = "https://graph.microsoft.com/v1.0/identityGovernance/entitlementManagement/assignments/$AccessPackageAssignmentId/reprocess"
    Invoke-RestMethod -Method POST -Uri $ReProcessUserURL -Headers $headers
}

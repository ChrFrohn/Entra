param (
    [Parameter(Mandatory = $true)] 
    [string]$ObjectId
)

# Service Principal
$ClientID = ""
$ClientSecret = ""
$TenantID = ""

$body = @{
    grant_type    = "client_credentials"
    client_id     = $ClientID
    client_secret = $ClientSecret
    scope         = "https://graph.microsoft.com/.default"
}

$response = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token" -ContentType "application/x-www-form-urlencoded" -Body $body
$accessToken = $response.access_token

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type"  = "application/json"
}

# Get user attributes
$url = "https://graph.microsoft.com/v1.0/users/${ObjectId}"
$userAttributes = Invoke-RestMethod -Uri $url -Headers $headers -Method Get -ErrorAction Stop 

# Initialize an empty array to store all assignments
$allAssignments = @()
$assignmentsUri = "https://graph.microsoft.com/beta/identityGovernance/entitlementManagement/accessPackageAssignments"

do {
    $response = Invoke-RestMethod -Method Get -Uri $assignmentsUri -Headers $headers
    $allAssignments += $response.value
    $assignmentsUri = $response.'@odata.nextLink'
} while ($assignmentsUri -ne $null)

# Filter assignments
$Catalogs = @($EMCatalogLocation, $EMCatalogEmployeeType, $EMCatalogDepartment, $EMCatalogSpecialer, $EMCatalogRoles)
$filteredAssignments = $allAssignments | Where-Object { 
    $_.targetId -eq $($userAttributes.id) -and 
    $_.assignmentState -eq 'Delivered'
}

$filteredAssignments

foreach ($Assignment in $filteredAssignments) {
    $accessPackageAssignmentId = $Assignment.id
    $ReProcessUserURL = "https://graph.microsoft.com/v1.0/identityGovernance/entitlementManagement/assignments/$accessPackageAssignmentId/reprocess"
    Invoke-RestMethod -Method POST -Uri $ReProcessUserURL -Headers $headers
}

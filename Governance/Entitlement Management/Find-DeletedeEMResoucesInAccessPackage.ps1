# Quick Group Type Checker for Access Package Groups
# Gets all groups from a specific access package and checks their types

# Set the Access Package ID here
$accessPackageId = "04d2a56c-cdf3-4c48-afea-d3cf3d49d497"

Write-Host "Getting groups from access package..." -ForegroundColor Yellow

# Get the access package with catalog and resource role scopes expanded
$accessPackage = Get-MgEntitlementManagementAccessPackage -AccessPackageId $accessPackageId -ExpandProperty "catalog,resourceRoleScopes(`$expand=role,scope)" -ErrorAction Stop

# Get the catalog ID
$catalogId = $accessPackage.Catalog.Id

# Get all catalog resources for lookup
$catalogResources = Get-MgEntitlementManagementCatalogResource -AccessPackageCatalogId $catalogId -All -ErrorAction Stop

# Extract group information from the resource role scopes
$groupData = $accessPackage.ResourceRoleScopes | 
    Where-Object { $_.Scope.OriginSystem -eq "AadGroup" } |
    ForEach-Object {
        $originId = $_.Scope.OriginId
        $catalogResource = $catalogResources | Where-Object { $_.OriginId -eq $originId }
        [PSCustomObject]@{
            OriginId = $originId
            DisplayName = $catalogResource.DisplayName
        }
    } | Select-Object -Unique OriginId, DisplayName

if ($groupData.Count -eq 0) {
    Write-Host "No groups found in this access package." -ForegroundColor Yellow
    exit
}

$results = foreach ($item in $groupData) {
    try {
        $group = Get-MgGroup -GroupId $item.OriginId -ErrorAction Stop
        
        $type = if ($group.GroupTypes -contains "Unified") { "Microsoft 365" }
                elseif (!$group.MailEnabled -and $group.SecurityEnabled) { "Security" }
                elseif ($group.MailEnabled -and $group.SecurityEnabled) { "Mail-enabled Security" }
                elseif ($group.MailEnabled -and !$group.SecurityEnabled) { "Distribution" }
                else { "Unknown" }
        
        [PSCustomObject]@{
            SearchedName = $item.DisplayName
            Type = $type
            MailEnabled = $group.MailEnabled
            SecurityEnabled = $group.SecurityEnabled
            Status = "✅ Found"
        }
    } catch {
        [PSCustomObject]@{
            SearchedName = $item.DisplayName
            Type = ""
            MailEnabled = ""
            SecurityEnabled = ""
            Status = "❌ Missing"
        }
    }
}

Write-Host "`nResults:" -ForegroundColor Cyan
$results | Format-Table SearchedName, Type, MailEnabled, SecurityEnabled, Status -AutoSize
# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Group.Read.All", "EntitlementManagement.Read.All"

# Search for the group in Entra ID
$targetGroup = "" # Name of the group to search for
$group = Get-MgGroup -Filter "displayName eq '$targetGroup'"

# ObjectId of the group
$targetGroupId = $group.Id

# Get all access packages
$accessPackages = Get-MgEntitlementManagementAccessPackage -All

Write-Host "Searching for access packages containing group '$targetGroup'..."

foreach ($package in $accessPackages) 
{
    $packageDetails = Get-MgEntitlementManagementAccessPackage -AccessPackageId $package.Id -ExpandProperty "resourceRoleScopes(`$expand=role,scope)"
       
    foreach ($scope in $packageDetails.ResourceRoleScopes.Scope) 
    {
        if ($scope.OriginId -eq $targetGroupId) 
        {
            Write-Host "Found: Group '$targetGroup' is in Access Package: $($package.DisplayName)" -ForegroundColor Green
        }
    }
}

Write-Host "Search complete."
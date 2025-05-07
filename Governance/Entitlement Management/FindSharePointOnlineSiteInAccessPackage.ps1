# Connect to Microsoft Graph with the required permissions
Connect-MgGraph -Scopes "EntitlementManagement.Read.All"

# Specify the SharePoint site URL you want to search for
$targetSiteUrl = "" # Sample: "https://kromannreumert.sharepoint.com/sites/YourSiteName"

# Retrieve all access packages
$accessPackages = Get-MgEntitlementManagementAccessPackage -all

Write-Host "Searching for access packages containing SharePoint site '$targetSiteUrl'..."

# Loop through each access package and check if it contains the specified SharePoint site
foreach ($package in $accessPackages) 
{
    $packageDetails = Get-MgEntitlementManagementAccessPackage -AccessPackageId $package.Id -ExpandProperty "resourceRoleScopes(`$expand=role,scope)"
    
    foreach ($scope in $packageDetails.ResourceRoleScopes.Scope) 
    {
        if ($scope.OriginId -eq $targetSiteUrl -and $scope.OriginSystem -eq "SharePointOnline") 
        {
            Write-Host "Found: SharePoint site '$targetSiteUrl' is in Access Package: $($package.DisplayName)" -ForegroundColor Green
        }
    }
}

Write-Host "Search complete."
# Connect to Microsoft Graph with the required permissions
Connect-MgGraph -Scopes "EntitlementManagement.Read.All"

# Specify the Application (Object ID) you want to search for
$targetApplicationId = "" # Sample: "db4859bf-43c3-49fa-ab13-8036bd333ebe" Application ID NOT Object ID

# Retrieve all access packages
$accessPackages = Get-MgEntitlementManagementAccessPackage -All

Write-Host "Searching for access packages containing Application ID '$targetApplicationId'..."

# Loop through each access package and check if it contains the specified Application
foreach ($package in $accessPackages) 
{
    $packageDetails = Get-MgEntitlementManagementAccessPackage -AccessPackageId $package.Id -ExpandProperty "resourceRoleScopes(`$expand=role,scope)"
    
    foreach ($scope in $packageDetails.ResourceRoleScopes.Scope) 
    {
        if ($scope.OriginId -eq $targetApplicationId -and $scope.OriginSystem -eq "AadApplication") 
        {
            Write-Host "Found: Application ID '$targetApplicationId' is in Access Package: $($package.DisplayName)" -ForegroundColor Green
        }
    }
}

Write-Host "Search complete."
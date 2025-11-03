# Remove orphaned resources from Access Packages and Catalogs
# Removes resources where the underlying Entra ID objects have been deleted

Connect-MgGraph -Scopes "Group.Read.All", "Application.Read.All", "EntitlementManagement.ReadWrite.All"

# Get all Access Packages with resources
$AccessPackages = Get-MgEntitlementManagementAccessPackage -All -ExpandProperty "accessPackageResourceRoleScopes(`$expand=accessPackageResourceRole,accessPackageResourceScope)"

$OrphanedInAccessPackages = @()

foreach ($package in $AccessPackages) 
{
    if ($package.AccessPackageResourceRoleScopes) 
    {
        foreach ($roleScope in $package.AccessPackageResourceRoleScopes) 
        {
            $resource = $roleScope.AccessPackageResourceScope.AccessPackageResource
            $OriginSystem = $resource.OriginSystem
            $OriginId = $resource.OriginId
            $ResourceName = $resource.DisplayName
            
            $IsOrphaned = $false
            
            # Check if resource still exists
            if ($OriginSystem -eq "AadGroup") 
            {
                try { 
                    $null = Get-MgGroup -GroupId $OriginId -ErrorAction Stop 
                } 
                catch { 
                    $IsOrphaned = $true 
                }
            }
            elseif ($OriginSystem -eq "AadApplication") 
            {
                try { 
                    $null = Get-MgServicePrincipal -ServicePrincipalId $OriginId -ErrorAction Stop 
                } 
                catch { 
                    $IsOrphaned = $true 
                }
            }
            
            if ($IsOrphaned) 
            {
                $OrphanedInAccessPackages += [PSCustomObject]@{
                    AccessPackageId     = $package.Id
                    AccessPackageName   = $package.DisplayName
                    ResourceRoleScopeId = $roleScope.Id
                    ResourceName        = $ResourceName
                    OriginSystem        = $OriginSystem
                    OriginId            = $OriginId
                }
            }
        }
    }
}

Write-Host "Found $($OrphanedInAccessPackages.Count) orphaned resources in Access Packages" -ForegroundColor Yellow

# Remove orphaned resources from Access Packages
foreach ($orphan in $OrphanedInAccessPackages) 
{
    Write-Host "Removing: $($orphan.ResourceName) from $($orphan.AccessPackageName)" -ForegroundColor Cyan
    
    $Uri = "https://graph.microsoft.com/v1.0/identityGovernance/entitlementManagement/accessPackages/$($orphan.AccessPackageId)/accessPackageResourceRoleScopes/$($orphan.ResourceRoleScopeId)"
    Invoke-MgGraphRequest -Method DELETE -Uri $Uri
    
    Start-Sleep -Milliseconds 500
}

# Get all Catalogs and their resources
$Catalogs = Get-MgEntitlementManagementCatalog -All

$OrphanedInCatalogs = @()

foreach ($catalog in $Catalogs) 
{
    $catalogResources = Get-MgEntitlementManagementCatalogResource -AccessPackageCatalogId $catalog.Id -All
    
    foreach ($resource in $catalogResources) 
    {
        $OriginSystem = $resource.OriginSystem
        $OriginId = $resource.OriginId
        $ResourceName = $resource.DisplayName
        
        $IsOrphaned = $false
        
        # Check if resource still exists
        if ($OriginSystem -eq "AadGroup") 
        {
            try { 
                $null = Get-MgGroup -GroupId $OriginId -ErrorAction Stop 
            } 
            catch { 
                $IsOrphaned = $true 
            }
        }
        elseif ($OriginSystem -eq "AadApplication") 
        {
            try { 
                $null = Get-MgServicePrincipal -ServicePrincipalId $OriginId -ErrorAction Stop 
            } 
            catch { 
                $IsOrphaned = $true 
            }
        }
        
        if ($IsOrphaned) 
        {
            $OrphanedInCatalogs += [PSCustomObject]@{
                CatalogId    = $catalog.Id
                CatalogName  = $catalog.DisplayName
                ResourceId   = $resource.Id
                ResourceName = $ResourceName
                OriginSystem = $OriginSystem
                OriginId     = $OriginId
            }
        }
    }
}

Write-Host "Found $($OrphanedInCatalogs.Count) orphaned resources in Catalogs" -ForegroundColor Yellow

# Remove orphaned resources from Catalogs
foreach ($orphan in $OrphanedInCatalogs) 
{
    Write-Host "Removing: $($orphan.ResourceName) from $($orphan.CatalogName)" -ForegroundColor Cyan
    
    $Uri = "https://graph.microsoft.com/v1.0/identityGovernance/entitlementManagement/catalogs/$($orphan.CatalogId)/resources/$($orphan.ResourceId)"
    Invoke-MgGraphRequest -Method DELETE -Uri $Uri
    
    Start-Sleep -Milliseconds 500
}

Write-Host "`nCleanup complete." -ForegroundColor Green
Write-Host "Removed from Access Packages: $($OrphanedInAccessPackages.Count)"
Write-Host "Removed from Catalogs: $($OrphanedInCatalogs.Count)"

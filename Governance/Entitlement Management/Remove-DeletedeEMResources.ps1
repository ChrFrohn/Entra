
Connect-MgGraph -Scopes "Group.Read.All", "Application.Read.All", "EntitlementManagement.ReadWrite.All", "Sites.Read.All" -NoWelcome

# Get all catalogs
$Catalogs = Get-MgEntitlementManagementCatalog -All

$AllOrphanedResources = @()

Write-Host "Checking catalogs for orphaned resources..." -ForegroundColor Yellow

foreach ($catalog in $Catalogs) 
{
    $catalogResources = Get-MgEntitlementManagementCatalogResource -AccessPackageCatalogId $catalog.Id -All
    
  Foreach ($resource in $catalogResources) 
    {
        $OriginSystem = $resource.OriginSystem
        $OriginId = $resource.OriginId
        $DisplayName = $resource.DisplayName
        $IsOrphaned = $false
        $ResourceType = ""
        
        # Check if Group still exists
        if ($OriginSystem -eq "AadGroup") 
        {
            $ResourceType = "Group"
            try 
            {
                $null = Get-MgGroup -GroupId $OriginId -ErrorAction Stop
            }
            catch 
            {
                $IsOrphaned = $true
            }
        }
        # Check if Application still exists
        elseif ($OriginSystem -eq "AadApplication") 
        {
            $ResourceType = "Application"
            try 
            {
                $null = Get-MgServicePrincipal -ServicePrincipalId $OriginId -ErrorAction Stop
            }
            catch 
            {
                $IsOrphaned = $true
            }
        }
        elseif ($OriginSystem -eq "SharePointOnline") 
        {
            $ResourceType = "SharePoint Online Site"
            # Check if SharePoint site still exists
            try 
            {
                $null = Get-MgSite -SiteId $OriginId -ErrorAction Stop
            }
            catch 
            {
                $IsOrphaned = $true
            }
        }
        
        if ($IsOrphaned) 
        {
            $AllOrphanedResources += [PSCustomObject]@{
                Catalog      = $catalog.DisplayName
                CatalogId    = $catalog.Id
              ResourceType = $ResourceType
              ResourceName = $DisplayName
                OriginId     = $OriginId
                OriginSystem = $OriginSystem
              ResourceId   = $resource.Id
            }
            
            Write-Host "Found orphaned resource: $DisplayName ($ResourceType) in $($catalog.DisplayName)" -ForegroundColor Red
        }
    }
}

if ($AllOrphanedResources.Count -gt 0) 
{
    Write-Host "`nTotal orphaned resources found: $($AllOrphanedResources.Count)" -ForegroundColor Yellow
    
    # Ask for confirmation before proceeding
    Write-Host "`n" -NoNewline
    $confirmation = Read-Host "Do you want to remove these orphaned resources? (yes/no)"
    
    if ($confirmation -in @("yes", "y", "Y", "Yes", "YES")) 
    {
        # Step 1: Remove orphaned resources from access packages
        
      Foreach ($orphanedResource in $AllOrphanedResources) 
        {
            # Get all access packages in this catalog
            try 
            {
                $accessPackages = Get-MgEntitlementManagementAccessPackage -Filter "catalog/id eq '$($orphanedResource.CatalogId)'" -ExpandProperty "resourceRoleScopes" -All -ErrorAction Stop
                
              Foreach ($accessPackage in $accessPackages) 
                {
                    # Check each resource role scope in the access package
                    if ($accessPackage.ResourceRoleScopes) 
                    {
                      Foreach ($roleScope in $accessPackage.ResourceRoleScopes) 
                        {
                            # Check if this role scope references the orphaned resource
                            if ($roleScope.Scope.OriginId -eq $orphanedResource.OriginId) 
                            {
                                try 
                                {
                                    #Remove-MgEntitlementManagementAccessPackageResourceRoleScope -AccessPackageId $accessPackage.Id -AccessPackageResourceRoleScopeId $roleScope.Id -ErrorAction Stop
                                    Write-Host "Removed '$($orphanedResource.ResourceName)' from access package '$($accessPackage.DisplayName)'" -ForegroundColor Green
                                }
                                catch 
                                {
                                    Write-Host "Failed to remove from '$($accessPackage.DisplayName)': $($_.Exception.Message)" -ForegroundColor Red
                                }
                            }
                        }
                    }
                }
            }
            catch 
            {
                Write-Host "  Error processing '$($orphanedResource.ResourceName)': $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        
        # Step 2: Remove orphaned resources from catalogs
        
      Foreach ($orphanedResource in $AllOrphanedResources) 
        {
            try 
            {
                #Remove-MgEntitlementManagementCatalogResource -AccessPackageCatalogId $orphanedResource.CatalogId -AccessPackageResourceId $orphanedResource.ResourceId -ErrorAction Stop
                Write-Host "Removed '$($orphanedResource.ResourceName)' from catalog '$($orphanedResource.Catalog)'" -ForegroundColor Green
            }
            catch 
            {
                Write-Host "Failed to remove '$($orphanedResource.ResourceName)': $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        
        Write-Host "`nRemoved $($AllOrphanedResources.Count) orphaned resource(s)" -ForegroundColor Green
    }
    else 
    {
        Write-Host "`nCleanup cancelled. No resources were removed." -ForegroundColor Yellow
    }
} 
else 
{
    Write-Host "No orphaned resources found" -ForegroundColor Green
}

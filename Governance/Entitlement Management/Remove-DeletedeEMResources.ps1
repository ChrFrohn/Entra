# Remove deleted resources from Entitlement Management catalogs and access packages

Connect-MgGraph -Scopes "Group.Read.All", "Application.Read.All", "EntitlementManagement.ReadWrite.All", "Sites.Read.All" -NoWelcome

# Get all catalogs
$Catalogs = Get-MgEntitlementManagementCatalog -All

$AllDeletedResources = @()

Write-Host "Checking catalogs for deleted resources..." -ForegroundColor Yellow

foreach ($catalog in $Catalogs) 
{
    $catalogResources = Get-MgEntitlementManagementCatalogResource -AccessPackageCatalogId $catalog.Id -All
    
  Foreach ($resource in $catalogResources) 
    {
        $OriginSystem = $resource.OriginSystem
        $OriginId = $resource.OriginId
        $DisplayName = $resource.DisplayName
        $IsDeleted = $false
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
                $IsDeleted = $true
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
                $IsDeleted = $true
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
                $IsDeleted = $true
            }
        }
        
        if ($IsDeleted) 
        {
            $AllDeletedResources += [PSCustomObject]@{
                Catalog      = $catalog.DisplayName
                CatalogId    = $catalog.Id
              ResourceType = $ResourceType
              ResourceName = $DisplayName
                OriginId     = $OriginId
                OriginSystem = $OriginSystem
              ResourceId   = $resource.Id
            }
            
            Write-Host "Found deleted resource: $DisplayName ($ResourceType) in $($catalog.DisplayName)" -ForegroundColor Red
        }
    }
}

if ($AllDeletedResources.Count -gt 0) 
{
    Write-Host "`nTotal deleted resources found: $($AllDeletedResources.Count)" -ForegroundColor Yellow
    
    # Ask for confirmation before proceeding
    Write-Host "`n" -NoNewline
    $confirmation = Read-Host "Do you want to remove these deleted resources? (yes/no)"
    
    if ($confirmation -in @("yes", "y", "Y", "Yes", "YES")) 
    {
        # Step 1: Remove deleted resources from access packages
        
      Foreach ($deletedResource in $AllDeletedResources) 
        {
            # Get all access packages in this catalog
            try 
            {
                $accessPackages = Get-MgEntitlementManagementAccessPackage -Filter "catalog/id eq '$($deletedResource.CatalogId)'" -ExpandProperty "resourceRoleScopes" -All -ErrorAction Stop
                
              Foreach ($accessPackage in $accessPackages) 
                {
                    # Check each resource role scope in the access package
                    if ($accessPackage.ResourceRoleScopes) 
                    {
                      Foreach ($roleScope in $accessPackage.ResourceRoleScopes) 
                        {
                            # Check if this role scope references the deleted resource
                            if ($roleScope.Scope.OriginId -eq $deletedResource.OriginId) 
                            {
                                try 
                                {
                                    #Remove-MgEntitlementManagementAccessPackageResourceRoleScope -AccessPackageId $accessPackage.Id -AccessPackageResourceRoleScopeId $roleScope.Id -ErrorAction Stop
                                    Write-Host "Removed '$($deletedResource.ResourceName)' from access package '$($accessPackage.DisplayName)'" -ForegroundColor Green
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
                Write-Host "  Error processing '$($deletedResource.ResourceName)': $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        
        # Step 2: Remove deleted resources from catalogs
        
      Foreach ($deletedResource in $AllDeletedResources) 
        {
            try 
            {
                #Remove-MgEntitlementManagementCatalogResource -AccessPackageCatalogId $deletedResource.CatalogId -AccessPackageResourceId $deletedResource.ResourceId -ErrorAction Stop
                Write-Host "Removed '$($deletedResource.ResourceName)' from catalog '$($deletedResource.Catalog)'" -ForegroundColor Green
            }
            catch 
            {
                Write-Host "Failed to remove '$($deletedResource.ResourceName)': $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        
        Write-Host "`nRemoved $($AllDeletedResources.Count) deleted resource(s)" -ForegroundColor Green
    }
    else 
    {
        Write-Host "`nCleanup cancelled. No resources were removed." -ForegroundColor Yellow
    }
} 
else 
{
    Write-Host "No deleted resources found" -ForegroundColor Green
}

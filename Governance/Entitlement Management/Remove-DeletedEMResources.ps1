# Remove deleted resources from Entitlement Management catalogs and access packages
# Please note that this scripts uses Beta graph PowerShell module as well

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
        Write-Host "`nRemoving deleted resources from ALL access packages..." -ForegroundColor Cyan
        
        $allAccessPackages = Get-MgBetaEntitlementManagementAccessPackage -ExpandProperty "accessPackageResourceRoleScopes(`$expand=accessPackageResourceRole,accessPackageResourceScope)" -All -ErrorAction Stop
        
        Foreach ($deletedResource in $AllDeletedResources) 
        {
            $removedFromPackages = 0
            
            Foreach ($accessPackage in $allAccessPackages) 
            {
                # Check each resource role scope in the access package
                if ($accessPackage.AccessPackageResourceRoleScopes) 
                {
                    Foreach ($roleScope in $accessPackage.AccessPackageResourceRoleScopes) 
                    {
                        # Check if this role scope references the deleted resource
                        if ($roleScope.AccessPackageResourceScope.OriginId -eq $deletedResource.OriginId) 
                        {
                            try 
                            {
                                Remove-MgBetaEntitlementManagementAccessPackageResourceRoleScope -AccessPackageId $accessPackage.Id -AccessPackageResourceRoleScopeId $roleScope.Id -ErrorAction Stop
                                Write-Host "  Removed '$($deletedResource.ResourceName)' from access package '$($accessPackage.DisplayName)'" -ForegroundColor Green
                                $removedFromPackages++
                            }
                            catch 
                            {
                                Write-Host "  Failed to remove '$($deletedResource.ResourceName)' from '$($accessPackage.DisplayName)': $($_.Exception.Message)" -ForegroundColor Red
                            }
                        }
                    }
                }
            }
            
            if ($removedFromPackages -eq 0) {
                Write-Host "  Resource '$($deletedResource.ResourceName)' not found in any access packages" -ForegroundColor Yellow
            } else {
                Write-Host "  Removed '$($deletedResource.ResourceName)' from $removedFromPackages access package(s)" -ForegroundColor Green
            }
        }
        
        Write-Host "`nRemoving deleted resources from catalogs..." -ForegroundColor Cyan
        
        Foreach ($deletedResource in $AllDeletedResources) 
        {
            try 
            {
                $removeParams = @{
                    requestType = "adminRemove"
                    resource = @{
                        originId = $deletedResource.OriginId
                        originSystem = $deletedResource.OriginSystem
                    }
                    catalog = @{ id = $deletedResource.CatalogId }
                }
                
                $null = New-MgEntitlementManagementResourceRequest -BodyParameter $removeParams -ErrorAction Stop
                Write-Host "  Removed '$($deletedResource.ResourceName)' from catalog '$($deletedResource.Catalog)'" -ForegroundColor Green
            }
            catch 
            {
                Write-Host "  Failed to remove '$($deletedResource.ResourceName)' from catalog: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        
        Write-Host "`nCleanup completed. Total resources processed: $($AllDeletedResources.Count)" -ForegroundColor Green
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

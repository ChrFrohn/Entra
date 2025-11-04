# Find deleted resources in Catalogs (deleted groups, applications, and SharePoint sites)

Connect-MgGraph -Scopes "Group.Read.All", "Application.Read.All", "EntitlementManagement.Read.All", "Sites.Read.All" -NoWelcome

# Get all catalogs
$Catalogs = Get-MgEntitlementManagementCatalog -All

$AllDeletedResources = @()

Write-Host "Checking catalogs for deleted resources..." -ForegroundColor Yellow

foreach ($catalog in $Catalogs) 
{
    $catalogResources = Get-MgEntitlementManagementCatalogResource -AccessPackageCatalogId $catalog.Id -All
    
    foreach ($resource in $catalogResources) 
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
                Catalog     = $catalog.DisplayName
                CatalogId   = $catalog.Id
                ResourceType = $ResourceType
                ResourceName = $DisplayName
                OriginId    = $OriginId
                OriginSystem = $OriginSystem
                ResourceId  = $resource.Id
            }
            
            Write-Host "Found deleted resource: $DisplayName ($ResourceType) in $($catalog.DisplayName)" -ForegroundColor Red
        }
    }
}

if ($AllDeletedResources.Count -gt 0) 
{
    Write-Host "`nTotal deleted resources found: $($AllDeletedResources.Count)" -ForegroundColor Yellow
    
    # Display summary by resource type
    Write-Host "`nDeleted Resources Summary:" -ForegroundColor Cyan
    $AllDeletedResources | Group-Object ResourceType | ForEach-Object {
        Write-Host "  • $($_.Name): $($_.Count) resources" -ForegroundColor White
    }
} 
else 
{
    Write-Host "`nNo deleted resources found." -ForegroundColor Green
}
# Find orphaned resources in Catalogs (deleted groups and applications)

Connect-MgGraph -Scopes "Group.Read.All", "Application.Read.All", "EntitlementManagement.Read.All"

# Get all catalogs
$Catalogs = Get-MgEntitlementManagementCatalog -All

$AllOrphanedResources = @()

Write-Host "Checking catalogs for orphaned resources..." -ForegroundColor Yellow

foreach ($catalog in $Catalogs) 
{
    $catalogResources = Get-MgEntitlementManagementCatalogResource -AccessPackageCatalogId $catalog.Id -All
    
    foreach ($resource in $catalogResources) 
    {
        $OriginSystem = $resource.OriginSystem
        $OriginId = $resource.OriginId
        $DisplayName = $resource.DisplayName
        $IsOrphaned = $false
        $ResourceType = ""
        
        # Check if Group still exists
        if ($OriginSystem -eq "AadGroup") 
        {
            $ResourceType = "Entra ID Group"
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
            $ResourceType = "Entra ID Application"
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
            # SharePoint sites require manual verification
            $IsOrphaned = $false
        }
        
        if ($IsOrphaned) 
        {
            $AllOrphanedResources += [PSCustomObject]@{
                Catalog     = $catalog.DisplayName
                CatalogId   = $catalog.Id
                ResourceType = $ResourceType
                ResourceName = $DisplayName
                OriginId    = $OriginId
                OriginSystem = $OriginSystem
                ResourceId  = $resource.Id
            }
            
            Write-Host "Found orphaned resource: $DisplayName ($ResourceType) in $($catalog.DisplayName)" -ForegroundColor Red
        }
    }
}

if ($AllOrphanedResources.Count -gt 0) 
{
    Write-Host "`nTotal orphaned resources found: $($AllOrphanedResources.Count)" -ForegroundColor Yellow
    
    $ExportPath = Join-Path $PSScriptRoot "OrphanedCatalogResources_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
    $AllOrphanedResources | Export-Csv -Path $ExportPath -NoTypeInformation
    Write-Host "Report exported to: $ExportPath" -ForegroundColor Cyan
} 
else 
{
    Write-Host "`nNo orphaned resources found." -ForegroundColor Green
}

Write-Host "Search complete."

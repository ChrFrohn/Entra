# Find orphaned resources in Access Packages (deleted groups and applications)

Connect-MgGraph -Scopes "Group.Read.All", "Application.Read.All", "EntitlementManagement.Read.All"

# Get all access packages
$AccessPackages = Get-MgEntitlementManagementAccessPackage -All

$AllOrphanedResources = @()

Write-Host "Checking access packages for orphaned resources..." -ForegroundColor Yellow

foreach ($package in $AccessPackages) 
{
    $packageDetails = Get-MgEntitlementManagementAccessPackage -AccessPackageId $package.Id -ExpandProperty "resourceRoleScopes(`$expand=role,scope)"
    
    if ($packageDetails.ResourceRoleScopes) 
    {
        foreach ($resourceRoleScope in $packageDetails.ResourceRoleScopes) 
        {
            $scope = $resourceRoleScope.Scope
            $role = $resourceRoleScope.Role
            
            if ($scope) 
            {
                $OriginSystem = $scope.OriginSystem
                $OriginId = $scope.OriginId
                $DisplayName = $scope.DisplayName
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
                        AccessPackage   = $package.DisplayName
                        AccessPackageId = $package.Id
                        ResourceType    = $ResourceType
                        ResourceName    = $DisplayName
                        OriginId        = $OriginId
                        OriginSystem    = $OriginSystem
                        RoleName        = $role.DisplayName
                    }
                    
                    Write-Host "Found orphaned resource: $DisplayName ($ResourceType) in $($package.DisplayName)" -ForegroundColor Red
                }
            }
        }
    }
}

if ($AllOrphanedResources.Count -gt 0) 
{
    Write-Host "`nTotal orphaned resources found: $($AllOrphanedResources.Count)" -ForegroundColor Yellow
    
    $ExportPath = Join-Path $PSScriptRoot "OrphanedAccessPackageResources_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
    $AllOrphanedResources | Export-Csv -Path $ExportPath -NoTypeInformation
    Write-Host "Report exported to: $ExportPath" -ForegroundColor Cyan
} 
else 
{
    Write-Host "`nNo orphaned resources found." -ForegroundColor Green
}

Write-Host "Search complete."

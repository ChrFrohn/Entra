Import-Module Microsoft.Graph.Identity.Governance

Connect-MgGraph -Scopes "EntitlementManagement.ReadWrite.All"

# SharePoint site that needs to be added as a resource to the Catalog and Access Package
$SharePointSite  = "" # SharePoint Online URL

# Catalog and Access package values
$CatalogId = ""
$AccessPackageId = ""

# Add the SharePoint as a resource to the Catalog
$SharePointResourceAddParameters = @{
  requestType = "adminAdd"
  resource = @{
    originId = $SharePointSite
		originSystem = "SharePointOnline"
  }
  catalog = @{ id = $CatalogId }
}

New-MgEntitlementManagementResourceRequest -BodyParameter $SharePointResourceAddParameters

# Get the SharePoint site as a resource from the Catalog
$CatalogResources = Get-MgEntitlementManagementCatalogResource -AccessPackageCatalogId $CatalogId -ExpandProperty "scopes" -all
$SharePointResource = $CatalogResources | Where-Object OriginId -eq $SharePointSite
$SharePointResourceId = $SharePointResource.id
$SharePointResourceScope = $SharePointResource.Scopes[0]

# Add the SharePoint site as a resource role to the Access Package
$SharePointResourceFilter = "(originSystem eq 'SharePointOnline' and resource/id eq '" + $SharePointResourceId + "')"
$SharePointResourceRoles = Get-MgEntitlementManagementCatalogResourceRole -AccessPackageCatalogId $CatalogId -Filter $SharePointResourceFilter -ExpandProperty "resource"
$ContributorRole = $SharePointResourceRoles | Where-Object DisplayName -eq "Contributors"

$SharePointResourceRoleScopeParameters = @{
  role = @{
      displayName =  "Contributors"
      description =  ""
      originSystem =  $ContributorRole.OriginSystem
      originId =  $ContributorRole.OriginId
      resource = @{
          id = $SharePointResource.Id
          originId = $SharePointResource.OriginId
          originSystem = $SharePointResource.OriginSystem
      }
  }
  scope = @{
      id = $SharePointResourceScope.Id
      originId = $SharePointResourceScope.OriginId
      originSystem = $SharePointResourceScope.OriginSystem
      displayName = "Root"
      description = "Root Scope"
      isRootScope = $true
  }
}

New-MgEntitlementManagementAccessPackageResourceRoleScope -AccessPackageId $AccessPackageId -BodyParameter $SharePointResourceRoleScopeParameters

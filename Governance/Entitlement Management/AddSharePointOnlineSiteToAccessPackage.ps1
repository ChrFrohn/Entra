# Add a SharePoint Online site to an access package in Entitlement Management
$CatalogId = "" # ID of the catalog - Sample: "db4859bf-43c3-49fa-ab13-8036bd333ebe"
$SharePointSiteURL = "" # URL of the SharePoint Online site - Sample: https://contoso.sharepoint.com/sites/HR
$SharePointSiteRole = "4" # 4 = Vistors / 5 = Members / 3 = Owners 
$AccessPackageId = "" # ID of the access package - Sample: "db4859bf-43c3-49fa-ab13-8036bd333ebe"

# Run this if you need to get the SharePoint Site ID roles
#$SharePointResourceFilter = "(originSystem eq 'SharePointOnline' and resource/id eq '" + $SharePointResourceId + "')"
#$SharePointResourceRoles = Get-MgEntitlementManagementCatalogResourceRole -AccessPackageCatalogId $CatalogId -Filter $SharePointResourceFilter -All -ExpandProperty "resource"

# Add the SharePoint Online site as a resource to the Catalog
$SharePointResourceAddParameters = @{
  requestType = "adminAdd"
  resource = @{
    originId = $SharePointSiteURL
    originSystem = "SharePointOnline"
  }
  catalog = @{ id = $CatalogId }
}

New-MgEntitlementManagementResourceRequest -BodyParameter $SharePointResourceAddParameters

# Get the SharePoint Online site as a resource from the Catalog
$CatalogResources = Get-MgEntitlementManagementCatalogResource -AccessPackageCatalogId $CatalogId -ExpandProperty "scopes" -All
$SharePointResource = $CatalogResources | Where-Object { $_.OriginId -eq $SharePointSiteURL }
$SharePointResourceId = $SharePointResource.id

#  Add the SharePoint Online site to the access package
$params = @{
  role = @{
    displayName = "Contributors"
    originSystem = "SharePointOnline"
    originId = $SharePointSiteRole
    resource = @{
      id = $SharePointResourceId
    }
  }
  scope = @{
    displayName = "Root"
    description = "Root Scope"
    originId = $SharePointSiteURL
    originSystem = "SharePointOnline"
    isRootScope = $true
  }
}

New-MgEntitlementManagementAccessPackageResourceRoleScope -AccessPackageId $AccessPackageId -BodyParameter $params
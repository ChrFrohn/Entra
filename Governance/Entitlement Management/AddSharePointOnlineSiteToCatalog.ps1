# Catalog Id and SharePoint Online site URL for the Catalog where the SharePoint site needs to be added
$CatalogId = "" # Catalog ID - Sample: "db4859bf-43c3-49fa-ab13-8036bd333ebe"
$SharePointSiteURL = "" # URL of the SharePoint Online site - Sample: https://christianfrohn.sharepoint.com/sites/HR

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

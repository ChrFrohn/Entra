# Import the necessary module
Import-Module Microsoft.Graph.Identity.Governance

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "EntitlementManagement.ReadWrite.All"

# Define the SharePoint Online site details
$SharePointSiteURL = ""
$CatalogId = ""  # 
$SharePointSiteRole = "4" # 4 = Vistors / 5 = Members / 3 = Owners | Run this to get IDs

# Run this if you need to get the SharePoint Site ID roles
#$SharePointResourceFilter = "(originSystem eq 'SharePointOnline' and resource/id eq '" + $SharePointResourceId + "')"
#$SharePointResourceRoles = Get-MgEntitlementManagementCatalogResourceRole -AccessPackageCatalogId $CatalogId -Filter $SharePointResourceFilter -All -ExpandProperty "resource"

# Add the SharePoint Online site as a resource to the catalog
$SharePointResourceAddParameters = @{
  requestType = "adminAdd"
  resource = @{
    originId = $SharePointSiteURL
    originSystem = "SharePointOnline"
  }
  catalog = @{ id = $CatalogId }
}

New-MgEntitlementManagementResourceRequest -BodyParameter $SharePointResourceAddParameters

# Get the SharePoint Online site resource ID
$CatalogResources = Get-MgEntitlementManagementCatalogResource -AccessPackageCatalogId $CatalogId -ExpandProperty "scopes" -All
$SharePointResource = $CatalogResources | Where-Object { $_.OriginId -eq $SharePointSiteURL }
$SharePointResourceId = $SharePointResource.id

#  Create a new access package resource role scope for the SharePoint Online site
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

New-MgEntitlementManagementAccessPackageResourceRoleScope -AccessPackageId "db4859bf-43c3-49fa-ab13-8036bd333ebe" -BodyParameter $params
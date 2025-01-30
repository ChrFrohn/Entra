Connect-MgGraph -Scopes "EntitlementManagement.ReadWrite.All"

# Group that needs to be added as a resource to the Catalog
$GroupObjectId  = "" # Object ID of the group

# Catalog
$CatalogId = ""

# Add the group as a resource to the Catalog
$GroupResourceAddParameters = @{
  requestType = "adminAdd"
  resource = @{
    originId = $GroupObjectId 
    originSystem = "AadGroup"
  }
  catalog = @{ id = $CatalogId }
}

New-MgEntitlementManagementResourceRequest -BodyParameter $GroupResourceAddParameters
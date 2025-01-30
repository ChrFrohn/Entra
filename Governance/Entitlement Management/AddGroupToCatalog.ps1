# Catalog Id and Group Object Id for the Catalog where the Group needs to be added
$CatalogId = "" # Catalog ID - Sample: "db4859bf-43c3-49fa-ab13-8036bd333ebe"
$GroupObjectId  = "" # Object ID of the group - Sample: "b3b3b3b3-3b3b-3b3b-3b3b-3b3b3b3b3b3b"

# Add the Group as a resource to the Catalog
$GroupResourceAddParameters = @{
  requestType = "adminAdd"
  resource = @{
    originId = $GroupObjectId 
    originSystem = "AadGroup"
  }
  catalog = @{ id = $CatalogId }
}

New-MgEntitlementManagementResourceRequest -BodyParameter $GroupResourceAddParameters
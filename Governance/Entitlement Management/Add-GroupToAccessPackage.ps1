# Add a group to an Access Package in Entitlement Management
$CatalogId = "" # ID of the catalog - Sample: "db4859bf-43c3-49fa-ab13-8036bd333ebe"
$GroupObjectId = "" # ID of the group - Sample: "db4859bf-43c3-49fa-ab13-8036bd333ebe"
$AccessPackageId = "" # ID of the Acceess package - Sample: "db4859bf-43c3-49fa-ab13-8036bd333ebe"

# Get the Group as a resource from the Catalog
$CatalogResources = Get-MgEntitlementManagementCatalogResource -AccessPackageCatalogId $CatalogId -ExpandProperty "scopes" -all
$GroupResource = $CatalogResources | Where-Object OriginId -eq $GroupObjectId 
$GroupResourceId = $GroupResource.id
$GroupResourceScope = $GroupResource.Scopes[0]

# Add the Group as a resource role to the Access Package
$GroupResourceFilter = "(originSystem eq 'AadGroup' and resource/id eq '" + $GroupResourceId + "')"
$GroupResourceRoles = Get-MgEntitlementManagementCatalogResourceRole -AccessPackageCatalogId $CatalogId -Filter $GroupResourceFilter -ExpandProperty "resource"
$GroupMemberRole = $GroupResourceRoles | Where-Object DisplayName -eq "Member"

$GroupResourceRoleScopeParameters = @{
  role = @{
      displayName =  "Member"
      description =  ""
      originSystem =  $GroupMemberRole.OriginSystem
      originId =  $GroupMemberRole.OriginId
      resource = @{
          id = $GroupResource.Id
          originId = $GroupResource.OriginId
          originSystem = $GroupResource.OriginSystem
      }
  }
  scope = @{
      id = $GroupResourceScope.Id
      originId = $GroupResourceScope.OriginId
      originSystem = $GroupResourceScope.OriginSystem
  }
 }

New-MgEntitlementManagementAccessPackageResourceRoleScope -AccessPackageId $AccessPackageId -BodyParameter $GroupResourceRoleScopeParameters
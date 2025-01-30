# Define the missing variables
$CatalogId = ""
$GroupObjectId = ""
$AccessPackageId = ""

# Existing code
# Get the group as a resource from the Catalog
$CatalogResources = Get-MgEntitlementManagementCatalogResource -AccessPackageCatalogId $CatalogId -ExpandProperty "scopes" -all
$GroupResource = $CatalogResources | Where-Object OriginId -eq $GroupObjectId 
$GroupResourceId = $GroupResource.id
$GroupResourceScope = $GroupResource.Scopes[0]

# Add the group as a resource role to the Access Package
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
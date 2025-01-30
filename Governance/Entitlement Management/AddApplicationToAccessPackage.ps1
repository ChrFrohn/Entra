# Add an application as a resource to an Access Package in Entitlement Management
$CatalogId = "" # ID of the catalog - Sample: "db4859bf-43c3-49fa-ab13-8036bd333ebe"
$ApplicationId = "" # Object ID of the Enterprise Application - Sample: "db4859bf-43c3-49fa-ab13-8036bd333ebe"
$AccessPackageId = "" # ID of the Acceess package - Sample: "db4859bf-43c3-49fa-ab13-8036bd333ebe"

$ApplicationParameters = @{
	requestType = "adminAdd"
	resource = @{
		originId = $ApplicationId
		originSystem = "AadApplication"
	}
	catalog = @{
		id = $CatalogId
	}
}

New-MgEntitlementManagementResourceRequest -BodyParameter $ApplicationParameters

# Get the Application as a resource from the Catalog
$CatalogResources = Get-MgEntitlementManagementCatalogResource -AccessPackageCatalogId $CatalogId -ExpandProperty "scopes" -All
$ApplicationResource = $CatalogResources | Where-Object { $_.OriginId -eq $ApplicationId }
$ApplicationResourceId = $ApplicationResource.id
$ApplicationResourceScope = $ApplicationResource.Scopes[0]

# Add the Application as a resource role to the Access Package
$ApplicationResourceFilter = "(originSystem eq 'AadApplication' and resource/id eq '" + $ApplicationResourceId + "')"
$ApplicationResourceRoles = Get-MgEntitlementManagementCatalogResourceRole -AccessPackageCatalogId $CatalogId -Filter $ApplicationResourceFilter -All -ExpandProperty "resource"
$ApplicationMemberRole = $ApplicationResourceRoles | Where-Object { $_.DisplayName -eq "Default Access" }

$ApplicationResourceRoleScopeParameters = @{
  role = @{
    displayName = $servicePrincipalRoleName
    description = ""
    originSystem = $ApplicationMemberRole.OriginSystem
    originId = $ApplicationMemberRole.OriginId
    resource = @{
      id = $ApplicationResource.Id
      originId = $ApplicationResource.OriginId
      originSystem = $ApplicationResource.OriginSystem
    }
  }
  scope = @{
    id = $ApplicationResourceScope.Id
    originId = $ApplicationResourceScope.OriginId
    originSystem = $ApplicationResourceScope.OriginSystem
  }
}

New-MgEntitlementManagementAccessPackageResourceRoleScope -AccessPackageId $AccessPackageId -BodyParameter $ApplicationResourceRoleScopeParameters
# Add an Entra Role to an Access Package in Entitlement Management
$CatalogId = "" # ID of the catalog - Sample: "db4859bf-43c3-49fa-ab13-8036bd333ebe" 
$EntraRole = "c4e39bd9-1100-46d3-8c65-fb160da0071f" # Change to DirectoryRole ID // https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/permissions-reference
$EligibilityStatus = "Eligible" # Change to Active if needed - Check if role is Privileged here: https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/permissions-reference
$AccessPackageId = "" # ID of the Access Package - Sample: "f4b3b3b4-4b3b-4b3b-4b3b-4b3b4b3b4b3b"

# Add the Entra role as a resource to the Catalog
$AdditionalRoleScopeParameters = @{
    role = @{
        originId = $EligibilityStatus
        displayName = if($EligibilityStatus -eq "Eligible") { "Eligible Member" } else { "Active Member" }
        originSystem = "DirectoryRole"
        resource = @{
            id = "ea036095-57a6-4c90-a640-013edf151eb1"
        }
    }
    scope = @{
        description = "Root Scope"
        displayName = "Root"
        isRootScope = $true
        originSystem = "DirectoryRole"
        originId = $EntraRole
    }
}

New-MgEntitlementManagementAccessPackageResourceRoleScope -AccessPackageId $AccessPackageId -BodyParameter $AdditionalRoleScopeParameters

# Get the Entra role as a resource from the Catalog
$CatalogResources = Get-MgEntitlementManagementCatalogResource -AccessPackageCatalogId $CatalogId -Filter "originSystem eq '$EntraRole'" -ExpandProperty "scopes" -All
$Resource = $CatalogResources | Where-Object { $_.Id -eq $CatalogResources.Id }
$ResourceScope = $Resource.Scopes[0]

# Add the resource role to the Access Package
$ResourceRoleFilter = "(id eq '" + $Resource.Id + "')"
$ResourceRoles = Get-MgEntitlementManagementCatalogResourceRole -AccessPackageCatalogId $CatalogId -Filter $ResourceRoleFilter -ExpandProperty "roles,scopes"
$ResourceRole = $ResourceRoles.Roles[0]

$ResourceRoleScopeParameters = @{
    role = @{
        id = $ResourceRole.Id
        displayName = $ResourceRole.DisplayName
        description = $ResourceRole.Description
        originSystem = $ResourceRole.OriginSystem
        originId = $ResourceRole.OriginId
        resource = @{
            id = $Resource.Id
            originId = $Resource.OriginId
            originSystem = $Resource.OriginSystem
        }
    }
    scope = @{
        id = $ResourceScope.Id
        originId = $ResourceScope.OriginId
        originSystem = $ResourceScope.OriginSystem
    }
}

New-MgEntitlementManagementAccessPackageResourceRoleScope -AccessPackageId $AccessPackageId -BodyParameter $ResourceRoleScopeParameters
Import-Module Microsoft.Graph.Identity.Governance

Connect-MgGraph -Scopes "EntitlementManagement.ReadWrite.All"

# Catalog and Access package values
$CatalogId = ""
$AccessPackageId = ""

$EntraRole = "c4e39bd9-1100-46d3-8c65-fb160da0071f" # Change to DirectoryRole ID // https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/permissions-reference
$EligibilityStatus = "Active" # Change to Active if needed - Check if role is Privileged here: https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/permissions-reference

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


# Get the resource from the Catalog
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

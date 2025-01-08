# Create an access package in Entra ID Goverance entitlment management

Import-Module Microsoft.Graph.Identity.Governance

Connect-MgGraph -Scopes "EntitlementManagement.ReadWrite.All"

# Access package information
$DisplayName = "" # The name of the access package
$Description = "" # The description of the access package
$CatalogId = "" # The ID of the catalog where the access package will be created (Needs to exists)

$AccessPackageInfoParameters = @{
	displayName = $DisplayName
	description = $Description
	isHidden = $false
	catalog = @{
		id = $CatalogId
	}
}

# Creation of the access package
New-MgEntitlementManagementAccessPackage -BodyParameter $AccessPackageInfoParameters

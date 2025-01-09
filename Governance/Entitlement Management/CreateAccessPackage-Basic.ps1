# Create an access package in Entra ID Goverance entitlment management

Import-Module Microsoft.Graph.Identity.Governance

Connect-MgGraph -Scopes "EntitlementManagement.ReadWrite.All"

# Access package parameters
$AccessPackageDisplayName = "" # Sample: "Department X"
$AccessPackageDescription = "" # Sample: "Department X Access Package"
$AccessPackageCatalogId = "" # Sample: "00000000-0000-0000-0000-000000000000"

# Creating the access package

$AccessPackageParameters = @{
	displayName = $AccessPackageDisplayName 
	description = $AccessPackageDescription
	isHidden = $false
	catalog = @{
		id = $AccessPackageCatalogId
	}
}

New-MgEntitlementManagementAccessPackage -BodyParameter $AccessPackageParameters

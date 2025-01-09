# Create an access package in Entra ID Goverance entitlment management

Import-Module Microsoft.Graph.Identity.Governance

Connect-MgGraph -Scopes "EntitlementManagement.ReadWrite.All"

# Access package parameters
$AccessPackageDisplayName = "Department Y" # Sample: "Department X"
$AccessPackageDescription = "Department Y Access Package" # Sample: "Department X Access Package"
$AccessPackageCatalogId = "c6348b01-93b3-4d7a-b634-c618e4eee601" # Sample: "00000000-0000-0000-0000-000000000000"

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

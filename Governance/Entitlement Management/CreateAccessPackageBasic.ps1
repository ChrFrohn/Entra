Import-Module Microsoft.Graph.Identity.Governance

# Access package parameters
$AccessPackageDisplayName = "" # Sample: "Sales department"
$AccessPackageDescription = "" # Sample: "Sales department access package"
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

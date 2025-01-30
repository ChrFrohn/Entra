# Catalog, Access Package and Group ID names
$CatalogName = "" # Sample: "General"
$AccessPackageName = "" # Sample: "Access Package 1"
$GroupName = "" # Sample: "Group 1"

# Get catalog by its Display Name
$GetCataLog = Get-MgEntitlementManagementCatalog -Filter "displayName eq '$CatalogName'" -All
$GetCataLog | Select-Object DisplayName, Id

# Get Access Package by its Display Name
$GetAccessPackage = Get-MgEntitlementManagementAccessPackage -Filter "displayName eq '$AccessPackageName'" -All
$GetAccessPackage | Select-Object DisplayName, Id

# Get the Object ID of a group in Entra ID by its name
$GetGroup = Get-MgGroup -Filter "DisplayName eq '$GroupName'" -All
$GetGroup | Select-Object DisplayName, Id

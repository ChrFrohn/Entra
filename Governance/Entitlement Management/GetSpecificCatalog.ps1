# Get a specific Catalog by name from Entra ID Governance Entitlement Management
$CatalogName = "General"

Get-MgEntitlementManagementCatalog -Filter "displayName eq '$CatalogName'" -All
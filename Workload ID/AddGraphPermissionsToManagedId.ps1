# Connect to Microsoft Graph
Connect-MgGraph -Scopes Application.Read.All, AppRoleAssignment.ReadWrite.All

$ManagedIdentityDisplayName = "" # Set the display name of the managed identity
$RequiredPermissions = "User.Read.All"

# Get Microsoft Graph service principal and required app roles
$GraphServicePrincipal = Get-MgServicePrincipal -Filter "AppId eq '00000003-0000-0000-c000-000000000000'"
$PermissionsToAssign = $GraphServicePrincipal.AppRoles | Where-Object { $_.Value -in $RequiredPermissions }
$ManagedIdentityServicePrincipal = Get-MgServicePrincipal -Filter "DisplayName eq '$ManagedIdentityDisplayName'"
$GraphServicePrincipalId = $GraphServicePrincipal.Id

# Assign app roles to managed identity
foreach ($Permission in $PermissionsToAssign) 
{
    New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $ManagedIdentityServicePrincipal.Id -PrincipalId $ManagedIdentityServicePrincipal.Id -ResourceId $GraphServicePrincipalId -AppRoleId $Permission.Id
}

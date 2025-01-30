# Get the ID of a group in Entra ID by its name
$GroupName = "Group Name"

Get-MgGroup -Filter "DisplayName eq '$GroupName'" -All
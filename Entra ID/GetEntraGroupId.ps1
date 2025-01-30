$GroupName = "Group Name"

Get-MgGroup -Filter "DisplayName eq '$GroupName'" -All

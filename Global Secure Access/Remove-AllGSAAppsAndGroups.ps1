# Connect to Microsoft Entra
Connect-Entra -Scopes 'Application.ReadWrite.All', 'Group.ReadWrite.All'

# Get all GSA Enterprise Applications
$GSAApps = Get-EntraBetaApplication -Filter "startswith(displayName,'GSA - ')"

# Get all GSA Security Groups
$GSAGroups = Get-EntraBetaGroup -Filter "startswith(displayName,'GSA -')"

# Delete GSA Applications
foreach ($App in $GSAApps) {
    Write-Output "Deleting application: $($App.DisplayName)"
    Remove-EntraBetaApplication -ApplicationId $App.Id
}

# Delete GSA Security Groups
foreach ($Group in $GSAGroups) {
    Write-Output "Deleting group: $($Group.DisplayName)"
    Remove-EntraBetaGroup -GroupId $Group.Id
}

Write-Output "All GSA Enterprise Applications and Security Groups have been deleted."

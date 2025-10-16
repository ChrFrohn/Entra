Connect-Entra -Scopes 'NetworkAccessPolicy.ReadWrite.All', 'Application.ReadWrite.All', 'NetworkAccess.ReadWrite.All', 'AppRoleAssignment.ReadWrite.All', 'Group.ReadWrite.All', 'Group.Create'

# CSV information
$CsvFilePath = "C:\Users\CFP\GitHub\Toolbox\GSA\WebApplications-Sample.csv" # Update with actual path to the CSV file
$CsvFileContent = Import-Csv $CsvFilePath -Delimiter ","

# Application and group naming
$ConnectorGroupName = "Default" # Update with actual connector group name
$ApplicationPrefix = "GSA - Web - " # Update with desired application prefix
$SecurityGroupPrefix = "GSA - Web - " # Update with desired security group prefix

# Get Private Connector group
$PrivateConnectorGroupName = $ConnectorGroupName # Name of the group where the Private connector is located
$PrivateConnectorGroup = Get-EntraBetaApplicationProxyConnectorGroup -Filter "Name eq '$PrivateConnectorGroupName'"

Foreach ($CsvRow in $CsvFileContent) 
{
    # Enterprise Application settings from CSV
    $AppName = $CsvRow.Name # Name of the application
    $AppUrl = $CsvRow.URL # URL of the application
    $AppPorts = @("80", "443") # Ports to be opened
    
    # Parse URL to extract hostname
    $AppUri = [System.Uri]$AppUrl
    $AppHostName = $AppUri.Host
    
    $EnterpriseAppName = $ApplicationPrefix + $AppName
    $SecurityGroupName = $SecurityGroupPrefix + $AppName

    # Create Private access 
    New-EntraBetaPrivateAccessApplication -ApplicationName $EnterpriseAppName -ConnectorGroupId $PrivateConnectorGroup.Id
    Write-Output "Enterprise Application created: $EnterpriseAppName"

    # Get Enterprise Application
    $EnterpriseApp = Get-EntraBetaApplication -Filter "DisplayName eq '$EnterpriseAppName'"
    Write-Output "Enterprise Application retrieved: $EnterpriseAppName"

    # Add FQDN to Application
    New-EntraBetaPrivateAccessApplicationSegment -ApplicationId $EnterpriseApp.Id -DestinationHost $AppHostName -Ports $AppPorts -Protocol TCP -DestinationType FQDN
    Write-Output "FQDN added to Enterprise Application: $AppHostName"

    # Create Entra Security Group
    New-EntraBetaGroup -SecurityEnabled $true -DisplayName $SecurityGroupName -MailNickname ($SecurityGroupName -replace '\s|æ|ø|å','') -MailEnabled $false
    Write-Output "Entra Security Group created: $SecurityGroupName"

    # Get Enterprise Application
    $ServicePrincipal = Get-EntraBetaServicePrincipal -Filter "displayName eq '$EnterpriseAppName'"
    $SecurityGroup = Get-EntraBetaGroup -Filter "displayName eq '$SecurityGroupName'"

    # Add Entra Security Group to Enterprise Application
    New-EntraBetaServicePrincipalAppRoleAssignment -ObjectId $ServicePrincipal.Id -ResourceId $ServicePrincipal.Id -Id $ServicePrincipal.Approles[1].Id -PrincipalId $SecurityGroup.Id
    Write-Output "Entra Security Group added to Enterprise Application: $SecurityGroupName"
}

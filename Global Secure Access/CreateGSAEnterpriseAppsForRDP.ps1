Connect-Entra -Scopes 'NetworkAccessPolicy.ReadWrite.All', 'Application.ReadWrite.All', 'NetworkAccess.ReadWrite.All', 'AppRoleAssignment.ReadWrite.All', 'Group.ReadWrite.All', 'Group.Create'

$CSVFile = "" # Path to the CSV file
$CSVFileConent = Import-Csv $CSVFile -Delimiter ";"

$ConnectorGroupName = "" # Name of the group where the Private connector is located

$applicationPreFix = "GSA - " # Prefix for the application name
$DomainName = "" # Domain name for the FQDN
$ServerName = $Variable.ServerName # Name of the server
$ServerPorts = "3389" # Ports to be opened
$ServerIP = $Variable.IPAddress # IP address of the server

$ServerFQDN = $ServerName + $DomainName # FQDN of the server
$EnterpriseApplicationName = $applicationPreFix + $ServerName # Name of the Enterprise Application

$ACLGroup = "GSA - " + $ServerName # Name of the ACL group for the Enterprise Application

# Get Private Connector group
$ConnectorGroup = Get-EntraBetaApplicationProxyConnectorGroup -Filter "Name eq '$ConnectorGroupName'"

Foreach ($Variable in $CSVFileConent) 
{
    # Create Private access 
    New-EntraBetaPrivateAccessApplication -ApplicationName $EnterpriseApplicationName -ConnectorGroupId $ConnectorGroup.Id
    Write-Output "Enterprise Application created: $EnterpriseApplicationName"

    # Get Enterprise Application
    $EnterpriseApplication = Get-EntraBetaApplication -Filter "DisplayName eq '$EnterpriseApplicationName'"
    Write-Output "Enterprise Application retrieved: $EnterpriseApplicationName"

    # Add FQDN to Application
    New-EntraBetaPrivateAccessApplicationSegment -ApplicationId $EnterpriseApplication.Id -DestinationHost $ServerFQDN -Ports $ServerPorts -Protocol TCP -DestinationType FQDN
    Write-Output "FQDN added to Enterprise Application: $ServerFQDN"

    # Add IP to Application
    New-EntraBetaPrivateAccessApplicationSegment -ApplicationId $EnterpriseApplication.Id -DestinationHost $ServerIP -Ports $ServerPorts -Protocol TCP -DestinationType ipAddress
    Write-Output "IP added to Enterprise Application: $ServerIP"

    # Create ACL GSA Group
    New-EntraBetaGroup -SecurityEnabled $true -DisplayName $ACLGroup -MailNickname $ACLGroup -MailEnabled $false
    Write-Output "ACL GSA Group created: $ACLGroup"

    # Get Enterprise Application
    $servicePrincipalObject = Get-EntraBetaServicePrincipal -Filter "displayName eq '$EnterpriseApplicationName'"
    $group = Get-EntraBetaGroup -Filter "displayName eq '$ACLGroup'"

    # Add ACL GSA Group to Enterprise Application
    New-EntraBetaServicePrincipalAppRoleAssignment -ObjectId $servicePrincipalObject.Id -ResourceId $servicePrincipalObject.Id -Id $servicePrincipalObject.Approles[1].Id -PrincipalId $group.Id
    Write-Output "ACL GSA Group added to Enterprise Application: $ACLGroup"
}

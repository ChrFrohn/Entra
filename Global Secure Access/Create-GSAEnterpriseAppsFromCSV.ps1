Connect-Entra -Scopes 'NetworkAccessPolicy.ReadWrite.All', 'Application.ReadWrite.All', 'NetworkAccess.ReadWrite.All', 'AppRoleAssignment.ReadWrite.All', 'Group.ReadWrite.All'

# CSV infomation
$CsvFilePath = "" # Update with actual path to the CSV file
$CsvFileContent = Import-Csv $CsvFilePath -Delimiter ","

# Application and group naming
$ConnectorGroupName = "Default" # Update with actual connector group name
$AppPrefix = "GSA - Web - " # Update with desired application prefix
$SecurityGroupPrefix = "GSA - Web - " # Update with desired security group prefix

# Get Private Connector group
$PrivateConnectorGroupName = $ConnectorGroupName # Name of the group where the Private connector is located
$PrivateConnectorGroup = Get-EntraBetaApplicationProxyConnectorGroup -Filter "Name eq '$PrivateConnectorGroupName'"

Foreach ($CsvRow in $CsvFileContent) 
{
    # Enterprise Application settings (from CSV row)
    $AppName = $CsvRow.Name # Name of the application
    $AppUrl = $CsvRow.URL # URL of the application
    $AppPorts = @("80", "443") # Ports to be opened

    # Parse URL to extract hostname
    $AppUri = [System.Uri]$AppUrl
    $AppHostName = $AppUri.Host
    
    $EnterpriseAppName = $AppPrefix + $AppName
    $SecurityGroupName = $SecurityGroupPrefix + $AppName

    Write-Output "Processing: $AppName"

    # Check if application already exists using Private Access command
    $ExistingPrivateApp = Get-EntraBetaPrivateAccessApplication -ErrorAction SilentlyContinue | Where-Object { $_.displayName -eq $EnterpriseAppName } | Select-Object -First 1
    
    if (-not $ExistingPrivateApp) {
        # Create Private access application
        New-EntraBetaPrivateAccessApplication -ApplicationName $EnterpriseAppName -ConnectorGroupId $PrivateConnectorGroup.Id | Out-Null
        Write-Output "  Enterprise Application created: $EnterpriseAppName"
        Start-Sleep -Seconds 5
        $ExistingPrivateApp = Get-EntraBetaPrivateAccessApplication -ErrorAction SilentlyContinue | Where-Object { $_.displayName -eq $EnterpriseAppName } | Select-Object -First 1
    } else {
        Write-Output "  Application already exists: $EnterpriseAppName"
    }
    
    # Get the full application details using the App ID from the Private Access app
    $EnterpriseApp = Get-EntraBetaApplication -Filter "AppId eq '$($ExistingPrivateApp.appId)'" -ErrorAction SilentlyContinue | Select-Object -First 1

    # Check if FQDN segment already exists
    $ExistingSegment = Get-EntraBetaPrivateAccessApplicationSegment -ApplicationId $EnterpriseApp.Id -ErrorAction SilentlyContinue | Where-Object { $_.destinationHost -eq $AppHostName }
    
    if (-not $ExistingSegment) {
        # Add FQDN to Application
        New-EntraBetaPrivateAccessApplicationSegment -ApplicationId $EnterpriseApp.Id -DestinationHost $AppHostName -Ports $AppPorts -Protocol TCP -DestinationType FQDN | Out-Null
        Write-Output "  FQDN added to Application: $AppHostName"
    } else {
        Write-Output "  FQDN segment already exists: $AppHostName"
    }

    # Check if security group already exists
    $SecurityGroup = Get-EntraBetaGroup -Filter "displayName eq '$SecurityGroupName'" -ErrorAction SilentlyContinue | Select-Object -First 1
    
    if (-not $SecurityGroup) {
        # Create Entra Security Group
        New-EntraBetaGroup -SecurityEnabled $true -DisplayName $SecurityGroupName -MailNickname ($SecurityGroupName -replace '\s|æ|ø|å','') -MailEnabled $false | Out-Null
        Write-Output "  Entra Security Group created: $SecurityGroupName"
        Start-Sleep -Seconds 3
        $SecurityGroup = Get-EntraBetaGroup -Filter "displayName eq '$SecurityGroupName'" -ErrorAction SilentlyContinue | Select-Object -First 1
    } else {
        Write-Output "  Security Group already exists: $SecurityGroupName"
    }

    # Get Service Principal
    $ServicePrincipal = Get-EntraBetaServicePrincipal -Filter "displayName eq '$EnterpriseAppName'" -ErrorAction SilentlyContinue | Select-Object -First 1
    
    # Check if group is already assigned
    $ExistingAssignment = Get-EntraBetaServicePrincipalAppRoleAssignedTo -ServicePrincipalId $ServicePrincipal.Id -ErrorAction SilentlyContinue | Where-Object { $_.PrincipalId -eq $SecurityGroup.Id }
    
    if (-not $ExistingAssignment) {
        # Find the appropriate app role
        $appRole = $ServicePrincipal.AppRoles | Where-Object { $_.AllowedMemberTypes -contains "User" } | Select-Object -First 1
        
        if ($null -eq $appRole) {
            $appRoleId = "00000000-0000-0000-0000-000000000000"
        } else {
            $appRoleId = $appRole.Id
        }

        # Add Entra Security Group to Enterprise Application
        New-EntraBetaServicePrincipalAppRoleAssignment -ObjectId $ServicePrincipal.Id -ResourceId $ServicePrincipal.Id -Id $appRoleId -PrincipalId $SecurityGroup.Id | Out-Null
        Write-Output "  Security Group assigned to Application"
    } else {
        Write-Output "  Security Group already assigned to Application"
    }
    
    Write-Output ""
}

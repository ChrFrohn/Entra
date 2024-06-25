# $ObjectId can be the users AAD object ID or email adress (UPN).
param (
    [Parameter (Mandatory = $true)]
    [object]$ObjectIdOrUPN
)

#Auth. using Service Principle with Secret against the SQL DB in Azure and Teams
$ClientID = "52055e07-a718-4079-b2dd-eb19add05566" # "enter application id that corresponds to the Service Principal" # Do not confuse with its display name
$TenantID = "7a0d6d06-8a78-4a32-aac9-23050ad2ba20" # "enter the tenant ID of the Service Principal"
$ClientSecret = "Jfq8Q~VJOIkHLEyiJxyvdeU_kNhBdinNahq52bRA" # "enter the secret associated with the Service Principal"
# SQL Auth.
$SQLRequestToken = Invoke-RestMethod -Method POST `
           -Uri "https://login.microsoftonline.com/$TenantID/oauth2/token"`
           -Body @{ resource="https://database.windows.net/"; grant_type="client_credentials"; client_id=$ClientID; client_secret=$ClientSecret }`
           -ContentType "application/x-www-form-urlencoded"
$SQLAccessToken = $SQLRequestToken.access_token

# SQL server info
$SQLServer = "cfp-sql.database.windows.net"
$DBName = "PhoneNumbers"
$DBTableName1 = "PSTNNumbers_DK"

# Teams Auth.
$tokenRequestBody = @{   
    Grant_Type    = "client_credentials"   
    Client_Id     = $ClientID 
    Client_Secret = $ClientSecret   
}

# Get Graph Token
$tokenRequestBody.Scope = "https://graph.microsoft.com/.default"
$graphToken = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token" -Method POST -Body $tokenRequestBody | Select-Object -ExpandProperty Access_Token

# Get Teams Token
$tokenRequestBody.Scope = "48ac35b8-9aa8-4d74-927d-1f4a14a0b239/.default"
$teamsToken = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token" -Method POST -Body $tokenRequestBody | Select-Object -ExpandProperty Access_Token

# Connect to Microsoft Teams
Connect-MicrosoftTeams -AccessTokens @($graphToken, $teamsToken) | Out-Null

#XML file containing InterpretedUserType to lookup for actions
[xml]$xml = Get-Content "C:\Users\Frohn\GitHub\Entra-ID\Governance\LifecycleWorkflows\Assign Teams Phonenumber\InterpretedUserType.xml" #Need a change to -Path where the script is running, or get the XML from URL

# Get user infomation from Microsoft Teams (since we need the user to be there)
$User = Get-CsOnlineUser -Identity $ObjectIdOrUPN | Select-Object UserPrincipalName, OnPremLineURI, LineURI, RegistrarPool, TeamsUpgradeEffectiveMode, InterpretedUserType, Department

Function CheckTeamsUserReadiness {
    param (
        [Parameter(Mandatory=$true)]
        $User
    )

    $XMLnode = $User.InterpretedUserType
    $XML_Values=$xml.SelectNodes("/InterpretedUser/Type[@id='$XMLnode']")
    $allChecksPassed = $true
    $failureMessages = @()

    # Check OnPremLineURI
    if([string]::IsNullOrWhiteSpace($User.OnPremLineURI)) {
        Write-OutPut "OnPremLineURI Check: Passed"
    }
    else {
        $failureMessages += "OnPremLineURI Check: Failed - $($User.OnPremLineURI)"
        $allChecksPassed = $false
    }
    # Check LineURI
    if([string]::IsNullOrWhiteSpace($User.LineURI)) {
        Write-OutPut "LineURI Check: Passed"
    }
    else {
        $failureMessages += "LineURI Check: Failed - $($User.LineURI)"
        $allChecksPassed = $false
    }

    # Check RegistrarPool
    if($User.RegistrarPool -ne $null) {
        Write-OutPut "RegistrarPool Check: Passed"
    }
    else {
        $failureMessages += "RegistrarPool Check: Failed - is not set."
        $allChecksPassed = $false
    }

    # Check CoexistenceMode
    if($User.TeamsUpgradeEffectiveMode -eq 'TeamsOnly' -or $User.TeamsUpgradeEffectiveMode -eq 'Island Mode') {
        Write-OutPut "Users CoexistenceMode Check: Passed ($($User.TeamsUpgradeEffectiveMode))"
    }
    else {
        $failureMessages += "Users CoexistenceMode Check: Failed - $($User.TeamsUpgradeEffectiveMode)"
        $allChecksPassed = $false
    }

    # Check interpreted user type
    if($XML_Values.action -eq "Proceed") {
        Write-OutPut "interpretedUserType Check: Passed - $($User.InterpretedUserType)"
    }
    else {
        $failureMessages += "InterpretedUserType Check: Failed - $($User.InterpretedUserType) + $($XML_Values.Solution)" 
        $allChecksPassed = $false
    }
 
    # Final check
    if($allChecksPassed) {
        # Return "Proceed" if all checks passed - this will be used to determine if the user is ready to be enabled for Teams
        return "Proceed"
    }
    else {
        # Return failure messages if checks did not pass - this will be outputted in the main script
        return "Error(s)", $failureMessages
        Exit 1
    }
}

Function EnableTeamsUser {
            param (
                [Parameter(Mandatory=$true)]
                [string]$UserDepartment,
                [Parameter(Mandatory=$true)]
                [object]$User
            )
            # Determine if a reserved number is needed based on $UserDepartment
            $condition = if ($UserDepartment -ne $null) {"ReservedFor='$UserDepartment'"} else {"UsedBy IS NULL and ReservedFor IS NULL"}
            $Query_Numbers = "SELECT * FROM $DBTableName1 WHERE $condition;"
        
            # Get numbers based on condition
            $Numbers = Invoke-Sqlcmd -ServerInstance $SQLServer -Database $DBName -AccessToken $SQLAccessToken -Query $Query_Numbers -Verbose
            # Select the first available phone number
            $SelectedNumber = $Numbers | Select-Object -First 1
        
            if ($SelectedNumber -ne $null) {
                $CountryCode = $SelectedNumber.CountryCode
                $Number = $SelectedNumber.PSTNnumber
                $CountryCodeAndNumber = "$CountryCode" + "$Number"
        
                # Configuring the user in Teams
                Set-CsPhoneNumberAssignment -Identity $User.UserPrinciplaName -PhoneNumber +$CountryCodeAndNumber -PhoneNumberType DirectRouting -EnterpriseVoiceEnabled $true
        
                # Updating the DB
                $TrimUserPrincipalName = $User.UserPrincipalName -replace "@", "_"
                $Query_UpdateNumber = "UPDATE $DBTableName1 SET UsedBy='$($TrimUserPrincipalName)' WHERE PSTNNumber=$Number"
                Invoke-Sqlcmd -ServerInstance $SQLServer -Database $DBName -AccessToken $SQLAccessToken -Query $Query_UpdateNumber -Verbose
        
                Write-OutPut $User.UserPrincipalName "Enabled user for PSTN in Teams with number" $Number
            } else {
                Write-OutPut "No available numbers found."
            }
}

# If $ReadinessResult is "Proceed", then the user is ready to be enabled for Teams and assigned a phone number, if "Error(s)" then the user is not ready and the failure messages are outputet
$ReadinessResult = CheckTeamsUserReadiness -User $User

if ($ReadinessResult -eq "Proceed") 
{
    EnableTeamsUser
} 
else 
{
    # Output failure messages if checks did not pass
    $ReadinessResult | ForEach-Object { Write-Output $_ }
}
   


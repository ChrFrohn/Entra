param (
    [Parameter (Mandatory = $true)] 
    [string]$ObjectId
)

# JSON file
$Username = "" # Your GitHub username
$Token = "" # Your GitHub personal access token
$Repo = "" # The name of the Github repository
$File_path = "" # The path to the file in the repository
 
# GitHub API URL & headers
$Url = "https://api.github.com/repos/$Username/$Repo/contents/$File_path"
$Headers = @{ "Authorization" = "Basic $([Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $Username,$Token))))" }

# Send the API request to GitHub to get the file content
$response = Invoke-WebRequest -Uri $Url -UseBasicParsing -Headers $Headers -ErrorAction Stop
$content = $response.Content | ConvertFrom-Json
$GitHubFileContent = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($content.content))
$JSON = $GitHubFileContent | ConvertFrom-Json

# Access package catalogs object IDs
$EMCatalogIDs = @(
    "", 
    "", 
    "", 
    "",
    "", 
    "", 
    ""  
) 

# Service Principal
$TenantID = ""
$ClientID = ""
$ClientSecret = ""

# Authentification to AD
$Domain = ""
$ADUsername = ""
$ADpassword = ""
$Useradmin = "$Domain\$ADUsername"
$SecurePassword = ConvertTo-SecureString -String $ADpassword -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Useradmin, $SecurePassword

function Set-ADGroupMember {
    param (
        [Parameter (Mandatory = $true)] # Name of the ADGroup group
        [string]$Identity,
        [Parameter (Mandatory = $true)] # The user that will be processed (Needs to be an email address of the user)
        [string]$Member,
        [Parameter (Mandatory = $true)] # Add or Remove, if the user should be added to the ADGroup group or removed from it.
        [string]$Action
    )

    try {
        if ($Action -eq "Add") {
            Add-ADGroupMember -Identity $Identity -Members $Member -Credential $Credential
            Write-Output "Adding $Member to $Identity"
        } else {
            Remove-ADGroupMember -Identity $Identity -Members $Member -Credential $Credential -Confirm:$false
            Write-Output "Removing $Member from $Identity"
        }
    } catch {
        Write-Output "An error occurred: $_"
    }
}

function Get-AllADGroupLists {
    param ([array]$json)
    $allLists = @()
    foreach ($accessPackage in $json.AccessPackages) {
        $allLists += $accessPackage.ADGroups | Where-Object { $_ -ne $null -and $_ -ne "" }
    }
    $allLists | Sort-Object -Unique
}

function Get-ADGroupLists {
    param (
        [array]$UsersAccessPackages,
        [array]$json
    )
    $ADGroupLists = @()
    foreach ($accessPackage in $json.AccessPackages) {
        if ($UsersAccessPackages -contains $accessPackage.AccessPackageID) {
            $ADGroupLists += $accessPackage.ADGroups | Where-Object { $_ -ne $null -and $_ -ne "" }
                }
            }
    $ADGroupLists | Sort-Object -Unique
}

function Remove-UserFromCurrentLists {
    param (
        [string]$UserName,
        [array]$currentLists,
        [array]$jsonLists,
        [array]$requiredLists
    )
    $listsToRemove = $currentLists | Where-Object { $jsonLists -contains $_ -and $requiredLists -notcontains $_ }
    foreach ($list in $listsToRemove) {
        Set-ADGroupMember -Identity $list -Member $userAttributes.userPrincipalName.Split("@")[0].ToUpper() -Action "Remove"
    }
}

function Add-UserToLists {
    param (
        [string]$UserName,
        [array]$lists
    )
    # Add user to the ADGroup lists
    foreach ($list in $lists | Sort-Object -Unique) {
        Set-ADGroupMember -Identity $list -Member $userAttributes.userPrincipalName.Split("@")[0].ToUpper() -Action "Add"
    }
}


# Authenticate to Microsoft Graph API
$body = @{
    grant_type    = "client_credentials"
    client_id     = $ClientID
    client_secret = $ClientSecret
    scope         = "https://graph.microsoft.com/.default"
}

$response = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token" -ContentType "application/x-www-form-urlencoded" -Body $body
$accessToken = $response.access_token

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type"  = "application/json"
}

# Get user attributes
$url = "https://graph.microsoft.com/v1.0/users/${ObjectId}"
$userAttributes = Invoke-RestMethod -Uri $url -Headers $headers -Method Get -ErrorAction Stop

# Initialize an empty array to store all Access Package assignments
$allAssignments = @()
$assignmentsUri = "https://graph.microsoft.com/beta/identityGovernance/entitlementManagement/accessPackageAssignments"

do {
    $response = Invoke-RestMethod -Method Get -Uri $assignmentsUri -Headers $headers
    $allAssignments += $response.value
    $assignmentsUri = $response.'@odata.nextLink'
} while ($assignmentsUri -ne $null)

# Filter Access package assignments
$Catalogs = $EMCatalogIDs
$filteredAssignments = $allAssignments | Where-Object {
    $_.targetId -eq $($userAttributes.id) -and
    $_.assignmentState -eq 'Delivered' -and
    $_.catalogId -in $Catalogs
}

$UsersEMAccessPackages = $filteredAssignments | Where-Object { $_.catalogId -in $EMCatalogIDs } | Select-Object -ExpandProperty accessPackageId

# Filter the AD Groups where the user is member of
$UserCurrentADGroups = Get-ADPrincipalGroupMembership -Identity $userAttributes.userPrincipalName.Split("@")[0].ToUpper() -Credential $Credential | Where-Object { $_.SamAccountName -notlike '$*' } | Select-Object SamAccountName

$allJsonLists = Get-AllADGroupLists -json $JSON
$newADGroupLists = Get-ADGroupLists -UsersAccessPackages $UsersEMAccessPackages -json $JSON

# Remove the user from the current AD groups that are not in the new AD group lists
Remove-UserFromCurrentLists -UserName $userAttributes.userPrincipalName.Split("@")[0].ToUpper() -currentLists $UserCurrentADGroups.SamAccountName -jsonLists $allJsonLists -requiredLists $newADGroupLists

# Add the user to the new AD group lists
Add-UserToLists -UserName $userAttributes.userPrincipalName.Split("@")[0].ToUpper() -lists $newADGroupLists

param (
    [Parameter (Mandatory = $true)] 
    [string]$ObjectId
)

# Auth information
# Exhange Online organization name:
$ExchangeOrganization = "" 

# Service Principal infomation:
$TenantID = ""
$ClientID = ""
$ClientSecret = ""

# JSON file
$jsonFilePath = ""

if (-Not (Test-Path -Path $jsonFilePath)) {
    Write-Error "JSON file not found at path: $jsonFilePath"
    exit
}
$jsonContent = Get-Content -Path $jsonFilePath -Raw
$mailLists = $jsonContent | ConvertFrom-Json

# Connections
# Auth - Exchange Online
try {
    Connect-ExchangeOnline # -ManagedIdentity -Organization $ExchangeOrganization -ShowBanner:$false
} catch {
    Write-Error "Failed to connect to Exchange Online: $_"
    exit
}

# Auth - Microsoft Graph
$body =  @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $ClientID
    Client_Secret = $ClientSecret
}

try {
    $connection = Invoke-RestMethod `
                -Uri https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token `
                -Method POST `
                -Body $body
} catch {
    Write-Error "Failed to get token from Microsoft Graph: $_"
    exit
}

$Headers = @{
    "Content-Type" = "application/json"
    "Authorization" = "Bearer " + $connection.access_token
}

$GraphToken = $connection.access_token | ConvertTo-SecureString -AsPlainText -Force
try {
    Connect-MgGraph -AccessToken $GraphToken 
} catch {
    Write-Error "Failed to connect to Microsoft Graph: $_"
    exit
}

#### Execution ####

# Get the user from Microsoft Graph
$url = "https://graph.microsoft.com/v1.0/users/${ObjectId}"
try {
    $user = Invoke-RestMethod -Uri $url -Headers $Headers -Method Get

} catch {
    Write-Error "Failed to get user via Microsoft Graph: $_"
}

# Get Access packages from Entra ID Goverance that users has assigned and is delivered
$allAssignments = @()
$assignmentsUri = "https://graph.microsoft.com/beta/identityGovernance/entitlementManagement/accessPackageAssignments"

do {
    $response = Invoke-RestMethod -Method Get -Uri $assignmentsUri -Headers $headers
    $allAssignments += $response.value
    $assignmentsUri = $response.'@odata.nextLink'
} while ($assignmentsUri -ne $null)

$filteredAssignments = $allAssignments | Where-Object { 
            $_.targetId -eq $($User.id) -and 
            $_.assignmentState -eq 'Delivered'
} 

$newAccessPackageID = $filteredAssignments | Select-Object -ExpandProperty accessPackageId 

# Get Distrubtions lists from Exchange Online
$DistributionGroups = Get-Distributiongroup -resultsize unlimited 
        
# Filter the Distribution Lists where given User is member
$UserCurrentDistrubtionslist = $DistributionGroups | Where-Object { (Get-DistributionGroupMember $_.Name -ResultSize Unlimited | ForEach-Object {$_.PrimarySmtpAddress}) -contains "$($User.userPrincipalName)"} | Select-Object PrimarySmtpAddress

# Function to get all distribution lists from the JSON
function Get-AllDistributionLists {
    param (
        [object]$mailLists # The JSON object containing the distribution lists
    )

    $allLists = @()

    foreach ($accessPackage in $mailLists.AccessPackages) {
        $allLists += $accessPackage.MainDistributionLists
        foreach ($distList in $accessPackage.DistributionLists) {
            $allLists += $distList.PSObject.Properties.Name
        }
    }

    # Remove duplicates
    $allLists = $allLists | Sort-Object -Unique
    return $allLists
}

# Function to get distribution lists for a given access package ID
function Get-DistributionLists {
    param (
        [string]$accessPackageID # The access package ID to get distribution lists for
    )

    $distributionLists = @()

    # Find the access package distribution lists
    $accessPackage = $mailLists.AccessPackages | Where-Object { $_.AccessPackageID -eq $accessPackageID }
    if ($accessPackage) {
        $distributionLists += $accessPackage.MainDistributionLists
        foreach ($distList in $accessPackage.DistributionLists) {
            $distributionLists += $distList.PSObject.Properties.Name
        }
    }

    # Remove duplicates
    $distributionLists = $distributionLists | Sort-Object -Unique
    return $distributionLists
}

# Function to add/remove user to/from distribution lists
function Set-DistributionGroupMember {
    param (
        [Parameter (Mandatory = $true)] # Name of the distribution group
        [string]$Identity,
        [Parameter (Mandatory = $true)] # The user that will be processed (Needs to be an email address of the user)
        [string]$Member,
        [Parameter (Mandatory = $true)] # Add or Remove, if the user should be added to the distribution group or removed from it.
        [string]$Action
    )

    try {
        if ($Action -eq "Add") {
            Add-DistributionGroupMember -Identity $Identity -Member $Member -BypassSecurityGroupManagerCheck
            Write-Output "Adding $Member to $Identity"
        } else {
            Remove-DistributionGroupMember -Identity $Identity -Member $Member -Confirm:$false -BypassSecurityGroupManagerCheck 
            Write-Output "Removing $Member from $Identity"
        }
    } catch {
        Write-Output "An error occurred: $_"
    }
}

# Function to add user to new distribution lists
function Add-UserToLists {
    param (
        [string]$UserName, # The user that will be processed (Needs to be an email address of the user)
        [array]$lists # The distribution lists to add the user to
    )
    foreach ($list in $lists) {
        Set-DistributionGroupMember -Identity $list -Member $ObjectId -Action "Add"
    }
}

# Function to remove user from current distribution lists that are in the JSON
function Remove-UserFromCurrentLists {
    param (
        [string]$username, # The user that will be processed (Needs to be an email address of the user)
        [array]$currentLists, # The current distribution lists the user is a member of
        [array]$jsonLists, # The distribution lists from the JSON
        [array]$requiredLists # The required distribution lists for the user
    )

    # Find the intersection of current lists and JSON lists, excluding required lists
    $listsToRemove = $currentLists | Where-Object { $jsonLists -contains $_ -and $requiredLists -notcontains $_ }

    foreach ($list in $listsToRemove) {
        Set-DistributionGroupMember -Identity $list -Member $($User.userPrincipalName) -Action "Remove"
    }
}

# Get all distribution lists from the JSON
$allJsonLists = Get-AllDistributionLists -mailLists $mailLists

# Get the new distribution lists
$newDistributionLists = Get-DistributionLists -accessPackageID $newAccessPackageID

# Remove the user from current distribution lists that are in the JSON, excluding required lists
Remove-UserFromCurrentLists -username $User.userPrincipalName -currentLists $UserCurrentDistrubtionslist.PrimarySmtpAddress -jsonLists $allJsonLists -requiredLists $newDistributionLists

# Add the user to the new distribution lists
Add-UserToLists -UserName $User.userPrincipalName -lists $newDistributionLists

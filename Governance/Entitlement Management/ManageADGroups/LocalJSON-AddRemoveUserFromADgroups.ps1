param (
    [Parameter (Mandatory = $true)] 
    [string]$ObjectId
)

# Auth information
# Service Principal information:
$TenantID = "" # Your tenant ID here
$ClientID = "" # Your client ID here
$ClientSecret = "" # Your client secret here
$jsonFilePath = "C:\Scripts\ADGroups.json" # Path to your JSON file

if (-Not (Test-Path -Path $jsonFilePath)) {
    Write-Error "JSON file not found at path: $jsonFilePath"
    exit
}
$jsonContent = Get-Content -Path $jsonFilePath -Raw
$adGroups = $jsonContent | ConvertFrom-Json

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

#### Execution ####

# Get the user from Microsoft Graph
$url = "https://graph.microsoft.com/v1.0/users/${ObjectId}"
try {
    $user = Invoke-RestMethod -Uri $url -Headers $Headers -Method Get

} catch {
    Write-Error "Failed to get user via Microsoft Graph: $_"
}

# Get Access packages from Entra ID Governance that users have assigned and are delivered
$allAssignments = @()
$assignmentsUri = "https://graph.microsoft.com/beta/identityGovernance/entitlementManagement/accessPackageAssignments"

do {
    $response = Invoke-RestMethod -Method Get -Uri $assignmentsUri -Headers $headers
    $allAssignments += $response.value
    $assignmentsUri = $response.'@odata.nextLink'
} while ($assignmentsUri -ne $null)

$filteredAssignments = $allAssignments | Where-Object { 
            $_.targetId -eq $($user.id) -and 
            $_.assignmentState -eq 'Delivered'
} 

$newAccessPackageID = $filteredAssignments | Select-Object -ExpandProperty accessPackageId 

# Filter the AD groups where the given user is a member
$UserCurrentADGroups = Get-ADPrincipalGroupMembership -Identity $user.userPrincipalName.Split("@")[0].ToUpper() | Select-Object SamAccountName

# Function to get all AD groups from the JSON
function Get-AllADGroupLists {
    param (
        [object]$adGroups # The JSON object containing the AD groups
    )

    $allGroups = @()

    foreach ($accessPackage in $adGroups.AccessPackages) {
        $allGroups += $accessPackage.ADGroups | Where-Object { $_ -ne $null -and $_ -ne "" }
    }

    # Remove duplicates
    $allGroups = $allGroups | Sort-Object -Unique
    return $allGroups
}

# Function to get AD groups for a given access package ID
function Get-ADGroupLists {
    param (
        [string]$accessPackageID, # The access package ID to get AD groups for
        [object]$adGroups
    )

    $adGroupLists = @()

    # Find the access package AD groups
    $accessPackage = $adGroups.AccessPackages | Where-Object { $_.AccessPackageID -eq $accessPackageID }
    if ($accessPackage) {
        $adGroupLists += $accessPackage.ADGroups | Where-Object { $_ -ne $null -and $_ -ne "" }
    }

    # Remove duplicates
    $adGroupLists = $adGroupLists | Sort-Object -Unique
    return $adGroupLists
}

# Function to add/remove user to/from AD groups
function Set-ADGroupMember {
    param (
        [Parameter (Mandatory = $true)] # Name of the AD group
        [string]$Identity,
        [Parameter (Mandatory = $true)] # The user that will be processed (UPN)
        [string]$Member,
        [Parameter (Mandatory = $true)] # Add or Remove, if the user should be added to the AD group or removed from it.
        [string]$Action
    )

    try {
        if ($Action -eq "Add") {
            Add-ADGroupMember -Identity $Identity -Members $Member
            Write-Output "Adding $Member to $Identity"
        } else {
            Remove-ADGroupMember -Identity $Identity -Members $Member -Confirm:$false
            Write-Output "Removing $Member from $Identity"
        }
    } catch {
        Write-Output "An error occurred: $_"
    }
}

# Function to remove user from current AD groups
function Remove-UserFromCurrentGroups {
    param (
        [string]$username, # The user that will be processed (Needs to be an email address of the user)
        [array]$currentGroups, # The current AD groups the user is a member of
        [array]$jsonGroups, # The AD groups from the JSON
        [array]$requiredGroups # The required AD groups for the user
    )

    # Find the intersection of current groups and JSON groups, excluding required groups
    $groupsToRemove = $currentGroups | Where-Object { $jsonGroups -contains $_ -and $requiredGroups -notcontains $_ }

    foreach ($group in $groupsToRemove) {
        Set-ADGroupMember -Identity $group -Member $username -Action "Remove"
    }
}

# Function to add user to new AD groups
function Add-UserToGroups {
    param (
        [string]$UserName, # The user that will be processed (Needs to be an email address of the user)
        [array]$groups # The AD groups to add the user to
    )
    foreach ($group in $groups) {
        Set-ADGroupMember -Identity $group -Member $UserName -Action "Add"
    }
}

# Get all AD groups from the JSON
$allJsonGroups = Get-AllADGroupLists -adGroups $adGroups

# Get the new AD groups
$newADGroupLists = @()
foreach ($accessPackageID in $newAccessPackageID) {
    $newADGroupLists += Get-ADGroupLists -accessPackageID $accessPackageID -adGroups $adGroups
}

# Remove the user from current AD groups that are in the JSON, excluding required groups
Remove-UserFromCurrentGroups -username $user.userPrincipalName -currentGroups $UserCurrentADGroups.SamAccountName -jsonGroups $allJsonGroups -requiredGroups $newADGroupLists

# Add the user to the new AD groups
Add-UserToGroups -UserName $user.userPrincipalName -groups $newADGroupLists

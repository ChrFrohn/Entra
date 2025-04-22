param (
    [Parameter (Mandatory = $true)] 
    [string]$ObjectId
)

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

# Access package catalogs
$EMCatalogIDs = @(
    "", 
    "", 
    "", 
    "",
    "", 
    "", 
    ""  
) 

# Auth information - Azure subscription / Tenant ID
$AzureSubscriptionID = ""
$TenantID = ""

# Service Principal
$ClientID = ""
$ClientSecret = ""

# Authentification to AD
$Domain = ""
$ADUsername = ""
$ADpassword = ""
$Useradmin = "$Domain\$ADUsername"
$SecurePassword = ConvertTo-SecureString -String $ADpassword -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Useradmin , $SecurePassword

$MaxRetryCount = "5"
$RetryDelay = "30"
$Stoploop = $false
[int]$Retrycount = "0"

do {
    try {
        # Connect to Azure - Managed ID
        Connect-AzAccount -Identity -Subscription $AzureSubscriptionID | Out-Null

        

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

        # Initialize an empty array to store all assignments
        $allAssignments = @()
        $assignmentsUri = "https://graph.microsoft.com/beta/identityGovernance/entitlementManagement/accessPackageAssignments"

        do {
            $response = Invoke-RestMethod -Method Get -Uri $assignmentsUri -Headers $headers
            $allAssignments += $response.value
            $assignmentsUri = $response.'@odata.nextLink'
        } while ($assignmentsUri -ne $null)

        # Filter assignments
        $Catalogs = $EMCatalogIDs
        $filteredAssignments = $allAssignments | Where-Object {
            $_.targetId -eq $($userAttributes.id) -and
            $_.assignmentState -eq 'Delivered' -and
            $_.catalogId -in $Catalogs
        }
        
        $UsersEMAccessPackages = $filteredAssignments | Where-Object { $_.catalogId -in $EMCatalogIDs } | Select-Object -ExpandProperty accessPackageId
        
        # Load JSON from file
        # Auth information - GitHub
        $jsonFilePath = "C:\Scripts\ADGroups.json" # Path to your JSON file

        if (-Not (Test-Path -Path $jsonFilePath)) {
            Write-Error "JSON file not found at path: $jsonFilePath"
        exit
        }
        $jsonContent = Get-Content -Path $jsonFilePath -Raw
        $JSON = $jsonContent | ConvertFrom-Json

        # Filter the ADGroup Lists where given User is member
        $UserCurrentADGroups = Get-ADPrincipalGroupMembership -Identity $userAttributes.userPrincipalName.Split("@")[0].ToUpper() -Credential $Credential | Where-Object { $_.SamAccountName -notlike '$*' } | Select-Object SamAccountName

        $allJsonLists = Get-AllADGroupLists -json $JSON
        $newADGroupLists = Get-ADGroupLists -UsersAccessPackages $UsersEMAccessPackages -json $JSON

        Remove-UserFromCurrentLists -UserName $userAttributes.userPrincipalName.Split("@")[0].ToUpper() -currentLists $UserCurrentADGroups.SamAccountName -jsonLists $allJsonLists -requiredLists $newADGroupLists

        Add-UserToLists -UserName $userAttributes.userPrincipalName.Split("@")[0].ToUpper() -lists $newADGroupLists

        # Output the job is done.
        Write-Output "Job completed"
        $Stoploop = $true
    } catch {
        if ($Retrycount -gt $MaxRetryCount) {
            # Final message after 5 tries
            Write-Output "Could not send Information after 5 retries."
            $Stoploop = $true
        } else {
            # Retry delay
            Write-Output "Could not send Information retrying in 30 seconds..."
            Start-Sleep -Seconds $RetryDelay
            $Retrycount = $Retrycount + 1
            Write-Output "Retry count: $Retrycount"
        }
    }
} while ($Stoploop -eq $false)
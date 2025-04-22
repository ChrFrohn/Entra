# $ObjectId can be the users AAD object ID or email adress (UPN).
param (
    [Parameter (Mandatory = $true)]
    [object]$ObjectIdOrUPN
)

# Auth. infomation
$ClientId = ""
$TenantId = ""
$ClientSecret = ""
$SPOTenant = "" # Sample: christinafrohn.sharepoint.com
$CertThumbprint = "" 

# Authenticate to Microsoft Graph
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

# Get the user from Microsoft Graph
$url = "https://graph.microsoft.com/v1.0/users/${ObjectIdOrUPN}"
$user = Invoke-RestMethod -Uri $url -Headers $headers -Method Get -ErrorAction Stop 

# Connect to PnP Online (SPO)
Connect-PnPOnline $SPOTenant -ClientId $ClientId -Tenant $SPOTenant -Thumbprint $CertThumbprint

# Define a helper function to update user profile properties and handle errors
function Update-SPOUserProfileProperty {
    param (
        [string]$Account,
        [string]$PropertyName,
        [string]$Value,
        [string]$PropertyDisplayName
    )

    try {
        Set-PnPUserProfileProperty -Account $Account -PropertyName $PropertyName -Value $Value
        Write-Output "$PropertyName set to $Value for $Account"
    } catch {
        Write-Error "Failed to set ${PropertyDisplayName} for ${Account}: $_"
    }
}

# Update the user in SharePoint Online using the helper function
Update-SPOUserProfileProperty -Account $user.UserPrincipalName -PropertyName "SPS-HireDate" -Value $User.HireDate -PropertyDisplayName "SPS-HireDate"
Update-SPOUserProfileProperty -Account $user.UserPrincipalName -PropertyName "SPS-Location" -Value $User.officeLocation -PropertyDisplayName "SPS-Location"

$formattedMobileNumber = $User.mobilePhone -replace '(\d{2})(?=\d{2})', '$1 '
Update-SPOUserProfileProperty -Account $user.UserPrincipalName -PropertyName "CellPhone" -Value $formattedMobileNumber -PropertyDisplayName "CellPhone"

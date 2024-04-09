# Get the infomation from the Azure AD app registration
$ClientID = "[yourClientId]"
$ClientSecret = "[yourClientSecret]"
$TenantID = "[yourTenantId]"

# Define the location of the JSON file to upload
$JsonFileLocation = ""

# Define the API endpoint for the inbound provisioning - Can be found on the provisioning configuration page in the Azure portal
$InboundProvisioningAPIEndpoint = ""

# Code execution starts here

# Define the parameters for getting the access token
$tokenParams = @{
    Uri         = "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token"
    Method      = 'POST'
    Body        = @{
        client_id     = $ClientID
        scope         = 'https://graph.microsoft.com/.default'
        client_secret = $ClientSecret
        grant_type    = 'client_credentials'
    }
    ContentType = 'application/x-www-form-urlencoded'
}

# Get the access token
$accessTokenResponse = Invoke-RestMethod @tokenParams

# Parameters for JSON upload to API-driven provisioning endpoint
$bulkUploadParams = @{
    Uri         = $InboundProvisioningAPIEndpoint
    Method      = 'POST'
    Headers     = @{
        'Authorization' = "Bearer " +  $accessTokenResponse.access_token
        'Content-Type'  = 'application/scim+json'
    }
    Body        = ([System.Text.Encoding]::UTF8.GetBytes($JsonFileLocation))
    Verbose     = $true
}

# Send the JSON payload to the API-driven provisioning endpoint
$response = Invoke-RestMethod @bulkUploadParams



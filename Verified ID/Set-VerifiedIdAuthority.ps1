# Define Azure AD credentials
$tenantId = ""
$clientId = ""
$clientSecret = ""

# Define the token endpoint
$tokenUrl = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"

# Define the request body for token acquisition
$body = @{
    grant_type    = "client_credentials"
    client_id     = $clientId
    client_secret = $clientSecret
    scope         = "https://management.azure.com/.default" # Scope for Azure Resource Manager API
}

# Request the token
$response = Invoke-RestMethod -Uri $tokenUrl -Method Post -Body $body -ContentType "application/x-www-form-urlencoded"

# Extract the bearer token
$bearerToken = $response.access_token

# Define the API endpoint for the PUT request
$subscriptionId = "" # Azure subscription ID
$resourceGroupName = "" # Resource group name
$authorityId = "" # Authority ID (used in the API URL)
$location = "" # Resource provider location

# Construct the API URL using the authority ID
$putApiUrl = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.VerifiedId/authorities/$authorityId`?api-version=2024-01-26-preview"

# Ensure the API URL includes the api-version parameter
Write-Output "PUT API URL: $putApiUrl"

# Define the request body
$putBody = @{
    location = $location
} | ConvertTo-Json -Depth 10

# Define the headers
$putHeaders = @{
    "Authorization" = "Bearer $bearerToken"
    "Content-Type"  = "application/json"
}

# Make the PUT request
$putResponse = Invoke-RestMethod -Uri $putApiUrl -Headers $putHeaders -Method Put -Body $putBody

# Output the response
Write-Output "PUT Response:"
$putResponse
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
    scope         = "6a8b4b39-c021-437c-b060-5a14a3fd65f3/.default" # Scope for Verified ID Admin API
}

# Request the token
$response = Invoke-RestMethod -Uri $tokenUrl -Method Post -Body $body -ContentType "application/x-www-form-urlencoded"

# Extract the bearer token
$bearerToken = $response.access_token

# Define the API endpoint for listing authorities
$apiUrl = "https://verifiedid.did.msidentity.com/v1.0/verifiableCredentials/authorities"

# Define the headers
$headers = @{
    "Authorization" = "Bearer $bearerToken"
    "Content-Type"  = "application/json"
}

# Make the GET request to list authorities
$response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get

# Extract and list the authority IDs
$authorityIds = $response.value | ForEach-Object { $_.id }
Write-Output "Authority IDs:"
$authorityIds
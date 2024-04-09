# Get the infomation from the Azure AD app registration
$ClientID = "[yourClientId]"
$ClientSecret = "[yourClientSecret]"
$TenantID = "[yourTenantId]"

# Define the API endpoint for the inbound provisioning - Can be found on the provisioning configuration page in the Azure portal
$InboundProvisioningAPIEndpoint = ""

# Define the location of the JSON file to upload
$JsonContent = @"
{
    "schemas": ["urn:ietf:params:scim:api:messages:2.0:BulkRequest"],
    "Operations": [
        {
            "method": "POST",
            "bulkId": "897401c2-2de4-4b87-a97f-c02de3bcfc61",
            "path": "/Users",
            "data": {
                "schemas": ["urn:ietf:params:scim:schemas:core:2.0:User",
                "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User"],
                "externalId": "701984",
                "userName": "dw@ducktales.com",
                "name": {
                    "formatted": "Darkwing Duck",
                    "familyName": "Duck",
                    "givenName": "Darkwing",
                    "middleName": ""
                },
                "displayName": "Darkwing Duck",
                "nickName": "DW",
                "emails": [
                    {
                        "value": "dw@ducktales.com",
                        "type": "work",
                        "primary": true
                    }
                ],
                "addresses": [
                    {
                        "type": "work",
                        "streetAddress": "537 Avian Way",
                        "locality": "St. Canard",
                        "region": "Calisota",
                        "postalCode": "",
                        "country": "USA",
                        "formatted": "537 Avian Way\nSt. Canard, Calisota, USA",
                        "primary": true
                    }
                ],
                "phoneNumbers": [
                    {
                        "value": "555-555-5555",
                        "type": "work"
                    }
                ],
                "userType": "The Masked Mallard",
                "title": "Terror that Flaps in the Night",
                "preferredLanguage": "en-US",
                "locale": "en-US",
                "timezone": "America/Los_Angeles",
                "active":true,
                "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User": {
                    "employeeNumber": "701984",
                    "costCenter": "999",
                    "organization": "Justice Ducks",
                    "division": "SHUSH",
                    "department": "Free Lance agents"
                }
            }
        }
    ],
    "failOnErrors": false
}
"@

$JsonPayload = $JsonContent | ConvertTo-Json

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
    Body        = ([System.Text.Encoding]::UTF8.GetBytes($JsonPayload))
    Verbose     = $true
}

# Send the JSON payload to the API-driven provisioning endpoint
$response = Invoke-RestMethod @bulkUploadParams

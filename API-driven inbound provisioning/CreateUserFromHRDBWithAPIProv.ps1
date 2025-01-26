#Modules
Import-Module SQLServer -Verbose 

# Shared Auth infomation
$TenantID = ""

#API-driven provisioning to on-premises Active Directory auth
$APIClientID = ""
$APISecret = ""
$InboundProvisioningAPIEndpoint = ""

#SQL authentication
$SQLClientID = ""
$SQLSecret = ""

$RequestToken = Invoke-RestMethod -Method POST `
    -Uri "https://login.microsoftonline.com/$TenantID/oauth2/token"`
    -Body @{ resource = "https://database.windows.net/"; grant_type = "client_credentials"; client_id = $SQLClientID; client_secret = $SQLSecret }`
    -ContentType "application/x-www-form-urlencoded"
$AccessToken = $RequestToken.access_token

#SQL server info (Server name, DB, Table)
$SQLServer = ""
$DBName = ""
$DBTableName = ""

# SQL query to get new employees
$SQLNewEmployeesQuery = "SELECT * FROM $DBTableName WHERE ValidFrom > '2024-05-14'"

$GetEmployees = Invoke-Sqlcmd -ServerInstance $SQLServer -Database $DBName -Query $SQLNewEmployeesQuery -AccessToken $AccessToken

Foreach($Newemployee in $GetEmployees)
{
    $JSONexternalId = $Newemployee.EmployeeId

    $JSONfirstName = $Newemployee.Name_FirstName
    $JSONlastName = $Newemployee.Name_LastName
    $JSONFullName = $Newemployee.Name_FullName
    $JSONNickName = $Newemployee.NickName
    $JSONNationalityId = $Newemployee.NationalityId
    $JSONLanguageId = $Newemployee.LanguageId
    $JSONOrganizationName = $Newemployee.OrganizationName
    $JSONTitle = $Newemployee.Title
    $JSONValidFrom = $Newemployee.ValidFrom

    $JsonContent = @"
{
	"schemas": ["urn:ietf:params:scim:api:messages:2.0:BulkRequest"],
    "Operations": [
    {
        "method": "POST",
        "bulkId": "701984",
        "path": "/Users",
        "data": {
            "schemas": ["urn:ietf:params:scim:schemas:core:2.0:User",
            "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User"],
            "externalId": "$JSONexternalId",
            "userName": "$JSONexternalId",
            "name": {
                "familyName": "$JSONlastName",
                "givenName": "$JSONfirstName"
            },
            "displayName": "$JSONFullName",
            "nickName": "$JSONNickName",
            "title": "$JSONtitle",
            "preferredLanguage": "$JSONLanguageId",
            "locale": "$JSONNationalityId",
            "active":true,
            "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User": {
                "employeeNumber": "$JSONexternalId",
                "organization": "Disney",
                "division": "$JSONdivision",
                "department": "$JSONOrganizationName"
            }
        },
        "urn:ietf:params:scim:schemas:extension:CustomExtensionName:2.0:User": {
          "extensionAttribute1": "$JSONValidFrom"
        }
    }
],
    "failOnErrors": null
}

"@

$JsonPayload = $JsonContent | ConvertTo-Json
 
# Code execution starts here
 
# Define the parameters for getting the access token
$tokenParams = @{
    Uri         = "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token"
    Method      = 'POST'
    Body        = @{
        client_id     = $APIClientID 
        scope         = 'https://graph.microsoft.com/.default'
        client_secret = $APISecret 
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
$response 

}

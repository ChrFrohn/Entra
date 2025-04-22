$User = "" # Object ID of the user in Entra ID
$LifeCycleWorkflowID = "" # ID of the lifecycle workflow

# Service Principal authentication
$ClientID = ""
$TenantID = ""
$ClientSecret = ""

# Authenticate to Microsoft Graph
$Body = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $ClientID
    Client_Secret = $ClientSecret
}

$Connection = Invoke-RestMethod `
    -Uri "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token" `
    -Method POST `
    -Body $Body

# Define the URL and headers for activating the lifecycle workflow
$Url = "https://graph.microsoft.com/v1.0/identityGovernance/lifecycleWorkflows/workflows/$LifeCycleWorkflowID/activate"
$Headers = @{
    "Content-Type" = "application/json"
    "Authorization" = "Bearer " + $Connection.access_token
}

# Define the body of the request
$Body = @{
    "Subjects" = @(
        @{ "Id" = $User }
    )
} | ConvertTo-Json

# Make the POST request to activate the lifecycle workflow
Invoke-RestMethod -Uri $Url -Headers $Headers -Method Post -Body $Body -Verbose

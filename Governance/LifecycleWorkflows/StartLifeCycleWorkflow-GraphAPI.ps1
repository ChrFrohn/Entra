$User = "" # Object ID of the user in Entra ID
$LifeCycleWorkflowID = "" # ID of the lifecycle workflow

# Service Principal authentication
$ClientID = ""
$TenantID = "" 
$ClientSecret = ""

$Body =  @{
    GrantType    = "client_credentials"
    Scope        = "https://graph.microsoft.com/.default"
    ClientId     = $ClientID 
    ClientSecret = $ClientSecret
}
 
$Connection = Invoke-RestMethod -Uri https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token -Method POST -Body $Body

$Headers = @{
    "Authorization" = "Bearer " + $Connection.AccessToken
    "Content-Type"  = "application/json"
}

# URL to activate the workflow
$ActivateWorkflowURL = "https://graph.microsoft.com/v1.0/identityGovernance/lifecycleWorkflows/workflows/$LifeCycleWorkflowID/activate"

# Body of the POST request
$RequestBody = @{
    Subjects = @(
        @{ Id = $User }
    )
} | ConvertTo-Json

# The request to activate the workflow
Invoke-RestMethod -Uri $ActivateWorkflowURL -Headers $Headers -Method Post -Body $RequestBody -ErrorAction Stop

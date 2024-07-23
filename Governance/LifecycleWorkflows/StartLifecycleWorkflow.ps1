param (
    [Parameter (Mandatory = $true)] 
    [string]$ObjecGUID #Users Active Directory SID
)

# Entra ID Goverance Lifecycle Workflow ID
$WorkflowId = "" 

# Authentification to AD
$ADUsername = ""
$ADpassword = ""
$SecurePassword = ConvertTo-SecureString -String $ADpassword -AsPlainText -Force
$ADCredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ADUsername , $SecurePassword

# Service Prinicipal
$ClientID = ""
$ClientSecret = ""
$TenantID = ""

# Microsoft Graph authentication
$body =  @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $ClientID
    Client_Secret = $ClientSecret
}
 
$connection = Invoke-RestMethod `
    -Uri https://login.microsoftonline.com/$tenantid/oauth2/v2.0/token `
    -Method POST `
    -Body $body
 
$GraphToken = $connection.access_token | ConvertTo-SecureString -AsPlainText -Force
Connect-MgGraph -AccessToken $GraphToken -Verbose

# Get user from AD
$ADuser = Get-ADUser -Identity $ObjecGUID -Credential $ADCredentials

# Get user from Entra ID
$User = Get-MgUser -UserId $ADuser.UserPrincipalName

# Initialize Entra ID Goverance Lifecycle Workflow // https://learn.microsoft.com/en-us/graph/api/identitygovernance-workflow-activate?view=graph-rest-1.0&tabs=powershell
$params = @{
    subjects = @(
    @{
            id = $User.Id # Entra ID users Object ID
     }
    )
}

Try
{
    Initialize-MgIdentityGovernanceLifecycleWorkflow -WorkflowId $WorkflowId -BodyParameter $params -verbose
}
Catch
{
    $ErrorMessage = $_.Exception.Message
    Write-Host $ErrorMessage
}

param (
    [Parameter (Mandatory = $true)] 
    [string]$DisplayName,

    [Parameter (Mandatory = $true)] 
    [string]$UPN
)

# Alias formated
$UserName = $UPN.Split("@")[0].ToLower() 

# Mailbox infomation
$PrimarySmtpAddress = "Contoso.com" # Sample: Youdomain.com - Contoso.com
$RemoteRoutingAddress = "Contoso.mail.onmicrosoft.com" # Sample: Youdomain.mail.onmicrosoft.com / Contoso.mail.onmicrosoft.com

# Auth information - Azure subscription / Tenant ID
$AzureSubscriptionID = "" # Azure subscription ID where the Hybrid Worker is located (VM)

# Connect to Azure -Managed ID (Madrid)
Connect-AzAccount -Identity -Subscription $AzureSubscriptionID | Out-Null

# Exchange on-premise Authentification
$ExchangeAdminUsername = "" # Exchange Admin username 
$ExchangeAdminPassword = "" # Exchange Admin Password
$ExchangeConnecionURI = "" # Sample "http://Exchangeservername.Domainname.com/PowerShell/"

$Password = ConvertTo-SecureString $Password -AsPlainText -Force
$ExchangeCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ExchangeAdminUsername, $ExchangeAdminPassword
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ExchangeConnecionURI -Authentication Kerberos -Credential $UserExchange

try 
{
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ExchangeConnecionURI -Authentication Kerberos -Credential $ExchangeCredential
    Import-PSSession $Session
} 
catch 
{
    Write-Error "Failed to connect to Exchange: $_"
    exit 1
}


# Enable mailbox
Try 
{
    Enable-RemoteMailbox $DisplayName -alias $UserName -PrimarySmtpAddress "$UserName@$PrimarySmtpAddress" -RemoteRoutingAddress "$UserName@$RemoteRoutingAddress" -verbose
} 
catch 
{
    Write-Error "Failed to enable remote mailbox: $_"
    exit 1
} 

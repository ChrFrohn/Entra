## To be edited for your needs:
#Microsoft Graph connection
$ClientID = ""
$TenantId = ""
$CertificateThumbprint = ""

#Mail settings
$MailAdress = "" #Email adress of the dist. list
$MailUsersObjectID = "" #ObjectID of the user sending the mail
$SaveToSentItems = "false" # Select false is you dont want the mail to be saved in the users sendt items, change to true if do.

#Mail template settings
#Subject + Heading text
$MailSubject = "Azure App reg secrets that is about to expire"
$Heading1 = "Azure App reg secrets that is about to expire"
$Heading2 = "Recommend steps is to create a new secret and delete the one that is expiring"

### The script - No edit beyond this point ###

#Connect to MS Graph
Connect-MgGraph -ClientID $ClientID -TenantId $TenantId -CertificateThumbprint $CertificateThumbprint

#Get all app regs. + current date
$AllAzureApps = Get-MgApplication -all:$True
$Date = Get-date

#Custom Function - Compose email + Send mail
Function SendMail
{
    $EmailContent = "
    <html>
    <head>
    <style type='text/css'>
    h1 {
        color: #8D8100;
        font-family: verdana;
        font-size: 18px;
    }
    h2 {
        color: #003c46;
        font-family: verdana;
        font-size: 14px;
    }
    body {
        color: #003c46;
        font-family: verdana;
        font-size: 12px;
    }
    </style>
    </head>
    <h1>$Heading1</h1>
    <h2>$Heading2</h2>
    <body>
    $EmailBody
    </body>
    </html>
"

$params = @{
	Message = @{
		Subject = $MailSubject
		Body = @{
			ContentType = "HTML"
			Content = $EmailContent
		}
		ToRecipients = @(
			@{
				EmailAddress = @{
					Address = $MailAdress
				}
			}
		)
		
	}
	SaveToSentItems = $SaveToSentItems
}

#A UPN can also be used as -UserId.
Send-MgUserMail -UserId $MailUsersObjectID  -BodyParameter $params

}

Foreach ($AzureApp in $AllAzureApps)
{
    $AllSecrets = $AzureApp.PasswordCredentials
    $AllCerts = $AllAzureApps.KeyCredentials
    $AzureAppOwners = Get-MgApplicationOwner -ApplicationId $AzureApp.ID

    Foreach($Secret in $AllSecrets)
    {
        #Check if secret is 30 days from expiring
        if($Secret.EndDateTime -lt $Date.AddDays(30))
        {
            #Collect information about the Azure App reg and the secret
            $AzureAppDisplayName = $AzureApp.DisplayName
            $AzureAppOwnersDisplayname = Foreach($Owner in $AzureAppOwners) {Get-MgUser -UserId $Owner.Id | Select-Object DisplayName, Mail }#Gets the owerns displayname and email
            $AzureOwnerName = $AzureAppOwnersDisplayname.DisplayName
            $SecretDisplayName = $Secret.DisplayName
            $SecretEndDate = $Secret.EndDateTime
            $Link = "https://portal.azure.com/#blade/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/Overview/appId/"+$AzureApp.AppId

            #Array that adds every secret that is expired or is about to expire            
            $EmailBody += "</br>" + "<b>Azure app reg navn:</b> $AzureAppDisplayName" + "<br>" + "Secret Displayname: $SecretDisplayName" + "<br>" + "Secret end date: $SecretEndDate" + " <br> " + "Secret link: $Link" + "<br>" + "Owner(s): $AzureOwnerName" + "</br>"

        }
    }
   
}

#Send the email to the distrubtion list. - This is a custom function
SendMail

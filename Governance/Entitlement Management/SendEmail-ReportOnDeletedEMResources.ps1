# Find deleted resources in Catalogs and send email report
# Checks for deleted groups, applications, and SharePoint sites

## To be edited for your needs:
# Mail settings
$MailAddress = "" # Email address of the recipient or distribution list
$MailUsersObjectID = "" # ObjectID of the user(mailbox) sending the mail
$SaveToSentItems = "false" # Select false if you don't want the mail to be saved in the user's sent items, change to true if you do

# Mail template settings
# Subject + Heading text
$MailSubject = "Deleted Resources in Entitlement Management Catalogs"
$Heading1 = "Deleted Resources Found in Catalogs"
$Heading2 = "The following resources are still in catalogs but have been deleted from Entra ID or SharePoint online"

### The script - No edit beyond this point ###

# Connect to MS Graph using Managed Identity
Connect-MgGraph -Identity

# Get all catalogs
$Catalogs = Get-MgEntitlementManagementCatalog -All

$AllDeletedResources = @()

Write-Output "Checking catalogs for deleted resources..."

foreach ($catalog in $Catalogs) 
{
    $catalogResources = Get-MgEntitlementManagementCatalogResource -AccessPackageCatalogId $catalog.Id -All
    
    foreach ($resource in $catalogResources) 
    {
        $OriginSystem = $resource.OriginSystem
        $OriginId = $resource.OriginId
        $DisplayName = $resource.DisplayName
        $IsDeleted = $false
        $ResourceType = ""
        
        # Check if Group still exists
        if ($OriginSystem -eq "AadGroup") 
        {
            $ResourceType = "Group"
            try 
            {
                $null = Get-MgGroup -GroupId $OriginId -ErrorAction Stop
            }
            catch 
            {
                $IsDeleted = $true
            }
        }
        # Check if Application still exists
        elseif ($OriginSystem -eq "AadApplication") 
        {
            $ResourceType = "Application"
            try 
            {
                $null = Get-MgServicePrincipal -ServicePrincipalId $OriginId -ErrorAction Stop
            }
            catch 
            {
                $IsDeleted = $true
            }
        }
        elseif ($OriginSystem -eq "SharePointOnline") 
        {
            $ResourceType = "SharePoint Online Site"
            # Check if SharePoint site still exists
            try 
            {
                $null = Get-MgSite -SiteId $OriginId -ErrorAction Stop
            }
            catch 
            {
                $IsDeleted = $true
            }
        }
        
        if ($IsDeleted) 
        {
            $AllDeletedResources += [PSCustomObject]@{
                Catalog      = $catalog.DisplayName
                CatalogId    = $catalog.Id
                ResourceType = $ResourceType
                ResourceName = $DisplayName
                OriginId     = $OriginId
                OriginSystem = $OriginSystem
                ResourceId   = $resource.Id
            }
            
            Write-Output "Found deleted resource: $DisplayName ($ResourceType) in $($catalog.DisplayName)"
        }
    }
}

# Compose email + Send mail
Function SendMail
{
    param($EmailBody)
    
    $EmailContent = "
    <html>
    <head>
    <style type='text/css'>
    h1 {
        color: #4E6B60;
        font-family: verdana;
        font-size: 18px;
    }
    h2 {
        color: #003C46;
        font-family: verdana;
        font-size: 14px;
    }
    body {
        color: #003C46;
        font-family: verdana;
        font-size: 12px;
    }
    table {
        border-collapse: collapse;
        width: 100%;
        margin-top: 10px;
    }
    th {
        background-color: #003C46;
        color: white;
        padding: 8px;
        text-align: left;
        border: 1px solid #A0A08D;
    }
    td {
        padding: 8px;
        border: 1px solid #A0A08D;
    }
    tr:nth-child(even) {
        background-color: #DDDDCB;
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
                        Address = $MailAddress
                    }
                }
            )
        }
        SaveToSentItems = $SaveToSentItems
    }

    # A UPN can also be used as -UserId
    Send-MgUserMail -UserId $MailUsersObjectID -BodyParameter $params
    Write-Output "Email sent successfully to $MailAddress"
}

# Build email body
if ($AllDeletedResources.Count -gt 0) 
{
    Write-Output "`nTotal deleted resources found: $($AllDeletedResources.Count)"
    
    # Display summary by resource type
    Write-Output "`nDeleted Resources Summary:"
    $Summary = $AllDeletedResources | Group-Object ResourceType
    $Summary | ForEach-Object {
        Write-Output "  • $($_.Name): $($_.Count) resources"
    }
    
    # Build HTML email body
    $EmailBody = "<p><b>Total deleted resources found: $($AllDeletedResources.Count)</b></p>"
    
    # Add summary section
    $EmailBody += "<h3>Summary by Resource Type:</h3><ul>"
    $Summary | ForEach-Object {
        $EmailBody += "<li><b>$($_.Name):</b> $($_.Count) resources</li>"
    }
    $EmailBody += "</ul>"
    
    # Add detailed table
    $EmailBody += "<table><tr><th>Catalog</th><th>Resource Type</th><th>Resource Name</th><th>Origin ID</th></tr>"
    
    foreach ($resource in $AllDeletedResources) 
    {
        $EmailBody += "<tr>"
        $EmailBody += "<td>$($resource.Catalog)</td>"
        $EmailBody += "<td>$($resource.ResourceType)</td>"
        $EmailBody += "<td>$($resource.ResourceName)</td>"
        $EmailBody += "<td>$($resource.OriginId)</td>"
        $EmailBody += "</tr>"
    }
    
    $EmailBody += "</table>"
    
    # Send the email
    SendMail -EmailBody $EmailBody
} 
else 
{
    Write-Output "`nNo deleted resources found. No email will be sent."
}

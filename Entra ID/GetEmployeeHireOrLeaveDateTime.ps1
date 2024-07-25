# UPN or Object ID of the user 
$ObjectId = ""

# Service Principal authentication
$ClientID = ""
$TenantID = "" 
$ClientSecret = ""

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

$headers = @{
    "Authorization" = "Bearer " + $connection.access_token
    }

# URL that Get's the users properties / Requries User.readAll
$MSGraphURL = "https://graph.microsoft.com/v1.0/users/${ObjectId}?`$select=employeeHireDate,employeeLeaveDateTime,EmployeeOrgData"        

# The request to get teh users properties
$Response = Invoke-RestMethod -Uri $MSGraphURL -Headers $headers -Method Get -ErrorAction Stop 

# Output of values
$Response.employeeHireDate
$Response.employeeLeaveDateTime
$Response.employeeOrgData

# Import the SqlServer module
Import-Module SqlServer

# API Auth and GET
$baseURL = "https://hrsystem.com/"
$employeeEndpoint = "$baseURL/api/Employees"
$UserName = ""
$Password = ""

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))

$headers = @{
    Authorization = "Basic $base64AuthInfo"
    "Content-Type" = "application/json; charset=utf-8"
}
$response = Invoke-RestMethod -Uri $employeeEndpoint -Method Get -Headers $headers

# SQL Auth
$SQLClientID = ""
$SQLSecret = ""
$TenantID = ""

$RequestToken = Invoke-RestMethod -Method POST `
    -Uri "https://login.microsoftonline.com/$TenantID/oauth2/token"`
    -Body @{ resource = "https://database.windows.net/"; grant_type = "client_credentials"; client_id = $SQLClientID; client_secret = $SQLSecret }`
    -ContentType "application/x-www-form-urlencoded"
$AccessToken = $RequestToken.access_token

# SQL server info
$SQLServer = ""
$DBName = ""
$DBTable = ""

foreach ($employee in $response) {
    # Create the SQL command
    $ImportQuery = @"
INSERT INTO $DBTable
(
    [EmployeeId], 
    [Name_FirstName], 
    [Name_MiddleName], 
    [Name_LastName], 
    [Name_FullName], 
    [Salutation], 
    [NickName], 
    [NationalityId], 
    [LanguageId], 
    [Email], 
    [Gender], 
    [BirthDate], 
    [RowNumber], 
    [CreatedBy], 
    [CreatedDateTime], 
    [ModifiedBy], 
    [ModifiedDateTime], 
    [VersionStamp], 
    [Active], 
    [Initials], 
    [LocationId], 
    [Location_Name], 
    [Office], 
    [ManagerId], 
    [Manager_Name], 
    [OrganizationId], 
    [OrganizationName], 
    [JobId], 
    [Job_Description], 
    [JobTypeId], 
    [JobType_Description], 
    [Title], 
    [ValidFrom], 
    [ValidTo], 
    [Released], 
    [HiredDate], 
    [TerminatedDate]
)
VALUES
(
    '$($employee.EmployeeId)', 
    '$($employee.Name_FirstName)', 
    '$($employee.Name_MiddleName)', 
    '$($employee.Name_LastName)', 
    '$($employee.Name_FullName)', 
    '$($employee.Salutation)', 
    '$($employee.NickName)', 
    '$($employee.NationalityId)', 
    '$($employee.LanguageId)', 
    '$($employee.Email)', 
    '$($employee.Gender)', 
    '$($employee.BirthDate)', 
    '$($employee.RowNumber)', 
    '$($employee.CreatedBy)', 
    '$($employee.CreatedDateTime)', 
    '$($employee.ModifiedBy)', 
    '$($employee.ModifiedDateTime)', 
    '$($employee.VersionStamp)', 
    '$($employee.Active)', 
    '$($employee.Initials)', 
    '$($employee.LocationId)', 
    '$($employee.Location_Name)', 
    '$($employee.Office)', 
    '$($employee.ManagerId)', 
    '$($employee.Manager_Name)', 
    '$($employee.OrganizationId)', 
    '$($employee.OrganizationName)', 
    '$($employee.JobId)', 
    '$($employee.Job_Description)', 
    '$($employee.JobTypeId)', 
    '$($employee.JobType_Description)', 
    '$($employee.Title)', 
    '$($employee.ValidFrom)', 
    '$($employee.ValidTo)', 
    '$($employee.Released)', 
    '$($employee.HiredDate)', 
    '$($employee.TerminatedDate)'
)
"@

    # Execute the command
    Invoke-Sqlcmd -ServerInstance $serverName -Database $databaseName -Query $ImportQuery -AccessToken $AccessToken
}

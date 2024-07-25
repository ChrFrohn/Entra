# UPN or Object ID of the user 
$ObjectId = ""

# Import Module
Import-Module Microsoft.Graph.Users

# Microsoft Graph Permission scope
$Scopes = "User.Read.All", "User-LifeCycleInfo.Read.All"

# Connect to the Microsoft Graph
Connect-MgGraph -Scopes $Scopes

# Get the users 
$MgUser = Get-MgUser -UserId $ObjectId -Property employeeHireDate,employeeLeaveDateTime,EmployeeOrgData

$MgUser.EmployeeHireDate
$MgUser.EmployeeLeaveDateTime
$MgUser.EmployeeOrgData.CostCenter
$MgUser.EmployeeOrgData.Division

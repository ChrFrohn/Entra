# Read Me Please

All code in this folder is related to working with API-driven inbound provisioning.

I'll suggest reading the following blog post as it explains how the code is used:

[API-Driven User Provisioning Blog Posts](https://www.christianfrohn.dk/tag/api-driven-user-provisioning/)

## Table of Contents

### JSON
- [JSONpayload-withExtAttribute.json](https://github.com/ChrFrohn/Entra-ID/blob/main/API-driven%20inbound%20provisioning/JSONpayload-withExtAttribute.json) - JSON payload file to update custom attribute mapping (Sample is extensionAttribute1)
- [JSONpayload-withmanager.json](https://github.com/ChrFrohn/Entra-ID/blob/main/API-driven%20inbound%20provisioning/JSONpayload-withmanager.json) - JSON payload file to update manager of a user in Active Directory
- [JSONpayload.json](https://github.com/ChrFrohn/Entra-ID/blob/main/API-driven%20inbound%20provisioning/JSONpayload.json) - Default JSON payload to create/update a user

### PowerShell
- [UploadUserDataToTheInboundProvisioningAPI-WithJSON.ps1](https://github.com/ChrFrohn/Entra-ID/blob/main/API-driven%20inbound%20provisioning/UploadUserDataToTheInboundProvisioningAPI-WithJSON.ps1) - Sample to send JSON to the API-driven inbound provisioning service
- [UploadUserDataToTheInboundProvisioningAPI.ps1](https://github.com/ChrFrohn/Entra-ID/blob/main/API-driven%20inbound%20provisioning/UploadUserDataToTheInboundProvisioningAPI.ps1) - Sample to send payload (without JSON payload in it)
- [CreateUserFromHRDBWithAPIProv.ps1](https://github.com/ChrFrohn/Entra-ID/blob/main/API-driven%20inbound%20provisioning/CreateUserFromHRDBWithAPIProv.ps1) - Script to create a user from HR database with API provisioning

### SQL
- [CreateAndInsertData-API-Driven-Sample.SQL](https://github.com/ChrFrohn/Entra-ID/blob/main/API-driven%20inbound%20provisioning/CreateAndInsertData-API-Driven-Sample.SQL) - SQL script to create and insert data for API-driven provisioning
- [CreateTableForAPI-Driven.sql](https://github.com/ChrFrohn/Entra-ID/blob/main/API-driven%20inbound%20provisioning/CreateTableForAPI-Driven.sql) - SQL script to create table for API-driven provisioning

### KQL
- [GetAllCreatedUserFromAPIDrivenUserProv.kql](https://github.com/ChrFrohn/Entra-ID/blob/main/API-driven%20inbound%20provisioning/GetAllCreatedUserFromAPIDrivenUserProv.kql) - KQL query to get all created users from API-driven user provisioning
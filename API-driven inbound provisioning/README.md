# Read me please

All code in this folder are realated to working with API-driven inbound provisioning

I'll suggest reading the following blog post as they explain how the code is used.

https://www.christianfrohn.dk/tag/api-driven-user-provisioning/

### Table of content:

#### JSON
- [JSONpayload-withExtAttribute.json - JSON payload file to update custom attribute mapping (Sample is extensionAttribute1)](https://github.com/ChrFrohn/Entra-ID/blob/main/API-driven%20inbound%20provisioning/JSONpayload-withExtAttribute.json)
- [JSONpayload-withmanager.json - JSON payload file to update manager of a user in Active Diretory](https://github.com/ChrFrohn/Entra-ID/blob/main/API-driven%20inbound%20provisioning/JSONpayload-withmanager.json)
[JSONpayload.json - Default JSON payload to create/Update a user](https://github.com/ChrFrohn/Entra-ID/blob/main/API-driven%20inbound%20provisioning/JSONpayload.json)

#### PowerShell
[UploadUserDataToTheInboundProvisioningAPI-WithJSON.ps1 - Sample to send JSON to the API-driven inbound provisioning service](https://github.com/ChrFrohn/Entra-ID/blob/main/API-driven%20inbound%20provisioning/UploadUserDataToTheInboundProvisioningAPI-WithJSON.ps1)
[UploadUserDataToTheInboundProvisioningAPI.ps1 - Sample to send payload (But with out JSON payload in it)](https://github.com/ChrFrohn/Entra-ID/blob/main/API-driven%20inbound%20provisioning/UploadUserDataToTheInboundProvisioningAPI.ps1)
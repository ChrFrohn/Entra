# Read me please

All code in this folder are realated to working with API-driven inbound provisioning

I'll suggest reading the following blog post as they explain how the code is used.

https://www.christianfrohn.dk/tag/api-driven-user-provisioning/

### Table of content:

JSONpayload-withExtAttribute.json / JSON payload file to update custom attribute mapping (Sample is extensionAttribute1)
JSONpayload-withmanager.json / JSON payload file to update manager of a user in Active Diretory
JSONpayload.json / Default JSON payload to create/Update a user

UploadUserDataToTheInboundProvisioningAPI-WithJSON.ps1 / Sample to send JSON to the API-driven inbound provisioning service
UploadUserDataToTheInboundProvisioningAPI.ps1 / Sample to send payload (But with out JSON payload in it)
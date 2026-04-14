# Entra Repository

Welcome to the Entra repository! This repository contains code related to my everyday work in Entra. Some of the code is associated with blog posts on my blog: [Christianfrohn.dk](https://www.christianfrohn.dk/).

## Disclaimer

The code and documentation in this repository are provided "as is" without warranty of any kind, either express or implied, including but not limited to the implied warranties of merchantability and fitness for a particular purpose. Use at your own risk.

## Table of Contents


### API-driven Inbound Provisioning
- [API-driven Inbound Provisioning](https://github.com/ChrFrohn/Entra/tree/main/API-driven%20inbound%20provisioning)

### Entra ID
- [Entra ID](https://github.com/ChrFrohn/Entra/tree/main/Entra%20ID)

### Global Secure Access
- [Global Secure Access](https://github.com/ChrFrohn/Entra/tree/main/Global%20Secure%20Access)
  - [Create-GSAEnterpriseAppsFromCSV.ps1](https://github.com/ChrFrohn/Entra/blob/main/Global%20Secure%20Access/Create-GSAEnterpriseAppsFromCSV.ps1)
    - Blog post: [Automating Web Application Creation in Global Secure Access Using PowerShell](https://www.christianfrohn.dk/2025/10/21/automating-web-application-creation-in-global-secure-access-using-powershell/)
  - [CreateGSAEnterpriseAppsForRDP.ps1](https://github.com/ChrFrohn/Entra/blob/main/Global%20Secure%20Access/CreateGSAEnterpriseAppsForRDP.ps1)
    - Blog post: [Bulk creating Global Secure Access Enterprise applications using PowerShell](https://www.christianfrohn.dk/2025/02/20/bulk-creating-global-secure-access-enterprise-applications-using-powershell/)
  - [DeleteGSAEnterpriseApps.ps1](https://github.com/ChrFrohn/Entra/blob/main/Global%20Secure%20Access/DeleteGSAEnterpriseApps.ps1)
  - [Get-PrivateConnectors.ps1](https://github.com/ChrFrohn/Entra/blob/main/Global%20Secure%20Access/Get-PrivateConnectors.ps1)
  - [Remove-AllGSAAppsAndGroups.ps1](https://github.com/ChrFrohn/Entra/blob/main/Global%20Secure%20Access/Remove-AllGSAAppsAndGroups.ps1)

### Entra ID Governance
- [Entra ID Governance](https://github.com/ChrFrohn/Entra/tree/main/Governance)
  - [Entitlement Management](https://github.com/ChrFrohn/Entra/tree/main/Governance/Entitlement%20Management)
    - [Add-GroupToAccessPackage.ps1](https://github.com/ChrFrohn/Entra/blob/main/Governance/Entitlement%20Management/Add-GroupToAccessPackage.ps1)
    - [AddApplicationToAccessPackage.ps1](https://github.com/ChrFrohn/Entra/blob/main/Governance/Entitlement%20Management/AddApplicationToAccessPackage.ps1)
    - [AddCustomExtensionParamterToPolicy.ps1](https://github.com/ChrFrohn/Entra/blob/main/Governance/Entitlement%20Management/AddCustomExtensionParamterToPolicy.ps1)
    - [AddEntraRoleToAccessPackage.ps1](https://github.com/ChrFrohn/Entra/blob/main/Governance/Entitlement%20Management/AddEntraRoleToAccessPackage.ps1)
    - [AddGroupToAccessPackage.ps1](https://github.com/ChrFrohn/Entra/blob/main/Governance/Entitlement%20Management/AddGroupToAccessPackage.ps1)
    - [AddGroupToCatalog.ps1](https://github.com/ChrFrohn/Entra/blob/main/Governance/Entitlement%20Management/AddGroupToCatalog.ps1)
    - [AddSharePointOnlineSiteToAccessPackage.ps1](https://github.com/ChrFrohn/Entra/blob/main/Governance/Entitlement%20Management/AddSharePointOnlineSiteToAccessPackage.ps1)
    - [AddSharePointOnlineSiteToCatalog.ps1](https://github.com/ChrFrohn/Entra/blob/main/Governance/Entitlement%20Management/AddSharePointOnlineSiteToCatalog.ps1)
    - Blog post: [Add Resources to an Access package with PowerShell](https://www.christianfrohn.dk/2025/01/30/add-resources-to-an-access-package-with-powershell/)
    - Blog post: [Create Access Packages in Entra ID Governance with PowerShell](https://www.christianfrohn.dk/2025/01/09/create-access-packages-in-entra-id-governance-with-powershell/)
      - [CreateAccessPackage-AutoPolicyAndExtension.ps1](https://github.com/ChrFrohn/Entra/blob/main/Governance/Entitlement%20Management/CreateAccessPackage-AutoPolicyAndExtension.ps1)
      - [CreateAccessPackage-Basic.ps1](https://github.com/ChrFrohn/Entra/blob/main/Governance/Entitlement%20Management/CreateAccessPackage-Basic.ps1)
      - [CreateAccessPackage-Template.ps1](https://github.com/ChrFrohn/Entra/blob/main/Governance/Entitlement%20Management/CreateAccessPackage-Template.ps1)
    - [CreateAccessPackagePolicy-AutoAssign.ps1](https://github.com/ChrFrohn/Entra/blob/main/Governance/Entitlement%20Management/CreateAccessPackagePolicy-AutoAssign.ps1)
    - [CreateAccessPackagePolicy-Request.ps1](https://github.com/ChrFrohn/Entra/blob/main/Governance/Entitlement%20Management/CreateAccessPackagePolicy-Request.ps1)
    - [CreateAccessPackagePolicy-RequestsForSpecifGroup.ps1](https://github.com/ChrFrohn/Entra/blob/main/Governance/Entitlement%20Management/CreateAccessPackagePolicy-RequestsForSpecifGroup.ps1)
    - [Export-AccessPackageRequestsExtended.ps1](https://github.com/ChrFrohn/Entra/blob/main/Governance/Entitlement%20Management/Export-AccessPackageRequestsExtended.ps1)
    - Blog post: [Finding and Cleaning Up Deleted Resources in Entra ID Access Packages](https://www.christianfrohn.dk/2025/11/05/finding-and-cleaning-up-deleted-resources-in-entra-id-access-packages/)
      - [Find-DeletedEMCatalogResources.ps1](https://github.com/ChrFrohn/Entra/blob/main/Governance/Entitlement%20Management/Find-DeletedEMCatalogResources.ps1)
      - [Find-DeletedEMResourcesInAccessPackage.ps1](https://github.com/ChrFrohn/Entra/blob/main/Governance/Entitlement%20Management/Find-DeletedEMResourcesInAccessPackage.ps1)
      - [Find-OrphanedAccessPackageResources.ps1](https://github.com/ChrFrohn/Entra/blob/main/Governance/Entitlement%20Management/Find-OrphanedAccessPackageResources.ps1)
      - [Remove-DeletedEMResources.ps1](https://github.com/ChrFrohn/Entra/blob/main/Governance/Entitlement%20Management/Remove-DeletedEMResources.ps1)
      - [SendEmail-ReportOnDeletedEMResources.ps1](https://github.com/ChrFrohn/Entra/blob/main/Governance/Entitlement%20Management/SendEmail-ReportOnDeletedEMResources.ps1)
    - [Find-MissingAccessPackageApprovers.ps1](https://github.com/ChrFrohn/Entra/blob/main/Governance/Entitlement%20Management/Find-MissingAccessPackageApprovers.ps1)
      - Blog post: [How to find deleted Approvers in Entra ID Governance Access Packages Using PowerShell](https://www.christianfrohn.dk/2025/08/14/how-to-find-and-fix-missing-approvers-in-entra-id-governance-access-packages-using-powershell/)
    - Blog post: [Finding Resources in Microsoft Entra ID Governance Access Packages using PowerShell](https://www.christianfrohn.dk/2025/05/08/finding-resources-in-microsoft-entra-id-governance-access-packages-using-powershell/)
      - [FindApplicationInAccessPackages.ps1](https://github.com/ChrFrohn/Entra/blob/main/Governance/Entitlement%20Management/FindApplicationInAccessPackages.ps1)
      - [FindGroupInAccessPackages.ps1](https://github.com/ChrFrohn/Entra/blob/main/Governance/Entitlement%20Management/FindGroupInAccessPackages.ps1)
      - [FindSharePointOnlineSiteInAccessPackage.ps1](https://github.com/ChrFrohn/Entra/blob/main/Governance/Entitlement%20Management/FindSharePointOnlineSiteInAccessPackage.ps1)
    - [GetInfoToAccessPackage.ps1](https://github.com/ChrFrohn/Entra/blob/main/Governance/Entitlement%20Management/GetInfoToAccessPackage.ps1)
    - [GetSpecificCatalog.ps1](https://github.com/ChrFrohn/Entra/blob/main/Governance/Entitlement%20Management/GetSpecificCatalog.ps1)
    - [Manage AD Groups](https://github.com/ChrFrohn/Entra/tree/main/Governance/Entitlement%20Management/Manage%20AD%20Groups)
      - Blog post: [A Way to Manage On-Prem AD Group Memberships Using Entra ID Governance](https://www.christianfrohn.dk/2025/04/23/a-way-to-manage-on-prem-ad-group-memberships-using-entra-id-governance/)
    - [Manage Distribution list](https://github.com/ChrFrohn/Entra/tree/main/Governance/Entitlement%20Management/Manage%20Distribution%20list)
      - Blog post: [A way to handle distributions lists with Entra ID Governance](https://www.christianfrohn.dk/2024/12/11/a-way-to-handle-distributions-lists-with-entra-id-governance/)
    - [ReprocessUsersAccessPackageAssigments.ps1](https://github.com/ChrFrohn/Entra/blob/main/Governance/Entitlement%20Management/ReprocessUsersAccessPackageAssigments.ps1)
      - Blog post: [Automate user Reprocess in Entra ID Governance Entitlement Management using Sentinel and PowerShell](https://www.christianfrohn.dk/2025/01/22/automate-user-reprocess-in-entra-id-governance-entitlement-management-using-sentinel-and-powershell/)
  - [Lifecycle Workflows](https://github.com/ChrFrohn/Entra/tree/main/Governance/Lifecycle%20Workflows)
    - [Assign Teams Phonenumber](https://github.com/ChrFrohn/Entra/tree/main/Governance/Lifecycle%20Workflows/Assign%20Teams%20Phonenumber)
      - Blog post: [Assign Teams Phone number to users with Lifecycle Workflows in Entra ID Governance](https://www.christianfrohn.dk/2024/06/27/assign-teams-phone-number-to-users-with-lifecycle-workflows-in-entra-id-governance/)
    - [CreateUserMailbox.ps1](https://github.com/ChrFrohn/Entra/blob/main/Governance/Lifecycle%20Workflows/CreateUserMailbox.ps1)
      - Blog post: [Create a user mailbox using Lifecycle Workflows in Microsoft Entra ID Governance](https://www.christianfrohn.dk/2024/06/14/create-a-user-mailbox-using-lifecycle-workflows-in-microsoft-entra-id-governance/)
    - Blog post: [Start Lifecycle Workflow in Entra ID Governance with PowerShell](https://www.christianfrohn.dk/2024/08/28/start-lifecycle-workflow-in-entra-id-governance-with-powershell/)
      - [StartLifecycleWorkflow.ps1](https://github.com/ChrFrohn/Entra/blob/main/Governance/Lifecycle%20Workflows/StartLifecycleWorkflow.ps1)
      - [StartLifeCycleWorkflow-GraphAPI.ps1](https://github.com/ChrFrohn/Entra/blob/main/Governance/Lifecycle%20Workflows/StartLifeCycleWorkflow-GraphAPI.ps1)
      - [StartLifecycleWorkflow-PoshModule.ps1](https://github.com/ChrFrohn/Entra/blob/main/Governance/Lifecycle%20Workflows/StartLifecycleWorkflow-PoshModule.ps1)
    - [UpdateUserInSPO-UsingMSGraph.ps1](https://github.com/ChrFrohn/Entra/blob/main/Governance/Lifecycle%20Workflows/UpdateUserInSPO-UsingMSGraph.ps1)

### Verified ID
- [Verified ID](https://github.com/ChrFrohn/Entra/tree/main/Verified%20ID)
  - [Get-VerifiedIdAuthorities.ps1](https://github.com/ChrFrohn/Entra/blob/main/Verified%20ID/Get-VerifiedIdAuthorities.ps1)
  - [Set-VerifiedIdAuthority.ps1](https://github.com/ChrFrohn/Entra/blob/main/Verified%20ID/Set-VerifiedIdAuthority.ps1)

### Workload ID
- [Workload ID](https://github.com/ChrFrohn/Entra/tree/main/Workload%20ID)
  - [AddGraphPermissionsToManagedId.ps1](https://github.com/ChrFrohn/Entra/blob/main/Workload%20ID/AddGraphPermissionsToManagedId.ps1)
  - [GetExpiringSecrets.ps1](https://github.com/ChrFrohn/Entra/blob/main/Workload%20ID/GetExpiringSecrets.ps1)

## Contact

For any questions or feedback, feel free to reach out via [LinkedIn](https://www.linkedin.com/in/frohn/).
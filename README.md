# Entra Repository

Welcome to the Entra repository! This repository contains code related to my everyday work in Entra. Some of the code is associated with blog posts on my blog: [Christianfrohn.dk](https://www.christianfrohn.dk/).

## Disclaimer

The code and documentation in this repository are provided "as is" without warranty of any kind, either express or implied, including but not limited to the implied warranties of merchantability and fitness for a particular purpose. Use at your own risk.

## Table of Contents

### Entra ID
- [Entra ID](https://github.com/ChrFrohn/Entra/tree/main/Entra%20ID)

### API-driven Inbound Provisioning
- [API-driven Inbound Provisioning](Entra/API-driven%20inbound%20provisioning)

### Entra ID Governance
- [Entra ID Governance](https://github.com/ChrFrohn/Entra/tree/main/Governance)
  - [Entitlement Management](Entra/Governance/Entitlement%20Management)
    - [AddApplicationToAccessPackage.ps1](Entra/Governance/Entitlement%20Management/AddApplicationToAccessPackage.ps1)
    - [AddGroupToAccessPackage.ps1](Entra/Governance/Entitlement%20Management/AddGroupToAccessPackage.ps1)
    - [AddSPOSiteToAccessPackage.ps1](Entra/Governance/Entitlement%20Management/AddSPOSiteToAccessPackage.ps1)
    - [Manage Distribution list](Entra/Governance/Entitlement%20Management/Manage%20Distribution%20list)
      - Blog post: [A way to handle distributions lists with Entra ID Governance](https://www.christianfrohn.dk/2024/12/11/a-way-to-handle-distributions-lists-with-entra-id-governance/)
    - [ReprocessUsersAccessPackageAssigments.ps1](Entra/Governance/Entitlement%20Management/ReprocessUsersAccessPackageAssigments.ps1)
      - Blog post: [Automate user Reprocess in Entra ID Governance Entitlement Management using Sentinel and PowerShell](https://www.christianfrohn.dk/2025/01/22/automate-user-reprocess-in-entra-id-governance-entitlement-management-using-sentinel-and-powershell/)
    - Blog post: [Create Access Packages in Entra ID Governance with PowerShell](https://www.christianfrohn.dk/2025/01/09/create-access-packages-in-entra-id-governance-with-powershell/)
      - [CreateAccessPackage-AutoPolicyAndExtension.ps1](Entra/Governance/Entitlement%20Management/CreateAccessPackage-AutoPolicyAndExtension.ps1)
      - [CreateAccessPackage-Basic.ps1](Entra/Governance/Entitlement%20Management/CreateAccessPackage-Basic.ps1)
      - [CreateAccessPackage-Template.ps1](Entra/Governance/Entitlement%20Management/CreateAccessPackage-Template.ps1)
  - [Lifecycle Workflows](https://github.com/ChrFrohn/Entra-ID/tree/main/Governance/LifecycleWorkflows)
    - [CreateUserMailbox.ps1](https://github.com/ChrFrohn/Entra-ID/blob/537e6f1cd6fa6bfabf57222b03586f930b9ef3a4/Governance/LifecycleWorkflows/CreateUserMailbox.ps1)
      - Blog post: [Create a user mailbox using Lifecycle Workflows in Microsoft Entra ID Governance](https://www.christianfrohn.dk/2024/06/14/create-a-user-mailbox-using-lifecycle-workflows-in-microsoft-entra-id-governance/)
    - [Assign Teams Phonenumber](https://github.com/ChrFrohn/Entra-ID/tree/main/Governance/LifecycleWorkflows/Assign%20Teams%20Phonenumber)
      - Blog post: [Assign Teams Phone number to users with Lifecycle Workflows in Entra ID Governance](https://www.christianfrohn.dk/2024/06/27/assign-teams-phone-number-to-users-with-lifecycle-workflows-in-entra-id-governance/)
    - [StartLifecycleWorkflow.ps1](https://github.com/ChrFrohn/Entra-ID/blob/main/Governance/LifecycleWorkflows/StartLifecycleWorkflow.ps1)
    - [StartLifeCycleWorkflow-GraphAPI.ps1](https://github.com/ChrFrohn/Entra-ID/blob/main/Governance/LifecycleWorkflows/StartLifeCycleWorkflow-GraphAPI.ps1)
    - [StartLifecycleWorkflow-PoshModule.ps1](https://github.com/ChrFrohn/Entra-ID/blob/main/Governance/LifecycleWorkflows/StartLifecycleWorkflow-PoshModule.ps1)
    - [Get-FailedLifecycleWorkflowsTasks-Details.kql](https://github.com/ChrFrohn/Entra-ID/blob/main/Governance/LifecycleWorkflows/Get-FailedLifecycleWorkflowsTasks-Details.kql)
    - [Get-FailedLifecycleWorkflowsTasks.kql](https://github.com/ChrFrohn/Entra-ID/blob/main/Governance/LifecycleWorkflows/Get-FailedLifecycleWorkflowsTasks.kql)

### Workload ID
- [Workload ID](https://github.com/ChrFrohn/Entra/tree/main/Workload%20ID)

## Blog Posts

### Entra ID Governance - Entitlement Management
- [A way to handle distributions lists with Entra ID Governance](https://www.christianfrohn.dk/2024/12/11/a-way-to-handle-distributions-lists-with-entra-id-governance/)
- [Automate user Reprocess in Entra ID Governance Entitlement Management using Sentinel and PowerShell](https://www.christianfrohn.dk/2025/01/22/automate-user-reprocess-in-entra-id-governance-entitlement-management-using-sentinel-and-powershell/)
- [Create Access Packages in Entra ID Governance with PowerShell](https://www.christianfrohn.dk/2025/01/09/create-access-packages-in-entra-id-governance-with-powershell/)
- [Monitoring access package delivery status in Entra ID Governance](https://www.christianfrohn.dk/2025/01/15/monitoring-access-package-delivery-status-in-entra-id-governance/)
- [Add resources to Access package with PowerShell](https://www.christianfrohn.dk/2025/01/23/add-resources-to-access-package-with-powershell/)
- [Managing User Photos Across Microsoft Services Using Microsoft Graph](https://www.christianfrohn.dk/2025/01/26/managing-user-photos-across-microsoft-services-using-microsoft-graph/)

### Entra ID Governance - Lifecycle Workflows
- [Create a user mailbox using Lifecycle Workflows in Microsoft Entra ID Governance](https://www.christianfrohn.dk/2024/06/14/create-a-user-mailbox-using-lifecycle-workflows-in-microsoft-entra-id-governance/)
- [Assign Teams Phone number to users with Lifecycle Workflows in Entra ID Governance](https://www.christianfrohn.dk/2024/06/27/assign-teams-phone-number-to-users-with-lifecycle-workflows-in-entra-id-governance/)
- [Start Lifecycle Workflow in Entra ID Governance with PowerShell](https://www.christianfrohn.dk/2024/08/28/start-lifecycle-workflow-in-entra-id-governance-with-powershell/)
- [Using Entra ID Governance and Sentinel to assure user alignment with HR data](https://www.christianfrohn.dk/2024/07/24/using-entra-id-governance-and-sentinel-to-assure-user-alignment-with-hr-data/)
- [How to run PowerShell scripts in Entra ID Governance Lifecycle Workflows](https://www.christianfrohn.dk/2024/06/06/how-to-run-powershell-scripts-in-entra-id-governance-lifecycle-workflows/)
- [Monitor Lifecycle Workflows status in Entra ID Governance](https://www.christianfrohn.dk/2024/05/31/monitor-lifecycle-workflows-status-in-entra-id-governance/)
- [Create onboarding Lifecycle Workflows using Microsoft Entra ID Governance](https://www.christianfrohn.dk/2024/05/24/create-onboarding-lifecycle-workflows-using-microsoft-entra-id-governance/)

### API-driven Inbound Provisioning
- [Using API-driven user provisioning with an Azure SQL database as a source of truth](https://www.christianfrohn.dk/2024/05/15/using-api-driven-user-provisioning-with-an-azure-sql-database-as-a-source-of-truth/)
- [Configure EmployeeHireDate and EmployeeLeaveDateTime in Active Directory to be used with Microsoft Entra ID Governance](https://www.christianfrohn.dk/2024/05/02/configure-employeehiredate-and-employeeleavedatetime-in-active-directory-to-be-used-with-microsoft-entra-id-governance/)
- [Modifying the attribute mapping in API-driven provisioning to on-premises Active Directory](https://www.christianfrohn.dk/2024/04/18/modifying-the-attribute-mapping-in-api-driven-provisioning-to-on-premises-active-directory/)
- [Getting started with API-driven Inbound User Provisioning to On-Premises AD](https://www.christianfrohn.dk/2024/04/10/getting-started-with-api-driven-inbound-user-provisioning-to-on-premises-ad/)
## Contact

For any questions or feedback, feel free to reach out via [Christianfrohn.dk](https://www.christianfrohn.dk/).
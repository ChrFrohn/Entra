# Read me

# Microsoft Entra - Governance - Entitlement Management

Contains code related to Microsoft Entra Entitlement Management in Microsoft Entra ID Governance

## Disclaimer

The code and documentation in this repository are provided "as is" without warranty of any kind, either express or implied, including but not limited to the implied warranties of merchantability and fitness for a particular purpose. Use at your own risk.

## Table of Contents

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
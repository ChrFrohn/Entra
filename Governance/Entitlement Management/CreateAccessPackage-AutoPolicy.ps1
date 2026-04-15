# Create an Access Package with an Auto Assignment Policy in Entra ID Governance Entitlement Management

Import-Module Microsoft.Graph.Identity.Governance

Connect-MgGraph -Scopes "EntitlementManagement.ReadWrite.All" -NoWelcome

# Access package parameters
$AccessPackageDisplayName = "" # Sample: "Department X"
$AccessPackageDescription = "" # Sample: "Department X Access Package"
$AccessPackageCatalogId = "" # Sample: "00000000-0000-0000-0000-000000000000"

# Auto assignment policy parameters
$AutoPolicyName = "" # Sample: "Auto policy"
$AutoPolicyDescription = "" # Sample: "Auto policy for department X"
$AutoAssignmentPolicyFilter = '' # Sample: '(user.department -eq "Department X")'

# Creating the access package

$AccessPackageParameters = @{
	displayName = $AccessPackageDisplayName
	description = $AccessPackageDescription
	isHidden = $false
	catalog = @{
		id = $AccessPackageCatalogId
	}
}

New-MgEntitlementManagementAccessPackage -BodyParameter $AccessPackageParameters
$NewAccessPackage = Get-MgEntitlementManagementAccessPackage -Filter "displayName eq '$AccessPackageDisplayName'"

# Creating the auto assignment policy

$AutoPolicyParameters = @{
	DisplayName = $AutoPolicyName
	Description = $AutoPolicyDescription
	AllowedTargetScope = "specificDirectoryUsers"
	SpecificAllowedTargets = @(
		@{
			"@odata.type" = "#microsoft.graph.attributeRuleMembers"
			description = $AutoPolicyDescription
			membershipRule = $AutoAssignmentPolicyFilter
		}
	)
	AutomaticRequestSettings = @{
		RequestAccessForAllowedTargets = $true
	}
	AccessPackage = @{
		Id = $NewAccessPackage.Id
	}
}

New-MgEntitlementManagementAssignmentPolicy -BodyParameter $AutoPolicyParameters

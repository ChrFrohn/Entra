# Create an Entitlement Management Assignment Policy with approval settings for an Access Package

Import-Module Microsoft.Graph.Identity.Governance

Connect-MgGraph -Scopes "EntitlementManagement.ReadWrite.All" -NoWelcome

# Auto assignment policy parameters
$AccessPackageId = "" # Sample: "00000000-0000-0000-0000-000000000000"
$AutoPolicyName = "" # Sample: "Auto policy"
$AutoPolicyDescription = "" # Sample: "Auto policy for department X"
$AutoAssignmentPolicyFilter = '' # Sample: '(user.department -eq "Department X")'

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
		Id = $AccessPackageId
	}
}

New-MgEntitlementManagementAssignmentPolicy -BodyParameter $AutoPolicyParameters

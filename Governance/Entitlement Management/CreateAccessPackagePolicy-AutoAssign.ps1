# Create an Entitlement Management Assignment Policy with approval settings for an Access Package

Import-Module Microsoft.Graph.Identity.Governance

Connect-MgGraph -Scopes "EntitlementManagement.ReadWrite.All"

$AccessPackageId = "" # Access Package ID
$AutoAssignmentPolicyFilter = '(user.department -eq "Department X")' # The filter to automatically assign the policy.

$PolicyName = "Automatic assignment policy"
$PolicyDescription = "policy for automatic assignment"

$AutoPolicyParameters = @{
	DisplayName = $PolicyName
	Description = $PolicyDescription
	AllowedTargetScope = "specificDirectoryUsers"
	SpecificAllowedTargets = @(
		@{
			"@odata.type" = "#microsoft.graph.attributeRuleMembers"
			description = $PolicyDescription
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

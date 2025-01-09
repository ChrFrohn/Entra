# Create an Entitlement Management auto assigment Policy for an Access Package

Import-Module Microsoft.Graph.Identity.Governance

Connect-MgGraph -Scopes "EntitlementManagement.ReadWrite.All"

# Auto assignment policy parameters
$AccessPackageId = "" # Access Package ID
$AutoPolicyName = "" # Sample: "Auto policy"
$AutoPolicyDescription = "" # Sample: "Auto policy for department X"
$AutoAssignmentPolicyFilter = '' # Sample: '(user.department -eq "Department X")' 

$PolicyName = "Automatic assignment policy"
$PolicyDescription = "policy for automatic assignment"

# Custom extension parameters
$CustomExtensionId = "" # Sample: "00000000-0000-0000-0000-000000000000" - Needs to be created before running this script

# Creating the auto assignment policy

$AutoPolicyParameters = @{
	DisplayName = $AutoPolicyName
	Description = $AutoPolicyDescription
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
		Id = $NewAccessPackage.Id
	}
	customExtensionStageSettings = @(
        @{
            stage = "assignmentRequestGranted"
            customExtension = @{
                "@odata.type" = "#microsoft.graph.accessPackageAssignmentRequestWorkflowExtension"
                id = $CustomExtensionId
            }
        }
        @{
            stage = "assignmentRequestRemoved"
            customExtension = @{
                "@odata.type" = "#microsoft.graph.accessPackageAssignmentRequestWorkflowExtension"
                id = $CustomExtensionId
            }
        }
    )
}

New-MgEntitlementManagementAssignmentPolicy -BodyParameter $AutoPolicyParameters


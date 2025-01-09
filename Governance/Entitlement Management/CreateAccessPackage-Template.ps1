# Create an Entitlement Management Assignment Policy with approval settings for an Access Package

Import-Module Microsoft.Graph.Identity.Governance

Connect-MgGraph -Scopes "EntitlementManagement.ReadWrite.All"

# Access package parameters
$AccessPackageDisplayName = "" # Sample: "Department X"
$AccessPackageDescription = "" # Sample: "Department X Access Package"
$AccessPackageCatalogId = "" # Sample: "00000000-0000-0000-0000-000000000000"

# Request policy parameters
$RequestPolicyName = "" # Sample: "Auto policy"
$PolicyDescription = "" # Sample: "Auto policy for sales department"
$membershipRule = "" # Sample: (user.department -eq "Sales")

# Auto assignment policy parameters
$AutoPolicyName = "" # Sample: "Auto policy"
$AutoPolicyDescription = "" # Sample: "Auto policy for department X"
$AutoAssignmentPolicyFilter = "" # Sample: (user.department -eq "Department X")

# Custom extension parameters
$CustomExtensionId = "" # Sample: "00000000-0000-0000-0000-000000000000" - Needs to be created before running this script


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

# Creating the request policy

$RequestPolicyNameParameters = @{
	displayName = $RequestPolicyName
	description = $PolicyDescription
	allowedTargetScope = "specificDirectoryUsers"
	specificAllowedTargets = @(
		@{
			"@odata.type" = "#microsoft.graph.attributeRuleMembers"
			description = $PolicyDescription
			membershipRule = $membershipRule
		}
	)
	automaticRequestSettings = @{
		requestAccessForAllowedTargets = $true
		removeAccessWhenTargetLeavesAllowedTargets = $true
	}
	accessPackage = @{
		id = $NewAccessPackage.Id
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

New-MgEntitlementManagementAssignmentPolicy -BodyParameter $RequestPolicyNameParameters 

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

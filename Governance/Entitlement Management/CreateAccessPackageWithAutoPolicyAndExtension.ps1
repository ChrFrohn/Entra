Import-Module Microsoft.Graph.Identity.Governance

# Access package parameters
$AccessPackageDisplayName = "" # Sample: "Sales department"
$AccessPackageDescription = "" # Sample: "Sales department access package"
$AccessPackageCatalogId = "" # Sample: "00000000-0000-0000-0000-000000000000"

# Policy parameters
$PolicyName = "" # Sample: "Auto policy"
$PolicyDescription = "" # Sample: "Auto policy for sales department"
$membershipRule = "" # Sample: (user.department -eq "Sales")

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
$NewAccessPackage = Get-MgEntitlementManagementAccessPackage -Filter "displayName eq '$DisplayName'"

# Creating the policy

$params = @{
	displayName = $PolicyName
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

New-MgEntitlementManagementAssignmentPolicy -BodyParameter $params
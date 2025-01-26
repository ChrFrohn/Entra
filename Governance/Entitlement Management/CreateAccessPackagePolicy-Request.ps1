# Create an Entitlement Management Assignment Policy with approval settings for an Access Package
Import-Module Microsoft.Graph.Identity.Governance
 
Connect-MgGraph -Scopes "EntitlementManagement.ReadWrite.All"

# Request policy parameters
$AccessPackageId = "" # Access Package ID
$RequestPolicyName = "" # Sample: "Auto policy"
$PolicyDescription = "" # Sample: "Request policy for Department X"
$membershipRule = "allMemberUsers" # "allMemberUsers", "specificAllowedTargets", "allConfiguredConnectedOrganizationUsers", "notSpecified"
$Approver = "" # Object ID of the user in Entra ID / Change to groupId for group

# Creating the request policy

$RequestPolicyNameParameters = @{
	displayName = $RequestPolicyName
	description = $PolicyDescription
    allowedTargetScope = $membershipRule
 
    expiration = @{
        type = "noExpiration"
    }
    requestorSettings = @{
        enableTargetsToSelfAddAccess = $true
        enableTargetsToSelfUpdateAccess = $true
        enableTargetsToSelfRemoveAccess = $true
        allowCustomAssignmentSchedule = $true
        enableOnBehalfRequestorsToAddAccess = $false
        enableOnBehalfRequestorsToUpdateAccess = $false
        enableOnBehalfRequestorsToRemoveAccess = $false
        onBehalfRequestors = @(
        )
    }
	requestApprovalSettings = @{
		isApprovalRequiredForAdd = "true"
		isApprovalRequiredForUpdate = "true"
		stages = @(
			@{
				durationBeforeAutomaticDenial = "P7D" # 7 days
				isApproverJustificationRequired = "false"
				isEscalationEnabled = "false" 
				fallbackPrimaryApprovers = @(
				)
				escalationApprovers = @(
				)
				fallbackEscalationApprovers = @(
				)
				primaryApprovers = @(
					@{
						"@odata.type" = "#microsoft.graph.singleUser" # For group use: "@odata.type" = "#microsoft.graph.groupMembers"
						userId = $Approver # Object ID of the user in Entra ID / Change to groupId for group
					}
				)
			}
		)
    }
    accessPackage = @{
        id = $NewAccessPackage.Id
    }
}

New-MgEntitlementManagementAssignmentPolicy -BodyParameter $RequestPolicyNameParameters 

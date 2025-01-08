# Create an Entitlement Management Assignment Policy with approval settings for an Access Package
Import-Module Microsoft.Graph.Identity.Governance
 
Connect-MgGraph -Scopes "EntitlementManagement.ReadWrite.All"

$AccessPackageId = "" # Access Package ID
$Approver = "" # ObjectId of the user that needs to approve the requests

$PolicyParameters = @{
    displayName = "Request Policy"
    description = "policy for assignments upon request"
    allowedTargetScope = "allMemberUsers" # "allMemberUsers", "specificAllowedTargets", "allConfiguredConnectedOrganizationUsers", "notSpecified"

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
        id = $AccessPackageId
    }
}

New-MgEntitlementManagementAssignmentPolicy -BodyParameter $PolicyParameters

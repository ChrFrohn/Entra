# Create an Entitlement Management Assignment Policy with no approval settings for an Access Package
Import-Module Microsoft.Graph.Identity.Governance
 
Connect-MgGraph -Scopes "EntitlementManagement.ReadWrite.All"

# Request policy parameters
$AccessPackageId = "" # Access Package ID
$RequestPolicyName = "" 
$PolicyDescription = ""
$GroupId = "" # Group object ID 

# Creating the request policy
$RequestPolicyNameParameters = @{
    displayName = $RequestPolicyName
    description = $PolicyDescription
    allowedTargetScope = "specificDirectoryUsers" # Restrict to specific groups
    specificAllowedTargets = @(
        @{
            "@odata.type" = "#microsoft.graph.groupMembers"
            groupId = $GroupId
        }
    )
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
        isApprovalRequiredForAdd = $false # No approval required for adding access
        isApprovalRequiredForUpdate = $false # No approval required for updating access
        stages = @() # No approval stages
    }
    accessPackage = @{
        id = $AccessPackageId
    }
}

New-MgEntitlementManagementAssignmentPolicy -BodyParameter $RequestPolicyNameParameters

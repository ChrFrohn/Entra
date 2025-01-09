# Custom extension parameters
$CustomExtensionId = "" # Sample: "00000000-0000-0000-0000-000000000000" - Needs to be created before running this script

# Add this part to the parameters of a new policy in Entra ID Goverance Entitlement Management

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

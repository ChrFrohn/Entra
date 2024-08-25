# Import module and Connect to Microsoft Graph
Import-Module Microsoft.Graph.Identity.Governance
Connect-MgGraph -Scopes "LifecycleWorkflows.ReadWrite.All"

# Initialize Lifecycle Workflow
$User = "" #Object ID or UPN of the user in Entra ID
$LifeCycleWorkflowID = "" # ID of the lifecycle workflow

$LifeCycleWorkflowParameters = @{
    subjects = @{
        id = $User # Entra ID users Object ID
    }
}

Initialize-MgIdentityGovernanceLifecycleWorkflow -WorkflowId $LifeCycleWorkflowID -BodyParameter $LifeCycleWorkflowParameters

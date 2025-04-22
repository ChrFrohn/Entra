# Import module and Connect to Microsoft Graph
Import-Module Microsoft.Graph.Identity.Governance
Connect-MgGraph -Scopes "LifecycleWorkflows.ReadWrite.All"

# Initialize Lifecycle Workflow
$User = "" #Object ID of the user in Entra ID
$LifeCycleWorkflowID = "" # ID of the Lifecycle Workflow

$LifeCycleWorkflowParameters = @{
	subjects = @(
		@{
			id = $User
		}
	)
}

Initialize-MgIdentityGovernanceLifecycleWorkflow -WorkflowId $LifeCycleWorkflowID -BodyParameter $LifeCycleWorkflowParameters

# Function to test if a user exists in the directory
function Test-UserExists {
    param([string]$UserId)
    
    try {
        $User = Get-MgUser -UserId $UserId -ErrorAction Stop
        Write-Verbose "User found: $($User.DisplayName) ($UserId)"
        return $true
    }
    catch {
        Write-Verbose "User NOT found: $UserId - $($_.Exception.Message)"
        return $false
    }
}

# Function to validate approvers in a policy
function Get-InvalidApprovers {
    param(
        [object]$Policy,
        [string]$AccessPackageName
    )
    
    $InvalidApprovers = @()
    
    if ($Policy.RequestApprovalSettings -and $Policy.RequestApprovalSettings.Stages) {
        foreach ($Stage in $Policy.RequestApprovalSettings.Stages) {
            
            # Check all approver types
            $ApproverTypes = @(
                @{ Property = "PrimaryApprovers"; Type = "Primary" },
                @{ Property = "EscalationApprovers"; Type = "Escalation" },
                @{ Property = "FallbackPrimaryApprovers"; Type = "Fallback Primary" },
                @{ Property = "FallbackEscalationApprovers"; Type = "Fallback Escalation" }
            )
            
            foreach ($ApproverType in $ApproverTypes) {
                $Approvers = $Stage.($ApproverType.Property)
                if ($Approvers) {
                    foreach ($Approver in $Approvers) {
                        # Check if approver is a specific user (access via AdditionalProperties)
                        $OdataType = $Approver.AdditionalProperties['@odata.type']
                        if ($OdataType -eq '#microsoft.graph.singleUser') {
                            $UserId = $Approver.AdditionalProperties['userId']
                            if (![string]::IsNullOrEmpty($UserId)) {
                                Write-Verbose "Testing user existence for: $UserId"
                                
                                # Test if user exists directly (not using function to avoid scope issues)
                                $UserExists = $false
                                try {
                                    $User = Get-MgUser -UserId $UserId -ErrorAction Stop
                                    $UserExists = $true
                                    Write-Verbose "User exists: $($User.DisplayName)"
                                }
                                catch {
                                    Write-Verbose "User does not exist: $UserId - $($_.Exception.Message)"
                                    $UserExists = $false
                                }
                                
                                if (!$UserExists) {
                                    $ApproverDescription = $Approver.AdditionalProperties['description']
                                    $InvalidApprovers += [PSCustomObject]@{
                                        AccessPackage = $AccessPackageName
                                        PolicyName = $Policy.DisplayName
                                        ApprovalStage = $Stage.DurationBeforeAutomaticDenial
                                        ApproverType = $ApproverType.Type
                                        InvalidUserId = $UserId
                                        ApproverName = $ApproverDescription
                                        ApproverDetails = $Approver
                                    }
                                    Write-Verbose "Added invalid approver: $UserId ($ApproverDescription)"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    return $InvalidApprovers
}

try {
    Write-Host "Starting Access Package Approver Validation..." -ForegroundColor Green
    Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Yellow
    
    # Connect to Microsoft Graph with required permissions
    Connect-MgGraph -Scopes "User.Read.All", "EntitlementManagement.Read.All" -NoWelcome
        
    # Get all access packages
    Write-Host "Retrieving all access packages..." -ForegroundColor Yellow
    $AccessPackages = Get-MgEntitlementManagementAccessPackage -All
       
    Write-Host "Found $($AccessPackages.Count) access packages to analyze" -ForegroundColor Green
    
    $AllInvalidApprovers = @()
    $ProcessedCount = 0
    
    foreach ($Package in $AccessPackages) {
        $ProcessedCount++
        Write-Progress -Activity "Checking Access Packages" -Status "Processing $($Package.DisplayName)" -PercentComplete (($ProcessedCount / $AccessPackages.Count) * 100)
        
        # Get assignment policies for this access package
        try {
            $Policies = Get-MgEntitlementManagementAssignmentPolicy -Filter "accessPackage/id eq '$($Package.Id)'" -All
            
            if ($Policies) {
                foreach ($Policy in $Policies) {
                    # Check for invalid approvers in this policy
                    $InvalidApprovers = Get-InvalidApprovers -Policy $Policy -AccessPackageName $Package.DisplayName
                    
                    if ($InvalidApprovers) {
                        # Only show output when issues are found
                        if ($AllInvalidApprovers.Count -eq 0) {
                            Write-Host "`nISSUES FOUND:" -ForegroundColor Red
                        }
                        
                        Write-Host "`n $($Package.DisplayName)" -ForegroundColor Red
                        Write-Host "   Policy: $($Policy.DisplayName)" -ForegroundColor Gray
                        
                        foreach ($Approver in $InvalidApprovers) {
                            Write-Host "   Invalid Approver: $($Approver.ApproverName) (ID: $($Approver.InvalidUserId))" -ForegroundColor Yellow
                            Write-Host "   Approver Type: $($Approver.ApproverType)" -ForegroundColor Gray
                        }
                        
                        $AllInvalidApprovers += $InvalidApprovers
                    }
                }
            }
        }
        catch {
            Write-Warning "Error processing access package '$($Package.DisplayName)': $($_.Exception.Message)"
        }
    }
    
    Write-Progress -Activity "Checking Access Packages" -Completed
    
    # Generate report - only show summary if issues were found
    if ($AllInvalidApprovers.Count -gt 0) {

        Write-Host "VALIDATION COMPLETE - ISSUES FOUND" -ForegroundColor Red
        
        # Group by access package for summary
        $PackageSummary = $AllInvalidApprovers | Group-Object AccessPackage | Sort-Object Name
        
        Write-Host "`nSUMMARY:" -ForegroundColor Yellow
        Write-Host "  Total Access Packages with Issues: $($PackageSummary.Count)" -ForegroundColor Red
        Write-Host "  Total Invalid Approvers Found: $($AllInvalidApprovers.Count)" -ForegroundColor Red
                
    } else {
        Write-Host "`nVALIDATION COMPLETE: No issues found - all access packages have valid approvers!" -ForegroundColor Green
        Write-Host "   Total Access Packages Checked: $($AccessPackages.Count)" -ForegroundColor Gray
    }
    
}
catch {
    Write-Error "Script execution failed: $($_.Exception.Message)"
}
finally {
    # Disconnect from Microsoft Graph
    if (Get-MgContext) {
        Disconnect-MgGraph -ErrorAction SilentlyContinue | Out-Null
    }
}

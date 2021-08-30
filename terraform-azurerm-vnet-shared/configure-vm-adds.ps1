param (
    [Parameter(Mandatory = $true)]
    [String]$TenantId,

    [Parameter(Mandatory = $true)]
    [String]$SubscriptionId,

    [Parameter(Mandatory = $true)]
    [String]$ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [String]$Location,

    [Parameter(Mandatory = $true)]
    [String]$AutomationAccountName,

    [Parameter(Mandatory = $true)]
    [String]$Domain,

    [Parameter(Mandatory = $true)]
    [String]$VirtualMachineName,

    [Parameter(Mandatory = $true)]
    [String]$AdminUsername,

    [Parameter(Mandatory = $true)]
    [String]$AdminPwd
)

#region constants
$AzureEnvironment = 'AzureCloud'
$DscConfigurationName = 'LabDomainConfig'
$DscConfigurationNode = 'localhost'
#endregion

#region functions
function Write-Log {
    param( [string] $msg)
    "$(Get-Date -Format FileDateTimeUniversal) : $msg" | Write-Host
}

function Exit-WithError {
    param( [string]$msg )
    Write-Log "There was an exception during the process, please review..."
    Write-Log $msg
    Exit 2
}
#endregion

#region main
Write-Log "Running '$PSCommandPath'..."

# Important: Discontinue use of device authentication for production use
Write-Log "Logging into Azure using AAD tenant id '$TenantId' and Azure subscription id '$SubscriptionId'..."
Disconnect-AzAccount

try {
    Connect-AzAccount -Environment $AzureEnvironment -Tenant $TenantId -Subscription $SubscriptionId -UseDeviceAuthentication -ErrorAction Stop
}
catch {
    Exit-WithError $_
}

# Bootstrap automation account
$automationAccount = Get-AzAutomationAccount -ResourceGroupName $ResourceGroupName -Name $AutomationAccountName

if ($null -eq $automationAccount) {
    Exit-WithError "Automation account '$AutomationAccountName' was not found..."
}

Write-Log "Located automation account '$AutomationAccountName' in resource group '$ResourceGroupName'"

# Register DSC Node
$nodeConfigName = $DscConfigurationName + '.' + $DscConfigurationNode
Write-Log "Registering DSC node '$VirtualMachineName' with node configuration '$nodeConfigName'..."
Write-Log "Warning, this process can take several minutes and the VM will be rebooted..."

try {
    Register-AzAutomationDscNode `
        -ResourceGroupName $ResourceGroupName `
        -AutomationAccountName $AutomationAccountName `
        -AzureVMName $VirtualMachineName `
        -AzureVMResourceGroup $ResourceGroupName `
        -AzureVMLocation $Location `
        -NodeConfigurationName $nodeConfigName `
        -ConfigurationModeFrequencyMins 15 `
        -ConfigurationMode 'ApplyOnly' `
        -AllowModuleOverwrite $false `
        -RebootNodeIfNeeded $true `
        -ActionAfterReboot 'ContinueConfiguration' `
        -ErrorAction Stop 
}
catch {
    Exit-WithError $_
}

Write-Log "Checking status of DSC node '$VirtualMachineName'..."

try {
    $dscNode = Get-AzAutomationDscNode `
        -ResourceGroupName $ResourceGroupName `
        -AutomationAccountName $automationAccount.AutomationAccountName `
        -Name $VirtualMachineName `
        -ErrorAction Stop
}
catch {
    Exit-WithError $_
}

Write-Log "Status for DSC node '$VirtualMachineName' is '$($dscNode.Status)'..."

if ($dscNode.Status -ne 'Compliant') {
    Exit-WithError "DSC node '$VirtualMachineName' is not compliant..."
}

Exit 0
#endregion

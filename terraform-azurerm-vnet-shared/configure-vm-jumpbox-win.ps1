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
    [String]$AppId,

    [Parameter(Mandatory = $true)]
    [string]$AppSecret
)

#region constants
$DscConfigurationName = 'JumpBoxConfig'
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

function Register-DscNode {
    param(
        [Parameter(Mandatory = $true)]
        [string] $ResourceGroupName,

        [Parameter(Mandatory = $true)]
        [string] $AutomationAccountName,

        [Parameter(Mandatory = $true)]
        [string] $VirtualMachineName,

        [Parameter(Mandatory = $true)]
        [string] $Location,

        [Parameter(Mandatory = $true)]
        [string] $DscConfigurationName,

        [Parameter(Mandatory = $true)]
        [string] $DscConfigurationNode
    )

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

    try {
        $dscNode = Get-AzAutomationDscNode `
            -ResourceGroupName $ResourceGroupName `
            -AutomationAccountName $AutomationAccountName `
            -Name $VirtualMachineName `
            -ErrorAction Stop
    }
    catch {
        Exit-WithError $_
    }

    $jobStatus = $dscNode.Status
    Write-Log "DSC registration status for virtual machine '$VirtualMachineName' is '$jobStatus'..."

    $i = 0
    do {
        $i++        

        Start-Sleep 10
        try {
            $dscNode = Get-AzAutomationDscNode `
                -ResourceGroupName $ResourceGroupName `
                -AutomationAccountName $AutomationAccountName `
                -Name $VirtualMachineName `
                -ErrorAction Stop
        }
        catch {
            Exit-WithError $_
        }

        $jobStatus = $dscNode.Status
        Write-Log "DSC registration status for virtual machine '$VirtualMachineName' is '$jobStatus'..."

    } while (($jobStatus -ne "Compliant") -or $i -gt 20)

    if ($jobStatus -ne 'Compliant') {
        Exit-WithError "DSC node '$VirtualMachineName' is not compliant..."
    }    
}
#endregion

#region main
Write-Log "Running '$PSCommandPath'..."

Write-Log "Logging into Azure using service principal id '$AppId'..."

$AppSecretSecure = ConvertTo-SecureString $AppSecret -AsPlainText -Force
$spCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $AppId, $AppSecretSecure

try {
    Connect-AzAccount -Credential $spCredential -Tenant $TenantId -ServicePrincipal -ErrorAction Stop | Out-Null
}
catch {
    Exit-WithError $_
}

# Get automation account
$automationAccount = Get-AzAutomationAccount -ResourceGroupName $ResourceGroupName -Name $AutomationAccountName

if ($null -eq $automationAccount) {
    Exit-WithError "Automation account '$AutomationAccountName' was not found..."
}

Write-Log "Located automation account '$AutomationAccountName' in resource group '$ResourceGroupName'"

# Register DSC Node
Register-DscNode `
    -ResourceGroupName $ResourceGroupName `
    -AutomationAccountName $AutomationAccountName `
    -VirtualMachineName $VirtualMachineName `
    -Location $Location `
    -DscConfigurationName $DscConfigurationName `
    -DscConfigurationNode $DscConfigurationNode

Exit 0
#endregion

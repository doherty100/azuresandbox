param (
    [Parameter(Mandatory = $false)]
    [String]$TenantId = '72f988bf-86f1-41af-91ab-2d7cd011db47',

    [Parameter(Mandatory = $false)]
    [String]$SubscriptionId = 'f6d69ee2-34d5-4ca8-a143-7a2fc1aeca55',

    [Parameter(Mandatory = $false)]
    [String]$ResourceGroupName = 'rg-vdc-nonprod-01',

    [Parameter(Mandatory = $false)]
    [String]$Location = 'eastus2',

    [Parameter(Mandatory = $false)]
    [Hashtable]$Tags = @{project = '#AzureQuickStarts'; costcenter = '10177772'; environment = 'dev' },

    [Parameter(Mandatory = $false)]
    [String]$Domain = 'mytestlab.local',

    [Parameter(Mandatory = $false)]
    [String]$VirtualMachineName = 'adds1',

    [Parameter(Mandatory = $false)]
    [String]$AdminUsername = 'bootstrapadmin',

    [Parameter(Mandatory = $false)]
    [String]$AdminPassword = '7S+1NXBYfl<y'
)

#region constants
$AzureEnvironment = 'AzureCloud'
$AutomationCredentialName = 'bootstrapadmin'
$DscConfigurationName = 'LabDomainConfig'
$DscConfigurationScript = 'LabDomainConfig.ps1'
$DscConfigurationNode = 'localhost'

#endregion

#region functions
function Write-Log {
    param( [string] $msg)
    "$(Get-Date -Format FileDateTimeUniversal) : $msg" | Write-Host
}

function Import-Module {
    param(
        [Parameter(Mandatory = $true)]
        [String]$ResourceGroupName,

        [Parameter(Mandatory = $true)]
        [String]$AutomationAccountName,

        [Parameter(Mandatory = $true)]
        [String]$ModuleName,

        [Parameter(Mandatory = $true)]
        [String]$ModuleUri
    )

    Write-Log "Importing module '$ModuleName'..."
    $automationModule = Get-AzAutomationModule -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName | Where-Object { $_.Name -eq $ModuleName }

    if ($null -eq $automationModule) {
        try {
            $automationModule = New-AzAutomationModule `
                -Name $ModuleName `
                -ContentLinkUri $ModuleUri `
                -ResourceGroupName $ResourceGroupName `
                -AutomationAccountName $AutomationAccountName `
                -ErrorAction Stop            
        }
        catch {
            Exit-WithError $_
        }
    }

    while ($true) {
        $automationModule = Get-AzAutomationModule -Name $ModuleName -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName
        
        if (($automationModule.ProvisioningState -eq 'Succeeded') -or ($automationModule.ProvisioningState -eq 'Failed')) {
            break
        }

        Write-Log "Module '$($automationModule.Name)' provisioning state is '$($automationModule.ProvisioningState)'..."
        Start-Sleep -Seconds 30
    }

    if ($automationModule.ProvisioningState -eq "Failed") {
        Exit-WithError "Module '$($automationModule.Name)' import failed..."
    }

    Write-Log "Module '$($automationModule.Name)' provisioning state is '$($automationModule.ProvisioningState)'..."
}

function Exit-WithError {
    param( [string]$msg )
    Write-Log "There was an exception during the process, please review..."
    Write-Log $msg
    Exit 2
}

function Set-Variable {
    param(
        [Parameter(Mandatory = $true)]
        [String]$ResourceGroupName,

        [Parameter(Mandatory = $true)]
        [String]$AutomationAccountName,

        [Parameter(Mandatory = $true)]
        [String]$VariableName,

        [Parameter(Mandatory = $true)]
        [String]$VariableValue
    )

    Write-Log "Setting automation variable '$VariableName' to value '$VariableValue'..."
    $automationVariable = Get-AzAutomationVariable -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName | Where-Object { $_.Name -eq $VariableName }

    if ($null -eq $automationVariable) {
        try {
            $automationVariable = New-AzAutomationVariable `
                -Name $VariableName `
                -Encrypted $false `
                -Description $VariableName `
                -Value $VariableValue `
                -ResourceGroupName $ResourceGroupName `
                -AutomationAccountName $AutomationAccountName `
                -ErrorAction Stop
        }
        catch {
            Exit-WithError $_
        }
    }
    else {
        try {
            $automationVariable = Set-AzAutomationVariable `
                -Name $VariableName `
                -Encrypted $false `
                -Value $VariableValue `
                -ResourceGroupName $ResourceGroupName `
                -AutomationAccountName $AutomationAccountName `
                -ErrorAction Stop
        }
        catch {
            Exit-WithError $_
        }
    }
}

#endregion

#region main
Write-Log "Running '$PSCommandPath'..."
Write-Log "Logging into Azure using AAD tenant id '$TenantId' and Azure subscription id '$SubscriptionId'..."
Disconnect-AzAccount

try {
    Connect-AzAccount -Environment $AzureEnvironment -Tenant $TenantId -Subscription $SubscriptionId -UseDeviceAuthentication -ErrorAction Stop
}
catch {
    Exit-WithError $_
}

# Bootstrap automation account
$automationAccount = Get-AzAutomationAccount -ResourceGroupName $ResourceGroupName | Where-Object { $_.Tags['provisioner'] -eq 'bootstrap-automation.ps1' }

if ($null -eq $automationAccount) {
    $automationAccountNameRandom = "auto-$(New-Guid)-01" 
    $Tags += @{provisioner = "$($MyInvocation.MyCommand.Name)" }
    Write-Log "Creating automation account '$automationAccountNameRandom' in resource group '$resourceGroupName'..."
    try {
        $automationAccount = New-AzAutomationAccount `
            -ResourceGroupName $ResourceGroupName `
            -Name $automationAccountNameRandom `
            -Location $Location `
            -Plan 'Basic' `
            -Tags $Tags `
            -ErrorAction Stop
    }
    catch {
        Exit-WithError $_
    }
}
else {
    Write-Log "Located automation account '$($automationAccount.AutomationAccountName)' in resource group '$resourceGroupName'"
}

# Bootstrap automation modules
Import-Module `
    -ResourceGroupName $ResourceGroupName `
    -AutomationAccountName $automationAccount.AutomationAccountName `
    -ModuleName 'Az.Accounts' `
    -ModuleUri 'https://www.powershellgallery.com/api/v2/package/Az.Accounts'

Import-Module `
    -ResourceGroupName $ResourceGroupName `
    -AutomationAccountName $automationAccount.AutomationAccountName `
    -ModuleName 'Az.Automation' `
    -ModuleUri 'https://www.powershellgallery.com/api/v2/package/Az.Automation'

Import-Module `
    -ResourceGroupName $ResourceGroupName `
    -AutomationAccountName $automationAccount.AutomationAccountName `
    -ModuleName 'ActiveDirectoryDsc' `
    -ModuleUri 'https://www.powershellgallery.com/api/v2/package/ActiveDirectoryDsc/6.0.1'

# Bootstrap automation variables
Set-Variable `
    -ResourceGroupName $ResourceGroupName `
    -AutomationAccountName $automationAccount.AutomationAccountName `
    -VariableName 'aad_tenant_id' `
    -VariableValue $TenantId

Set-Variable `
    -ResourceGroupName $ResourceGroupName `
    -AutomationAccountName $automationAccount.AutomationAccountName `
    -VariableName 'subscription_id' `
    -VariableValue $SubscriptionId

Set-Variable `
    -ResourceGroupName $ResourceGroupName `
    -AutomationAccountName $automationAccount.AutomationAccountName `
    -VariableName 'resource_group_name' `
    -VariableValue $ResourceGroupName

Set-Variable `
    -ResourceGroupName $ResourceGroupName `
    -AutomationAccountName $automationAccount.AutomationAccountName `
    -VariableName 'automation_account_name' `
    -VariableValue $automationAccount.AutomationAccountName

Set-Variable `
    -ResourceGroupName $ResourceGroupName `
    -AutomationAccountName $automationAccount.AutomationAccountName `
    -VariableName 'adds_domain_name' `
    -VariableValue $Domain

Set-Variable `
    -ResourceGroupName $ResourceGroupName `
    -AutomationAccountName $automationAccount.AutomationAccountName `
    -VariableName 'adds_dsc_config_name' `
    -VariableValue 'LabDomainConfig'

# Bootstrap automation credentials
Write-Log "Setting automation credential '$AutomationCredentialName'..."

try {
    $automationCredential = Get-AzAutomationCredential `
        -ResourceGroupName $ResourceGroupName `
        -AutomationAccountName $automationAccount.AutomationAccountName `
        -ErrorAction Stop `
        | Where-Object { $_.Name -eq $AutomationCredentialName }
}
catch {
    Exit-WithError $_
}

$adminPasswordSecure = ConvertTo-SecureString $AdminPassword -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $AdminUsername, $adminPasswordSecure

if ($null -eq $automationCredential) {
    $adminPasswordSecure = ConvertTo-SecureString $AdminPassword -AsPlainText -Force
    $credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $AdminUsername, $adminPasswordSecure

    try {
        $automationCredential = New-AzAutomationCredential `
            -Name $AutomationCredentialName `
            -Description $AutomationCredentialName `
            -Value $credential `
            -ResourceGroupName $ResourceGroupName `
            -AutomationAccountName $automationAccount.AutomationAccountName `
            -ErrorAction Stop
    }
    catch {
        Exit-WithError $_
    }
}
else {
    try {
        $automationCredential = Set-AzAutomationCredential `
            -Name $AutomationCredentialName `
            -Description $AutomationCredentialName `
            -Value $credential `
            -ResourceGroupName $ResourceGroupName `
            -AutomationAccountName $automationAccount.AutomationAccountName `
            -ErrorAction Stop
    }
    catch {
        Exit-WithError $_
    }
}

# Bootstrap DSC Configurations
Write-Log "Importing DSC configuration '$DscConfigurationName' from '$DscConfigurationScript'..."
$dscConfigurationScriptPath = Join-Path $PSScriptRoot $DscConfigurationScript

try {
    Import-AzAutomationDscConfiguration `
        -SourcePath $dscConfigurationScriptPath `
        -Description $DscConfigurationName `
        -Published `
        -Force `
        -ResourceGroupName $ResourceGroupName `
        -AutomationAccountName $automationAccount.AutomationAccountName `
        -ErrorAction Stop `
        | Out-Null
}
catch {
    Exit-WithError $_
}

# Compile DSC Configuration
Write-Log "Compliling DSC Configuration '$DscConfigurationName'..."

try {
    $dscCompilationJob = Start-AzAutomationDscCompilationJob `
        -ResourceGroupName $ResourceGroupName `
        -AutomationAccountName $automationAccount.AutomationAccountName `
        -ConfigurationName $DscConfigurationName `
        -ErrorAction Stop
}
catch {
    Exit-WithError $_
}

$jobId = $dscCompilationJob.Id

while($null -eq $dscCompilationJob.EndTime -and $null -eq $dscCompilationJob.Exception)
{
    $dscCompilationJob = $dscCompilationJob | Get-AzAutomationDscCompilationJob
    Write-Log "DSC compilation job ID '$jobId' status is '$($dscCompilationJob.Status)'..."
    Start-Sleep -Seconds 5
}

if ($dscCompilationJob.Exception) {
    Exit-WithError "DSC compilation job ID '$jobId' failed..."
}

Write-Log "DSC compilation job ID '$jobId' status is '$($dscCompilationJob.Status)'..."

# Register DSC Node
$nodeConfigName = $DscConfigurationName + '.' + $DscConfigurationNode
Write-Log "Registering DSC node '$VirtualMachineName' with node configuration '$nodeConfigName'..."

try {
    Register-AzAutomationDscNode `
        -ResourceGroupName $ResourceGroupName `
        -AutomationAccountName $automationAccount.AutomationAccountName `
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

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
    [String]$AdminPwd,

    [Parameter(Mandatory = $true)]
    [String]$AppId,

    [Parameter(Mandatory = $true)]
    [string]$AppSecret
)

#region constants
$AutomationCredentialName = 'bootstrapadmin'
$DscConfigurationName = 'LabDomainConfig'
$DscConfigurationScript = 'LabDomainConfig.ps1'
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
        Start-Sleep -Seconds 10
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

Write-Log "Logging into Azure using service principal id '$AppId'..."

$AppSecretSecure = ConvertTo-SecureString $AppSecret -AsPlainText -Force
$spCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $AppId, $AppSecretSecure

try {
    Connect-AzAccount -Credential $spCredential -Tenant $TenantId -ServicePrincipal -ErrorAction Stop | Out-Null
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

$AdminPwdSecure = ConvertTo-SecureString $AdminPwd -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $AdminUsername, $AdminPwdSecure

if ($null -eq $automationCredential) {
    $AdminPwdSecure = ConvertTo-SecureString $AdminPwd -AsPlainText -Force
    $credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $AdminUsername, $AdminPwdSecure

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
    Start-Sleep -Seconds 10
}

if ($dscCompilationJob.Exception) {
    Exit-WithError "DSC compilation job ID '$jobId' failed..."
}

Write-Log "DSC compilation job ID '$jobId' status is '$($dscCompilationJob.Status)'..."

Exit 0
#endregion

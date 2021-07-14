$connectionName = "AzureRunAsConnection"
try {
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName      
    Write-Output "Logging in to Azure..."
    Connect-AzAccount `
        -ServicePrincipal `
        -Tenant $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection) {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } 
    else { 
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

Write-Output "Retrieving automation variables..."

try {
    $ConfigName = Get-AutomationVariable -Name 'adds_dsc_config_name'
    $ResourceGroupName = Get-AutomationVariable -Name 'resource_group_name'
    $AutomationAccountName = Get-AutomationVariable -Name 'automation_account_name'
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

Write-Output "Starting compilation job for configuration '$ConfigName' on automation account '$AutomationAccountName' in resource group '$ResourceGroupName'..."
try {
    $compilationJob = Start-AzAutomationDscCompilationJob `
        -ConfigurationName $ConfigName `
        -ResourceGroupName $ResourceGroupName `
        -AutomationAccountName $AutomationAccountName
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

Write-Output "Compilation job id '$($compilationJob.id)' has started..."
$sleepSeconds = 10

while(($null -eq $compilationJob.EndTime) -and ($null -eq $compilationJob.Exception)) {
    Write-Output "Status for compilation job '$($compilationJob.id)' is '$($compilationJob.Status)'..."
    Write-Output "Sleeping for '$sleepSeconds' seconds..."
    Start-Sleep -Seconds $sleepSeconds
    $compilationJob = $compilationJob | Get-AzAutomationDscCompilationJob 
}

if ($null -ne $compilationJob.Exception ) {
    throw $compilationJob.Exception
}

$compilationJob

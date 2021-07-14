$connectionName = "AzureRunAsConnection"
try {
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName      
    Write-Output "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
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
    $DomainName = Get-AutomationVariable -Name 'adds_domain_name'
    $ResourceGroupName = Get-AutomationVariable -Name 'resource_group_name'
    $AutomationAccountName = Get-AutomationVariable -Name 'automation_account_name'
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

Write-Output "Starting compilation job for configuration '$ConfigName' on automation account '$AutomationAccountName' in resource group '$ResourceGroupName'..."
try {
    $compilationJob = Start-AzureRmAutomationDscCompilationJob `
        -ConfigurationName $ConfigName `
        -ResourceGroupName $ResourceGroupName `
        -AutomationAccountName $AutomationAccountName
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

$jobId = $compilationJob.id
Write-Output "Compilation job id '$jobId' has started..."

while(($compilationJob.EndTime -eq $null) -and ($compilationJob.Exception -eq $null )) {
    Write-Output "Status for compilation job '$jobId' is '$($compilationJob.Status)'..."
    Write-Output "Sleeping for 3 seconds..."
    Start-Sleep -Seconds 10
    $compilationJob = $compilationJob | Get-AzureRmAutomationDscCompilationJob 
}

if ($null -ne $compilationJob.Exception ) {
    throw $compilationJob.Exception
}

$compilationJob

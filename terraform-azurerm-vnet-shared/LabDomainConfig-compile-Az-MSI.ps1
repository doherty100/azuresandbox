Write-Output "Retrieving automation variables..."
try {
    $AADTenantId = Get-AutomationVariable -Name 'aad_tenant_id'
    $AutomationAccountName = Get-AutomationVariable -Name 'automation_account_name'
    $ConfigName = Get-AutomationVariable -Name 'adds_dsc_config_name'
    $ResourceGroupName = Get-AutomationVariable -Name 'resource_group_name'
    $SubscriptionId = Get-AutomationVariable -Name 'subscription_id'
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

Write-Output "Logging in to Azure using system assigned managed identity..."
try {
    Connect-AzAccount -Environment 'AzureCloud' -Tenant $AADTenantId -Identity -Subscription $SubscriptionId | Out-Null
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

$compilationJob

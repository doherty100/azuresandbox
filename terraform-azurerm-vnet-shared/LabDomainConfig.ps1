configuration LabDomainConfig {
    Import-DscResource -ModuleName PSDscResources
    Import-DscResource -ModuleName ActiveDirectoryDsc

    $adminCredential = Get-AutomationPSCredential 'bootstrapadmin'
    $domain = Get-AutomationVariable -Name 'adds_domain_name'
    # $storageAccountName = Get-AzAutomationVariable -Name 'storage_account_name'
    # $domainControllerName = Get-AzAutomationVariable -Name 'vm_adds_name'
    # $domainAdminCredential = Get-AutomationPSCredential 'domainadmin'
    # $storageAccountCredentialKerberos = Get-AutomationPSCredential 'storageaccountkeykerb'
    
    node 'localhost' {
        WindowsFeature 'AD-Domain-Services' {
            Name = 'AD-Domain-Services'
            Ensure = 'Present'
        }

        ADDomain 'LabDomain' {
            DomainName = $domain
            Credential = $adminCredential
            SafemodeAdministratorPassword = $adminCredential
            ForestMode = 'WinThreshold'
            DependsOn = '[WindowsFeature]AD-Domain-Services'
        }

        # ADComputer 'AzureFilesEndpoint' {
        #     ComputerName = $storageAccountName
        #     DomainController = $domainControllerName
        #     UserPrincipalName = "cifs/$storageAccountName.file.core.windows.net"
        #     Credential = $storageAccountCredentialKerberos
        #     EnabledOnCreation = $true
        #     PsDscRunAsCredential = $domainAdminCredential
        #     DependsOn = '[ADDomain]LabDomain'
        # }
    }
}

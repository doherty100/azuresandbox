configuration LabDomainConfig {
    Import-DscResource -ModuleName PSDscResources
    Import-DscResource -ModuleName ActiveDirectoryDsc

    $adminCredential = Get-AutomationPSCredential 'bootstrapadmin'
    $domain = Get-AutomationVariable -Name 'adds_domain_name'

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
    }
}          

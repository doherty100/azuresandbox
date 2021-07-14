configuration LabDomainConfig {
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ActiveDirectoryDsc
    $AdminCredential = Get-AutomationPSCredential 'bootstrapadmin'
    $Domain = Get-AutomationVariable -Name 'adds_domain_name'

    node 'localhost' {
        WindowsFeature 'AD-Domain-Services' {
            Name = 'AD-Domain-Services'
            Ensure = 'Present'
        }

        WindowsFeature 'RSAT-AD-PowerShell' {
            Name = 'RSAT-AD-PowerShell'
            Ensure = 'Present'
        }

        WindowsFeature 'RSAT-ADDS' {
            Name = 'RSAT-ADDS'
            Ensure = 'Present'
        }

        ADDomain 'LABDOMAIN' {
            DomainName = $Domain
            Credential = $AdminCredential
            SafemodeAdministratorPassword = $AdminCredential
            ForestMode = 'WinThreshold'
            DependsOn = '[WindowsFeature]AD-Domain-Services'
        }
    }
}          

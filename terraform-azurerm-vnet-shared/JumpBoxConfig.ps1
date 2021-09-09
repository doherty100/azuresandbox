configuration JumpBoxConfig {
    Import-DscResource -ModuleName 'PSDscResources'
    Import-DscResource -ModuleName 'xDSCDomainjoin'
    
    $domain = Get-AutomationVariable -Name 'adds_domain_name'
    $domainAdminCredential = Get-AutomationPSCredential 'domainadmin'
 
    node 'localhost' {
        xDSCDomainjoin JoinDomain {
            Domain = $domain
            Credential = $domainAdminCredential
        }

        WindowsFeature 'RSAT-AD-PowerShell' {
            Name = 'RSAT-AD-PowerShell'
            Ensure = 'Present'
            DependsOn = '[xDSCDomainjoin]JoinDomain'            
        }

        WindowsFeature 'RSAT-ADDS' {
            Name = 'RSAT-ADDS'
            Ensure = 'Present'
            DependsOn = '[xDSCDomainjoin]JoinDomain'            
        }

        WindowsFeature 'RSAT-DNS-Server' {
            Name = 'RSAT-DNS-Server'
            Ensure = 'Present'
            DependsOn = '[xDSCDomainjoin]JoinDomain' 
        }
    }
}

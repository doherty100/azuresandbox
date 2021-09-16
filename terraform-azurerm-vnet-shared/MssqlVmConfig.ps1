configuration MssqlVmConfig {
    Import-DscResource -ModuleName 'PSDscResources'
    Import-DscResource -ModuleName 'xDSCDomainjoin'
    
    $domain = Get-AutomationVariable -Name 'adds_domain_name'
    $domainAdminCredential = Get-AutomationPSCredential 'domainadmin'
 
    node 'localhost' {
        xDSCDomainjoin JoinDomain {
            Domain = $domain
            Credential = $domainAdminCredential
        }
    }
}

configuration MssqlVmConfig {
    Import-DscResource -ModuleName 'PSDscResources'
    Import-DscResource -ModuleName 'xDSCDomainjoin'
    Import-DscResource -ModuleName 'cChoco'
    
    $domain = Get-AutomationVariable -Name 'adds_domain_name'
    $domainAdminCredential = Get-AutomationPSCredential 'domainadmin'
 
    node 'localhost' {
        xDSCDomainjoin JoinDomain {
            Domain = $domain
            Credential = $domainAdminCredential
        }

        cChocoInstaller installChoco {
            InstallDir = "c:\choco"
            DependsOn = '[xDSCDomainjoin]JoinDomain'
        }

        cChocoPackageInstaller installEdge {
            Name = "microsoft-edge"
            DependsOn   = "[cChocoInstaller]installChoco"
            AutoUpgrade = $true
        }
    }
}

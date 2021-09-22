configuration MssqlVmConfig {
    Import-DscResource -ModuleName 'PSDscResources'
    Import-DscResource -ModuleName 'xDSCDomainjoin'
    Import-DscResource -ModuleName 'NetworkingDsc'
    Import-DscResource -ModuleName 'SqlServerDsc'
    
    $domain = Get-AutomationVariable -Name 'adds_domain_name'
    $localAdminCredential = Get-AutomationPSCredential 'bootstrapadmin'
    $domainAdminCredential = Get-AutomationPSCredential 'domainadmin'
    $domainAdminShortCredential = Get-AutomationPSCredential 'domainadminshort'

    node 'localhost' {
        xDSCDomainjoin 'JoinDomain' {
            Domain      = $domain
            Credential  = $domainAdminCredential
        }

        Firewall 'MssqlFirewallRule' {
            Name        = 'MssqlFirewallRule'
            DisplayName = 'Microsoft SQL Server database engine.'
            Ensure      = 'Present'
            Enabled     = 'True'
            Profile     = ('Domain', 'Private')
            Direction   = 'InBound'
            LocalPort   = ('1433')
            Protocol    = 'TCP'
            DependsOn   = '[xDSCDomainjoin]JoinDomain'
        }

        SqlLogin 'DomainAdmin' {
            Name                    = $domainAdminShortCredential.UserName
            LoginType               = 'WindowsUser'
            InstanceName            = 'MSSQLSERVER'
            Ensure                  = 'Present'
            DependsOn               = '[xDSCDomainjoin]JoinDomain'
            PSDscRunAsCredential    = $localAdminCredential
        }

        SqlRole 'Include_DomainAdmin_In_sysadmin' {
            ServerRoleName          = 'sysadmin'
            MembersToInclude        = $domainAdminShortCredential.UserName
            InstanceName            = 'MSSQLSERVER'
            Ensure                  = 'Present'
            DependsOn               = '[SqlLogin]DomainAdmin'
            PSDscRunAsCredential    = $localAdminCredential
        }
    }
}

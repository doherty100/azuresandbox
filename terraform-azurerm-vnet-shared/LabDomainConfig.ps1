configuration LabDomainConfig {
    param (
        [Parameter(Mandatory = $true)]
        [String]$ComputerName
    )

    Import-DscResource -ModuleName PSDscResources
    Import-DscResource -ModuleName ActiveDirectoryDsc

    $adminCredential = Get-AutomationPSCredential 'bootstrapadmin'
    $domain = Get-AutomationVariable -Name 'adds_domain_name'
    $userPath = "CN=Users,DC=$($domain.Split('.')[0]),DC=$($domain.Split('.')[1])"

    node $ComputerName {
        WindowsFeature 'AD-Domain-Services' {
            Name = 'AD-Domain-Services'
            Ensure = 'Present'
        }

        ADDomain 'LabDomain' {
            DomainName = $domain
            Credential = $adminCredential
            SafemodeAdministratorPassword = $adminCredential
            ForestMode = 'WinThreshold'
            DependsOn =  '[WindowsFeature]AD-Domain-Services'
        }

        ADUser 'FSContributor1' {
            UserName = 'FSContributor1'
            Password = $adminCredential
            DomainName = $domain
            Path = $userPath
            Ensure = 'Present'
            DependsOn = '[ADDomain]LabDomain'
        }

        ADUser 'FSReader1' {
            UserName = 'FSReader1'
            Password = $adminCredential
            DomainName = $domain
            Path = $userPath
            Ensure = 'Present'
            DependsOn = '[ADDomain]LabDomain'
        }

        ADGroup 'FSContributors' {
            GroupName = 'FSContributors'
            GroupScope = 'Global'
            Category = 'Security'
            Description = 'Users with file share contributor rights.'
            MembersToInclude = 'FSContributor1'
            Ensure = 'Present'
            DependsOn = '[ADUser]FSContributor1'
        }

        ADGroup 'FSReaders' {
            GroupName = 'FSReaders'
            GroupScope = 'Global'
            Category = 'Security'
            Description = 'Users with file share reader rights.'
            MembersToInclude = 'FSReader1'
            Ensure = 'Present'
            DependsOn = '[ADUser]FSReader1'
        }
    }
}

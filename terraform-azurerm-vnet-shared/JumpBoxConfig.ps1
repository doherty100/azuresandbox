configuration JumpBoxConfig {
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

        cChocoInstaller 'install_Choco' {
            InstallDir = "c:\choco"
            DependsOn = '[xDSCDomainjoin]JoinDomain'
        }

        cChocoPackageInstaller 'install_Edge' {
            Name = "microsoft-edge"
            DependsOn   = "[cChocoInstaller]installChoco"
            AutoUpgrade = $true
        }

        cChocoPackageInstaller 'install_Az_PowerShell' {
            Name = "az.powershell"
            DependsOn   = "[cChocoInstaller]installChoco"
            AutoUpgrade = $true
        }

        cChocoPackageInstaller 'install_VSCode' {
            Name = "vscode"
            DependsOn   = "[cChocoInstaller]installChoco"
            AutoUpgrade = $true
        }

        cChocoPackageInstaller 'install_SSMS' {
            Name = "sql-server-management-studio"
            DependsOn   = "[cChocoInstaller]installChoco"
            AutoUpgrade = $true
        }

        cChocoPackageInstaller 'install_AzureStorageExplorer' {
            Name = "microsoftazurestorageexplorer"
            DependsOn   = "[cChocoInstaller]installChoco"
            AutoUpgrade = $true
        }

        cChocoPackageInstaller 'install_AzCopy10' {
            Name = "azcopy10"
            DependsOn   = "[cChocoInstaller]installChoco"
            AutoUpgrade = $true
        }

        cChocoPackageInstaller 'install_AdminCenter' {
            Name = "windows-admin-center"
            DependsOn   = "[cChocoInstaller]installChoco"
            AutoUpgrade = $true
        }
    }
}

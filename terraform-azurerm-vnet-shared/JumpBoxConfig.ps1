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

        cChocoInstaller installChoco {
            InstallDir = "c:\choco"
            DependsOn = '[xDSCDomainjoin]JoinDomain'
        }

        cChocoPackageInstaller installEdge {
            Name = "microsoft-edge"
            DependsOn   = "[cChocoInstaller]installChoco"
            AutoUpgrade = $true
        }

        cChocoPackageInstaller installAzPowerShell {
            Name = "az.powershell"
            DependsOn   = "[cChocoInstaller]installChoco"
            AutoUpgrade = $true
        }

        cChocoPackageInstaller installVSCode {
            Name = "vscode"
            DependsOn   = "[cChocoInstaller]installChoco"
            AutoUpgrade = $true
        }

        cChocoPackageInstaller installSSMS {
            Name = "sql-server-management-studio"
            DependsOn   = "[cChocoInstaller]installChoco"
            AutoUpgrade = $true
        }

        cChocoPackageInstaller installAzureStorageExplorer {
            Name = "microsoftazurestorageexplorer"
            DependsOn   = "[cChocoInstaller]installChoco"
            AutoUpgrade = $true
        }

        cChocoPackageInstaller installAzCopy10 {
            Name = "azcopy10"
            DependsOn   = "[cChocoInstaller]installChoco"
            AutoUpgrade = $true
        }

        cChocoPackageInstaller installAdminCenter {
            Name = "windows-admin-center"
            DependsOn   = "[cChocoInstaller]installChoco"
            AutoUpgrade = $true
        }
    }
}

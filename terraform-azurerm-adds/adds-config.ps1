# Derived from https://github.com/adbertram/TestDomainCreator

param
(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Domain
)

$logpath = $PSCommandPath + '.log'

function Write-Log {
    param( [string] $msg)
    "$(Get-Date -Format FileDateTimeUniversal) : $msg" | Out-File -FilePath $logpath -Append -Force
}

function Exit-WithError {
    param( [string]$msg )
    Write-Log "There was an exception during the process, please review..."
    Write-Log $msg
    Exit 2
}

Configuration BasicDomainConfig
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $AdminCredential,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $SafeModePassword,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Domain
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ActiveDirectoryDsc
             
    Node $AllNodes.where({ $_.Purpose -eq 'Domain Controller' }).NodeName
    {

        @($ConfigurationData.NonNodeData.ADGroups).foreach( {
                ADGroup $_
                {
                    Ensure = 'Present'
                    GroupName = $_
                    DependsOn = '[ADDomain]ADDomain'
                }
            })

        @($ConfigurationData.NonNodeData.OrganizationalUnits).foreach( {
                ADOrganizationalUnit $_
                {
                    Ensure = 'Present'
                    Name = ($_ -replace '-')
                    Path = ('DC={0},DC={1}' -f ($ConfigurationData.NonNodeData.DomainName -split '\.')[0], ($ConfigurationData.NonNodeData.DomainName -split '\.')[1])
                    DependsOn = '[ADDomain]ADDomain'
                }
            })

        @($ConfigurationData.NonNodeData.ADUsers).foreach( {
                ADUser "$($_.FirstName) $($_.LastName)"
                {
                    Ensure = 'Present'
                    DomainName = $Domain
                    GivenName = $_.FirstName
                    SurName = $_.LastName
                    UserName = ('{0}{1}' -f $_.FirstName.SubString(0, 1), $_.LastName)
                    Department = $_.Department
                    Path = ("OU={0},DC={1},DC={2}" -f $_.Department, ($ConfigurationData.NonNodeData.DomainName -split '\.')[0], ($ConfigurationData.NonNodeData.DomainName -split '\.')[1])
                    JobTitle = $_.Title
                    Password = $defaultAdUserCred
                    DependsOn = '[ADDomain]ADDomain'
                }
            })

        ($Node.WindowsFeatures).foreach( {
                WindowsFeature $_
                {
                    Ensure = 'Present'
                    Name = $_
                }
            })        
        
        ADDomain ADDomain     
        {
            DomainName = $Domain
            Credential = $AdminCredential
            SafemodeAdministratorPassword = $SafeModePassword
            ForestMode = $ConfigurationData.NonNodeData.ForestMode
            DependsOn = '[WindowsFeature]AD-Domain-Services'
        }
    }         
}

# Start main
Write-Log "Running: $PSCommandPath..."

# Get admin credentials
Write-Log "Getting virtual machine tags from instance metadata service..."

try {
    $tags = Invoke-RestMethod -Headers @{"Metadata" = "true" } -Method GET -Uri http://169.254.169.254/metadata/instance/compute/tagsList?api-version=2020-06-01 
}
catch {
    Exit-WithError $_
}

$kvname = ($tags | Where-Object { $_.name -eq 'keyvault' }).value

if ( $null -eq $kvname ) {
    Exit-WithError "Unable to locate key vault name from virtual machine tags."
}

Write-Log "Using key vault name '$kvname'..."
Write-Log "Getting managed identity token from instance metadata service..."

try {
    $token = (Invoke-RestMethod -Headers @{"Metadata" = "true" } -Method GET -Uri 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2020-06-01&resource=https%3A%2F%2Fvault.azure.net').access_token
}
catch {
    Exit-WithError $_
}

Write-Log "Retrieving adminuser secret from key vault using managed identity..."
$secretName = "adminuser"

try {
    $secret = Invoke-RestMethod -Headers @{Authorization = "Bearer $token" } -Method GET -Uri "https://$kvname.vault.azure.net/secrets/$($secretName)?api-version=2016-10-01"
}
catch {
    Exit-WithError $_
}

$adminUser = $secret.Value
Write-Log "Using adminuser '$adminUser'..."
Write-Log "Retrieving adminpassword secret from key vault using managed identity..."
$secretName = "adminpassword"

try {
    $secret = Invoke-RestMethod -Headers @{Authorization = "Bearer $token" } -Method GET -Uri "https://$kvname.vault.azure.net/secrets/$($secretName)?api-version=2016-10-01"
}
catch {
    Exit-WithError $_
}

$adminPasswordSecure = ConvertTo-SecureString -String $secret.Value -AsPlainText -Force
$adminPasswordSecure.MakeReadOnly()

Write-Log "Using adminpassword '$('*' * $adminPasswordSecure.Length)'..."
$adminCredential = New-Object System.Management.Automation.PSCredential ($adminUser, $adminPasswordSecure)

Write-Log "Compiling basic domain configuration using domain '$Domain'..."
try {
    BasicDomainConfig -AdminCredential $adminCredential -SafeModePassword $adminCredential -Domain $Domain -ConfigurationData "$PSScriptRoot\adds-config-data.psd1"
}
catch {
    Exit-WithError $_
}

Write-Log "Starting DSC configuration"
try {
    Start-DscConfiguration -Path "$PSScriptRoot\BasicDomainConfig" -Wait -Verbose -Force
}
catch {
    Exit-WithError $_
}

Write-Log "Exiting normally..."
Exit

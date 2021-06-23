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

# Start main
Write-Log "Running: $PSCommandPath..."

# Install PowerShell prerequisites

$nugetPackage = Get-PackageProvider | Where-Object Name -eq 'NuGet'

if ($null -eq $nugetPackage) {
    Write-Log "Installing NuGet PowerShell package provider..."

    try {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force 
    }
    catch {
        Exit-WithError $_
    }
}

$nugetPackage = Get-PackageProvider | Where-Object Name -eq 'NuGet'
Write-Log "NuGet Powershell Package Provider version $($nugetPackage.Version.Major).$($nugetPackage.Version.Minor).$($nugetPackage.Version.Build).$($nugetPackage.Version.Revision) is already installed..."

$repo = Get-PSRepository -Name PSGallery

if ( $repo.InstallationPolicy -eq 'Trusted' ) {
    Write-Log "PSGallery installation policy is already set to 'Trusted'..."
}
else {
    Write-Log "Setting PSGallery installation policy to 'Trusted'..."

    try {
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted    
    }
    catch {
        Exit-WithError $_
    }
}

$PSDscResourcesModule = Get-Module -ListAvailable -Name PSDscResources

if ($null -eq $PSDscResourcesModule ) {
    Write-Log "Installing PowerShell PSDscResources module..."

    try {
        Install-Module -Name PSDscResources -AllowClobber -Scope AllUsers
    }
    catch {
        Exit-WithError $_
    }
}
else {
    Write-Log "PowerShell PSDscResources module is already installed..."
}

$ActiveDirectoryDscModule = Get-Module -ListAvailable -Name ActiveDirectoryDsc

if ($null -eq $ActiveDirectoryDscModule ) {
    Write-Log "Installing PowerShell ActiveDirectoryDsc module..."

    try {
        Install-Module -Name ActiveDirectoryDsc -AllowClobber -Scope AllUsers
    }
    catch {
        Exit-WithError $_
    }
}
else {
    Write-Log "PowerShell ActiveDirectoryDsc module is already installed..."
}

$scriptCommand = "$PSScriptRoot\adds-config.ps1 -Domain $Domain"

Write-Log "Running '$scriptCommand'..."
Invoke-Expression $scriptCommand

Write-Log "Exiting normally..."
Exit

param (
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

function Get-AdminCredential {
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

    return $adminCredential
}

# Start main
Write-Log "Running '$PSCommandPath'..."

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

# Configure AD DS
$scriptPath = "$PSScriptRoot\adds-config.ps1"
$jobName = "LabDomainConfig"
$adminCredential = Get-AdminCredential

Write-Log "Starting background job '$jobName'..."
try {
    $job = Start-Job -Name $jobName -Credential $adminCredential -FilePath $scriptPath -Authentication Basic -ArgumentList $Domain, $PSScriptRoot 
}
catch {
    Exit-WithError $_
}

if ($job.State -eq 'Failed') {
    Write-Log "Background job '$jobName' with InstanceId '$($job.InstanceId)' failed..."
    Exit-WithError $job.JobStateInfo.Reason
}

Write-Log "Exiting normally..."
Exit

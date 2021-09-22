param(
    [Parameter(Mandatory = $true)]
    [string]$Domain,

    [Parameter(Mandatory = $true)]
    [string]$Username,
    
    [Parameter(Mandatory = $true)]
    [string]$UsernameSecret
)
#region contants
$logpath = $PSCommandPath + '.log'
$scriptName = 'sql-bootstrap.ps1'
#endregion

#region fucntions
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
#endregion

#region main
Write-Log "Running '$PSCommandPath'..."
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
Write-Log "Current user '$currentUser'..."


# Launch sql-bootstrap.ps1 with elevated privileges
$domainUsername = $Domain.Split('.')[0] + '\' + $Username
$usernameSecretSecure = ConvertTo-SecureString $UsernameSecret -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $domainUsername, $usernameSecretSecure
$scriptPath = "$PSScriptRoot\$scriptName"
Write-Log "Starting script '$scriptName' as '$($credential.UserName)'..."

try {
    Start-Process `
        -FilePath "PowerShell.exe" `
        -ArgumentList "-ExecutionPolicy Unrestricted -File $scriptPath" `
        -Credential $credential `
        -WorkingDirectory $PSScriptRoot `
        -Verb RunAs `
        -Wait `
        -ErrorAction Stop
}
catch {
    Exit-WithError $_
}

Write-Log "Exiting normally..."
Exit 0
#endregion

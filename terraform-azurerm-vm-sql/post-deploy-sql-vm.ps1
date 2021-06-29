# Launches sql-bootstrap.ps1 with elevated privileges

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
Write-Log "Running '$PSCommandPath'..."
$scriptPath = "$PSScriptRoot\sql-bootstrap.ps1"
Write-Log "Starting '$scriptPath'..."

try {
    Start-Process -FilePath "PowerShell.exe" -ArgumentList "-ExecutionPolicy Unrestricted -File $scriptPath" -WorkingDirectory $PSScriptRoot -Verb RunAs -Wait
}
catch {
    Exit-WithError $_
}

Write-Log "Exiting normally..."
Exit

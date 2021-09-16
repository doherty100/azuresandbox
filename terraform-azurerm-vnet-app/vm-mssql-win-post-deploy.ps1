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
    $process = Start-Process `
        -FilePath "PowerShell.exe" `
        -ArgumentList "-ExecutionPolicy Unrestricted -File $scriptPath" `
        -WorkingDirectory $PSScriptRoot `
        -Verb RunAs `
        -Wait `
        -ErrorAction Stop
}
catch {
    Exit-WithError $_
}

if ($process.ExitCode -ne 0)
{
    Exit-WithError "Script '$scriptPath' returned exit code '$($process.ExitCode)'..."
}

Write-Log "Exiting normally..."
Exit

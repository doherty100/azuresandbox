param (
    [Parameter(Mandatory = $true)]
    [String]$TenantId,

    [Parameter(Mandatory = $true)]
    [String]$SubscriptionId,

    [Parameter(Mandatory = $true)]
    [String]$AppId,

    [Parameter(Mandatory = $true)]
    [string]$AppSecret,

    [Parameter(Mandatory = $true)]
    [String]$ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,

    [Parameter(Mandatory = $true)]
    [string]$StorageAccountKerbKey,

    [Parameter(Mandatory = $true)]
    [string]$Domain,

    [Parameter(Mandatory = $true)]
    [string]$AdminUser,

    [Parameter(Mandatory = $true)]
    [string]$AdminUserSecret
)

#region constants
$TaskName = 'configure-storage-kerberos'
$MaxTaskAttempts = 12
#endregion

#region functions
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
$logpath = $PSCommandPath + '.log'
Write-Log "Running '$PSCommandPath'..."

# Register scheduled task to configure Azure Storage for kerberos authentication with domain
$scriptPath = "$((Get-Item $PSCommandPath).DirectoryName)\$TaskName.ps1"
$domainAdminUser = $Domain.Split('.')[0].ToUpper() + "\" + $AdminUser
# $adminSecretSecure = ConvertTo-SecureString -String $AdminUserSecret -AsPlainText -Force
# $adminSecretSecure.MakeReadOnly()

if ( -not (Test-Path $scriptPath) ) {
    Exit-WithError "Unable to locate '$scriptPath'..."
}

Write-Log "Registering task '$TaskName' to run '$scriptPath' as '$domainAdminUser'..."

$commandParamParts = @(
    '$params = @{',
      "TenantId = '$TenantId'; ", 
      "SubscriptionId = '$SubscriptionId'; ", 
      "AppId = '$AppId'; ",
      "AppSecret = '$AppSecret'; ",
      "ResourceGroupName = '$ResourceGroupName'; ",
      "StorageAccountName = '$StorageAccountName'; ",
      "StorageAccountKerbKey = '$StorageAccountKerbKey'; ",
      "Domain = '$Domain'",
    '}'
)

$taskAction = New-ScheduledTaskAction `
    -Execute 'powershell.exe' `
    -Argument "-ExecutionPolicy Unrestricted -Command `"$($commandParamParts -join ''); . $scriptPath @params`""

try {
    Register-ScheduledTask `
        -Force `
        -Password $AdminUserSecret `
        -User $domainAdminUser `
        -TaskName $TaskName `
        -Action $taskAction `
        -RunLevel 'Highest' `
        -Description "Configure Azure Storage for kerberos authentication with domain." `
        -ErrorAction Stop
}
catch {
    Exit-WithError $_
}

Write-Log "Starting task '$TaskName'..."

try {
    Start-ScheduledTask -TaskName $TaskName -ErrorAction Stop
}
catch {
    Exit-WithError $_
}

$i=0

do {
    $i++

    Start-Sleep 10

    try {
        $taskInfo = Get-ScheduledTaskInfo -TaskName $TaskName
    }
    catch {
        Exit-WithError $_
    }

    $lastTaskResult = $taskInfo.LastTaskResult

    if ($null -eq $lastTaskResult) {
        Write-Log "Waiting for '$TaskName' to complete (attempt $i of $MaxTaskAttempts)..."
        continue
    }

    if ($lastTaskResult -eq 0 ) {
        Write-Log "Task '$TaskName' completed with a return code of 0..."
        break
    }
    else {
        Exit-WithError "Task '$TaskName' exited with non-zero return code '$lastTaskResult'..."
    }
} while ($i -lt $MaxTaskAttempts)

Write-Log "Exiting normally..."
Exit 0

#endregion

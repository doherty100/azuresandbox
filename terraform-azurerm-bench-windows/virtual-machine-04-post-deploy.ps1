$logpath = $PSCommandPath + '.log'

# Function to write to log file
function Write-Log {
    param($msg)
    "$(Get-Date -Format G) : $msg" | Out-File -FilePath $logpath -Append -Force
}

Write-Log "Running: $PSCommandPath..."

# Initialize data disks

Write-Log "Looking for raw disks.."

$disks = Get-Disk | Where-Object partitionstyle -eq 'raw' | sort number

if ( $null -ne $disks ) {
    Write-Log $disks
}
else {
    Write-Log 'No raw disks found.'
}

$letters = 70..89 | ForEach-Object { [char]$_ }
$count = 0

foreach ($disk in $disks) {
    $driveLetter = $letters[$count].ToString()

    Write-Log "Initializing disk..."
    Write-Log $disk

    try {
        $disk | 
        Initialize-Disk -PartitionStyle MBR -PassThru | 
        New-Partition -UseMaximumSize -DriveLetter $driveLetter |
        Format-Volume -FileSystem NTFS -NewFileSystemLabel $driveLetter -Confirm:$false -Force
    }
    catch {
        $ErrorMessage = $_
        Write-Log "There was an exception during the process, please review"
        Write-Log "$ErrorMessage"
        Exit 2
    }
    
    $count++
}

Write-Log "Exiting normally..."

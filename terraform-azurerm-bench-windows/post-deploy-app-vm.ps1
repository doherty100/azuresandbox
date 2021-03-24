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

function Get-DataDisks {
    $sleepSeconds = 60
    $maxAttempts = 5

    for ($currentAttempt = 1; $currentAttempt -lt $maxAttempts; $currentAttempt++) {
        Write-Log "Querying Azure instance metadata service for virtual machine storageProfile, attempt '$currentAttempt' of '$maxAttempts'..."

        try {
            $storageProfile = Invoke-RestMethod -Headers @{"Metadata" = "true" } -Method GET -Uri http://169.254.169.254/metadata/instance/compute/storageProfile?api-version=2020-06-01
        }
        catch {
            Exit-WithError $_
        }

        if ($null -eq $storageProfile) {
            Exit-WithError "Azure instance metadata service did not return a storage profile..."
        }

        if ($storageProfile.dataDisks.Count -gt 0) {
            break
        }

        if (($storageProfile.dataDisks.Count -eq 0) -and ($currentAttempt -lt $maxAttempts)) {
            Write-Log "Waiting for Azure instance metadata service to refresh for '$sleepSeconds' seconds..."
            Start-Sleep -Seconds $sleepSeconds
        }
    }

    return $storageProfile.dataDisks
}

# Start main
Write-Log "Running: $PSCommandPath..."

# Initialize data disks
$localRawDisks = Get-Disk | Where-Object PartitionStyle -eq 'RAW'

if ($null -eq $localRawDisks ) {
    Write-Log "No local raw disks found..."
    Write-Log "Exiting normally..."
    Exit
}

if ($null -eq $localRawDisks.Count) {
    Write-Log "Located 1 local raw disk..."
}
else {
    Write-Log "Located $($localRawDisks.Count) local raw disks..."    
}

foreach ( $disk in $localRawDisks ) {
    Write-Log "$('=' * 80)"
    Write-Log "Local disk DiskNumber -----: $($disk.DiskNumber)"
    Write-Log "Local disk UniqueId -------: $($disk.UniqueId)"
    Write-Log "Local disk PartitionStyle -: $($disk.PartitionStyle)"
    Write-Log "Local disk Size -----------: $($disk.Size / 1Gb) Gb"
    Write-Log "Local disk Location -------: $($disk.Location)"
    Write-Log "Local disk BusType --------: $($disk.BusType)"
}

Write-Log "$('=' * 80)"

$azureDataDisks = Get-DataDisks

if (($null -eq $azureDataDisks) -or ($azureDataDisks.Count -eq 0)) {
    Write-Log "No attached Azure data disks found..."
    Write-Log "Exiting normally..."
    Exit
}

if ($null -eq $azureDataDisks.Count) {
    Write-Log "Located 1 attached Azure data disk..."
}
else {
    Write-Log "Located $($azureDataDisks.Count) attached Azure data disks..."
}

foreach ( $azureDataDisk in $azureDataDisks ) {
    Write-Log "$('=' * 80)"
    Write-Log "Azure data disk name ------: $($azureDataDisk.name)"
    Write-Log "Azure data disk size ------: $($azureDataDisk.diskSizeGb) Gb"
    Write-Log "Azure data disk LUN -------: $($azureDataDisk.lun)"
}

# Partition and format disks
foreach ($disk in $localRawDisks) {
    Write-Log "$('=' * 80)"

    $lun = $disk.Location.Split(":").Trim() -match 'LUN' -replace 'LUN ', ''
    
    if ($null -eq $azureDataDisks.Count) {
        $azureDataDisk = $azureDataDisks

        if ($azureDataDisk.lun -ne $lun) {
            Exit-WithError "Unable to locate Azure data disk with LUN '$lun'..."
        }
    }
    else {
        $azureDataDisk = $azureDataDisks | Where-Object lun -eq $lun

        if ($null -eq $azureDataDisk) {
            Exit-WithError "Unable to locate Azure data disk with LUN '$lun'..."
        }
    }

    $partitionStyle = "GPT"
    Write-Log "Initializing disk '$($disk.UniqueId)' using parition style '$partitionStyle'..."
    
    try {
        Initialize-Disk -UniqueId $disk.UniqueId -PartitionStyle $partitionStyle -Confirm:$false | Out-Null
    }
    catch {
        Exit-WithError $_
    }

    $fileSystemLabel = $azureDataDisk.name.Split("-").Trim()[2]
    $driveLetter = $fileSystemLabel.Substring($fileSystemLabel.Length - 1, 1)

    Write-Log "Partitioning disk '$($disk.UniqueId)' using maximum volume size '$($azureDataDisk.diskSizeGb)' Gb and drive letter '$($driveLetter):'..."

    try {
        New-Partition -DiskId $disk.UniqueId -UseMaximumSize -DriveLetter $driveLetter | Out-Null
    }
    catch {
        Exit-WithError $_
    }

    $fileSystem = "NTFS"
    
    Write-Log "Formatting volume '$($driveLetter):' using file system '$fileSystem' and label '$fileSystemLabel'..."

    try {
        Format-Volume -DriveLetter $driveLetter -FileSystem $fileSystem -NewFileSystemLabel $fileSystemLabel -Confirm:$false -Force | Out-Null
    }
    catch {
        Exit-WithError $_
    }
}

Write-Log "$('=' * 80)"

Write-Log "Exiting normally..."
Exit

$logpath = $PSCommandPath + '.log'

function Write-Log {
    param($msg)
    "$(Get-Date -Format FileDateTimeUniversal) : $msg" | Out-File -FilePath $logpath -Append -Force
}

function Exit-WithError {
    param($msg)
    Write-Log "There was an exception during the process, please review..."
    Write-Log $msg
    Exit 2
}

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

$azModule = Get-Module -ListAvailable -Name Az*

if ($null -eq $azModule ) {
    Write-Log "Installing PowerShell Az module..."

    try {
        Install-Module -Name Az -AllowClobber -Scope AllUsers
    }
    catch {
        Exit-WithError $_
    }
}
else {
    Write-Log "PowerShell Az module is already installed..."
}

$azComputeMachineModule = Get-Module -ListAvailable -Name Az.Compute
Write-Log "PowerShell Az.Compute version $($azComputeMachineModule.Version) is installed..."

# Initialize data disks

$localRawDisks = Get-Disk | Where-Object PartitionStyle -eq 'RAW'

if ($null -eq $localRawDisks ) {
    Write-Log "No local raw disks found, skipping data disk initialization and formatting..."
}
else {
    if ($null -eq $localRawDisks.Count ) {
        Write-Log "Located 1 local raw disks..."
    }
    else {
        Write-Log "Located $($localRawDisks.Count) local raw disks..."
    }

    $localRawDiskIndex = 0

    foreach ( $localRawDisk in $localRawDisks) {
        Write-Log "Local disk index ----------: $localRawDiskIndex"
        Write-Log "Local disk DiskNumber -----: $($localRawDisk.DiskNumber)"
        Write-Log "Local disk UniqueId -------: $($localRawDisk.UniqueId)"
        Write-Log "Local disk PartitionStyle -: $($localRawDisk.PartitionStyle)"
        Write-Log "Local disk Size -----------: $($localRawDisk.Size / [Math]::Pow(1024,3)) Gb"
        Write-Log "Local disk Location -------: $($localRawDisk.Location)"
        Write-Log "Local disk LUN ------------: $($localRawDisk.Location.Split(":").Trim()[4] -replace 'LUN ','')"
        Write-Log "Local disk BusType --------: $($localRawDisk.BusType)"
        $localRawDiskIndex ++    
    }

    # Get Azure data disk storage profile

    Write-Log "Querying Azure instance metadata service for virtual machine storageProfile..."

    try {
        $storageProfile = Invoke-RestMethod -Headers @{"Metadata" = "true" } -Method GET -Uri http://169.254.169.254/metadata/instance/compute/storageProfile?api-version=2020-06-01
        $azureDataDisks = $storageProfile.dataDisks
    }
    catch {
        Exit-WithError $_
    }

    Write-Log "Located $($azureDataDisks.Count) attached Azure data disks..."
    $azureDiskIndex = 0

    foreach ( $azureDataDisk in $azureDataDisks ) {
        Write-Log "Azure data disk index -----: $azureDiskIndex"
        Write-Log "Azure data disk name ------: $($azureDataDisk.name)"
        Write-Log "Azure data disk size ------: $($azureDataDisk.diskSizeGb) Gb"
        Write-Log "Azure data disk LUN -------: $($azureDataDisk.lun)"
        $azureDiskIndex ++
    }

    # Partition and format disks

    $count = 0

    foreach ($disk in $localRawDisks) {
        $lun = $disk.Location.Split(":").Trim()[4] -replace 'LUN ', ''
        $azureDataDisk = $azureDataDisks | Where-Object lun -eq $lun
        $partitionStyle = "GPT"

        Write-Log "Initializing disk '$($disk.UniqueId)' using parition style '$partitionStyle'..."
        
        try {
            Initialize-Disk -UniqueId $disk.UniqueId -PartitionStyle $partitionStyle
        }
        catch {
            Exit-WithError $_
        }

        $azureDataDiskName = $azureDataDisk.name
        $fileSystemLabel = $azureDataDiskName.Split("-").Trim()[2]
        $driveLetter = $fileSystemLabel.Substring($fileSystemLabel.Length - 1, 1)

        Write-Log "Partitioning disk '$($disk.UniqueId)' using maximum volume size '$($azureDataDisk.diskSizeGb)' Gb and drive letter '$($driveLetter):'..."

        try {
            New-Partition -DiskId $disk.UniqueId -UseMaximumSize -DriveLetter $driveLetter 
        }
        catch {
            Exit-WithError $_
        }

        $fileSystem = "NTFS"

        Write-Log "Formatting volume '$($driveLetter):' using file system '$fileSystem' and label '$fileSystemLabel'..."

        try {
            Format-Volume -DriveLetter $driveLetter -FileSystem $fileSystem -NewFileSystemLabel $fileSystemLabel -Confirm:$false -Force
        }
        catch {
            Exit-WithError $_
        }

        $count++
    }
}

Write-Log "Exiting normally..."
Exit

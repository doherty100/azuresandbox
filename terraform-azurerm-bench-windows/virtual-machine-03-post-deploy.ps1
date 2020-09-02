$logpath = $PSCommandPath + '.log'

# Function to write to log file
function Write-Log
{
	param($msg)
	"$(Get-Date -Format FileDateTimeUniversal) : $msg" | Out-File -FilePath $logpath -Append -Force
}

Write-Log "Running: $PSCommandPath..."

# Install PowerShell prerequisites for using the SQL Server IaaS agent extension

Write-Log "Install NuGet provider..."

try 
{
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force 
}
catch 
{
    $ErrorMessage = $_
    Write-Log "There was an exception during the process, please review"
    Write-Log "$ErrorMessage"
    Exit 2
}

Write-Log "Set PSGallery as a trusted repository..."

try 
{
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted    
}
catch 
{
    $ErrorMessage = $_
    Write-Log "There was an exception during the process, please review"
    Write-Log "$ErrorMessage"
    Exit 2    
}

Write-Log "Installing Azure PowerShell module..."

try 
{
    Install-Module -Name Az -AllowClobber -Scope AllUsers
}
catch
{
    $ErrorMessage = $_
    Write-Log "There was an exception during the process, please review"
    Write-Log "$ErrorMessage"
    Exit 2
}

# Get local raw disks

Write-Log "Looking for local raw disks..."

$localRawDisks = Get-Disk | Where PartitionStyle -EQ 'RAW'

Write-Log "Located $($localRawDisks.Count) local raw disks...`n"

$localRawDiskIndex = 0

foreach( $localRawDisk in $localRawDisks) {
    Write-Log "Local disk index ----------: $localRawDiskIndex"
    Write-Log "Local disk DiskNumber -----: $($localRawDisk.DiskNumber)"
    Write-Log "Local disk UniqueId -------: $($localRawDisk.UniqueId)"
    Write-Log "Local disk PartitionStyle -: $($localRawDisk.PartitionStyle)"
    Write-Log "Local disk Size -----------: $($localRawDisk.Size / [Math]::Pow(1024,3)) Gb"
    Write-Log "Local disk Location -------: $($localRawDisk.Location)"
    Write-Log "Local disk LUN ------------: $($localRawDisk.Location.Split(":").Trim()[4] -replace 'LUN ','')"
    Write-Log "Local disk BusType --------: $($localRawDisk.BusType)`n"
    
    $localRawDiskIndex ++    
}

# Get Azure data disk storage profile

Write-Log "Querying Azure instance metadata service for VM storageProfile..."

try {
    $storageProfile = Invoke-RestMethod -Headers @{"Metadata"="true"} -Method GET -Uri http://169.254.169.254/metadata/instance/compute/storageProfile?api-version=2020-06-01
    $azureDataDisks = $storageProfile.dataDisks
}
catch {
    $ErrorMessage = $_
    Write-Log "There was an exception during the process, please review"
    Write-Log "$ErrorMessage"
    Exit 2
}

Write-Log "Located $($azureDataDisks.Count) attached Azure data disks...`n"

$azureDiskIndex = 0

foreach( $azureDataDisk in $azureDataDisks ) {
    Write-Log "Azure data disk index -----: $azureDiskIndex"
    Write-Log "Azure data disk name ------: $($azureDataDisk.name)"
    Write-Log "Azure data disk size ------: $($azureDataDisk.diskSizeGb) Gb"
    Write-Log "Azure data disk LUN -------: $($azureDataDisk.lun)`n"
    
    $azureDiskIndex ++
}

$letters = 70..89 | ForEach-Object { [char]$_ }
$count = 0

foreach ($disk in $localRawDisks) 
{
    Write-Log "Initializing and formatting raw disk UniqueId $($disk.UniqueId)..."

    $partitionStyle = "GPT"
    Write-Log "Using PartitionStyle $($partitionStyle)..."

    $fileSystem = "NTFS"
    Write-Log "Using FileSytem $($fileSystem)..."

    $driveLetter = $letters[$count].ToString()
    Write-Log "Using drive letter $($driveLetter)..."

    $allocationUnitSize = 65536
    Write-Log "Using allocationUnitSize $($allocationUnitSize)..."

    $lun = $disk.Location.Split(":").Trim()[4] -replace 'LUN ',''
    $azureDataDisk = $azureDataDisks | Where lun -EQ $lun
    
    $fileSystemLabel = $azureDataDisk.name

    Write-Log "Using fileSystemLabel $($fileSystemLabel)..."
    
    try 
    {
        $disk | 
            Initialize-Disk -PartitionStyle $partitionStyle -PassThru | 
            New-Partition -UseMaximumSize -DriveLetter $driveLetter |
            Format-Volume -FileSystem $fileSystem -NewFileSystemLabel $fileSystemLabel -AllocationUnitSize $allocationUnitSize -Confirm:$false -Force
        
    }
    catch
    {
        $ErrorMessage = $_
        Write-Log "There was an exception during the process, please review..."
        Write-Log "$ErrorMessage"
        Exit 2
    }

    Write-Log "Disk UniqueId $($disk.UniqueId) initialized and formatted...`n"
    
    $count++
}

Write-Log "Exiting normally..."

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

function Restart-SqlServer {
    Write-Log "Restarting SQL Server..."
        
    try {
        Stop-Service -Name SQLSERVERAGENT
        Stop-Service -Name MSSQLLaunchpad
        Stop-Service -Name MSSQLSERVER
        Start-Service -Name MSSQLSERVER
        Start-Service -Name MSSQLLaunchpad
        Start-Service -Name SQLSERVERAGENT
    }
    catch {
        Exit-WithError $_
    }        
}

function Invoke-Sql {
    param([string]$SqlCommand, [string]$User, [SecureString]$Password)

    $cred = New-Object System.Data.SqlClient.SqlCredential($User, $Password)
    $cxnstring = New-Object System.Data.SqlClient.SqlConnectionStringBuilder
    $cxnstring."Data Source" = '.'
    $cxnstring."Initial Catalog" = 'master'
    $cxn = New-Object System.Data.SqlClient.SqlConnection($cxnstring, $cred)

    try {
        $cxn.Open()
    }
    catch {
        Exit-WithError $_
    }

    $cmd = $cxn.CreateCommand()
    $cmd.CommandText = $SqlCommand

    try {
        $cmd.ExecuteNonQuery()
    }
    catch {
        Exit-WithError $_
    }      
        
    $cxn.Close()
}

Write-Log "Running: $PSCommandPath..."

# Install PowerShell prerequisites for using the SQL Server IaaS agent extension

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

$azSqlVirtualMachineModule = Get-Module -ListAvailable -Name Az.SqlVirtualMachine
Write-Log "PowerShell Az.SqlVirtualMachine version $($azSqlVirtualMachineModule.Version) is installed..."

# Get Azure data disk storage profile

Write-Log "Querying Azure instance metadata service for virtual machine storageProfile..."

try {
    $storageProfile = Invoke-RestMethod -Headers @{"Metadata" = "true" } -Method GET -Uri http://169.254.169.254/metadata/instance/compute/storageProfile?api-version=2020-06-01
    $azureDataDisks = $storageProfile.dataDisks
}
catch {
    Exit-WithError $_
}

Write-Log "$('=' * 80)"
Write-Log "Located $($azureDataDisks.Count) attached Azure data disks..."
$azureDiskIndex = 0

foreach ( $azureDataDisk in $azureDataDisks ) {
    Write-Log "$('=' * 80)"
    Write-Log "Azure data disk index -----: $azureDiskIndex"
    Write-Log "Azure data disk name ------: $($azureDataDisk.name)"
    Write-Log "Azure data disk size ------: $($azureDataDisk.diskSizeGb) Gb"
    Write-Log "Azure data disk LUN -------: $($azureDataDisk.lun)"
    $azureDiskIndex ++
}

Write-Log "$('=' * 80)"

# Initialize data disks

$localRawDisks = Get-Disk | Where-Object PartitionStyle -eq 'RAW'

if ($null -eq $localRawDisks ) {
    Write-Log "No local raw disks found, skipping data disk preparation..."
}
else {
    Write-Log "Located $($localRawDisks.Count) local raw disks..."

    # Partition and format disks

    $count = 0

    foreach ($disk in $localRawDisks) {
        $lun = $disk.Location.Split(":").Trim()[4] -replace 'LUN ', ''
        $sizeGb = $disk.Size / [Math]::Pow(1024,3)
        
        Write-Log "$('=' * 80)"
        Write-Log "Local disk index ----------: $count"
        Write-Log "Local disk DiskNumber -----: $($disk.DiskNumber)"
        Write-Log "Local disk UniqueId -------: $($disk.UniqueId)"
        Write-Log "Local disk PartitionStyle -: $($disk.PartitionStyle)"
        Write-Log "Local disk Size -----------: $sizeGb Gb"
        Write-Log "Local disk Location -------: $($disk.Location)"
        Write-Log "Local disk LUN ------------: $lun"
        Write-Log "Local disk BusType --------: $($disk.BusType)"
        
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

        Write-Log "Partitioning disk '$($disk.UniqueId)' using maximum volume size '$($azureDataDisk.diskSizeGb)' Gb and drive letter '$driveLetter':..."

        try {
            New-Partition -DiskId $disk.UniqueId -UseMaximumSize -DriveLetter $driveLetter 
        }
        catch {
            Exit-WithError $_
        }

        $fileSystem = "NTFS"
        $allocationUnitSize = 65536

        Write-Log "Formatting volume '$($driveLetter):' using file system '$fileSystem', label '$fileSystemLabel' and allocation unit size '$allocationUnitSize'..."

        try {
            Format-Volume -DriveLetter $driveLetter -FileSystem $fileSystem -NewFileSystemLabel $fileSystemLabel -AllocationUnitSize $allocationUnitSize -Confirm:$false -Force
        }
        catch {
            Exit-WithError $_
        }

        $count++
    }
}

Write-Log "$('=' * 80)"

# Get admin credentials

Write-Log "Getting virtual machine tags..."

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
Write-Log "Getting token using virtual machine managed identity..."

try {
    $token = (Invoke-RestMethod -Headers @{"Metadata" = "true" } -Method GET -Uri 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2020-06-01&resource=https%3A%2F%2Fvault.azure.net').access_token
}
catch {
    Exit-WithError $_
}

Write-Log "Retrieving adminuser secret from key vault..."
$secretName = "adminuser"

try {
    $secret = Invoke-RestMethod -Headers @{Authorization = "Bearer $token" } -Method GET -Uri "https://$kvname.vault.azure.net/secrets/$($secretName)?api-version=2016-10-01"
}
catch {
    Exit-WithError $_
}

$adminUser = $secret.Value
Write-Log "Using adminuser '$adminUser'..."
Write-Log "Retrieving adminpassword secret from key vault..."
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

# Configure data disks

Write-Log "$('=' * 80)"
Write-Log "Configuring data disks..."

$volumes = Get-Volume
$volumeIndex = -1

foreach ( $volume in $volumes) {
    $volumeIndex ++ 
    Write-Log "$('=' * 80)"
    Write-Log "Volume index -------------: $volumeIndex"
    Write-Log "Volume DriveLetter -------: $($volume.DriveLetter)"
    Write-Log "Volume FileSystemLabel ---: $($volume.FileSystemLabel)"
    Write-Log "Volume FileSystemType ----: $($volume.FileSystemType)"
    Write-Log "Volume DriveType ---------: $($volume.DriveType)"
    
    if ( $volume.FileSystemLabel -in @( 'System Reserved', 'Windows' ) ) {
        Write-Log "Skipping FileSystemLabel '$($volume.FileSystemLabel)'..."
        continue 
    }

    if ( $volume.DriveType -in @( 'CD-ROM', 'Removable' ) ) {
        Write-Log "Skipping DriveType '$($volume.DriveType)'..."
        continue 
    }

    if ( $volume.FileSystemLabel -eq "Temporary Storage" ) {
        Write-Log "Ephemeral (temporary) drive located at $path..."
        $path = "$($volume.DriveLetter):\SQLTEMP"

        if ( -not ( Test-Path $path ) ) {
            try {
                Write-Log "Creating $($path)..."
                New-Item -ItemType Directory -Path $path -Force 
            }
            catch {
                Exit-WithError $_
            }
        }

        $filePath = "$path\tempdb.mdf"
        $sqlCommand = "ALTER DATABASE tempdb MODIFY FILE ( NAME = tempdev, FILENAME = N'$filePath' );"
        Write-Log "Altering tempdb and setting database file location to '$filePath'..."
        Invoke-Sql $sqlCommand $adminUser $adminPasswordSecure
        $filePath = "$path\templog.ldf"
        $sqlCommand = "ALTER DATABASE tempdb MODIFY FILE ( NAME = templog, FILENAME = N'$filePath' ) "
        Write-Log "Altering tempdb and setting log file location to '$filePath'..."
        Invoke-Sql $sqlCommand $adminUser $adminPasswordSecure
        Restart-SqlServer                        
        continue 
    }

    # Create SQL Server data and log directories if they don't already exist

    $sqlPath = $null

    switch -Wildcard ( $volume.FileSystemLabel ) {
        '*sqldata*' {
            $sqlPath = "$($volume.DriveLetter):\MSSQL\DATA"
        }
        '*sqllog*' {
            $sqlPath = "$($volume.DriveLetter):\MSSQL\LOG"
        }
    }

    if ( ( $null -ne $sqlPath )  -and ( -not ( Test-Path $sqlPath ) )) {
        Write-Log "Creating $($sqlPath)..."

        try {
            New-Item -ItemType Directory -Path $sqlPath -Force 
        }
        catch {
            Exit-WithError $_
        }
    }

    # Check alignment of drive letters

    $azureDataDisk = $azureDataDisks | Where-Object name -like "*$($volume.FileSystemLabel)*"

    if ( $null -ne $azureDataDisks ) {
        $azureDataDiskName = $azureDataDisk.name
        $azureFileSystemLabel = $azureDataDiskName.Split("-").Trim()[2]
        $azureDriveLetter = $azureFileSystemLabel.Substring($azureFileSystemLabel.Length - 1, 1)

        if ( $volume.DriveLetter -ne $azureDriveLetter ) {
            Write-Log "Changing drive letter for volume '$($volume.FileSystemLabel)' from '$($volume.DriveLetter)' to '$azureDriveLetter'..."

            try {
                 Set-Partition -DriveLetter $volume.DriveLetter -NewDriveLetter $azureDriveLetter
            }
            catch {
                Exit-WithError $_
            }
        }
    }

    continue
}

Write-Log "$('=' * 80)"

# Set SQL for manaual startup 

Write-Log "Configuring SQL Server services for manual startup..."

try {
    Set-Service -Name MSSQLSERVER -StartupType Manual
    Set-Service -Name SQLSERVERAGENT -StartupType Manual
}
catch {
    Exit-WithError $_
}

# Register scheduled task to recreate SQL Server tempdb folders on ephemeral drive

$taskName = "SQL-startup"
$sqlStartupScriptPath = "$((Get-Item $PSCommandPath).DirectoryName)\$taskName.ps1"

if ( -not (Test-Path $sqlStartupScriptPath) ) {
    Exit-WithError "Unable to locate '$sqlStartupScriptPath'..."
}

$taskAction = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-ExecutionPolicy Unrestricted -File `"$sqlStartupScriptPath`"" 
$taskTrigger = New-ScheduledTaskTrigger -AtStartup

Write-Log "Registering scheduled task to execute '$sqlStartupScriptPath'..."

try {
    Register-ScheduledTask -TaskName $taskName -Action $taskAction -Trigger $taskTrigger -Force -User 'System' -RunLevel 'Highest' -Description "Prepare ephemeral drive folders for tempdb and start SQL Server."
}
catch {
    Exit-WithError $_
}

Write-Log "Exiting normally..."
Exit

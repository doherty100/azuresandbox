$logpath = $PSCommandPath + '.log'

# Function to write to log file
function Write-Log
{
	param($msg)
	"$(Get-Date -Format G) : $msg" | Out-File -FilePath $logpath -Append -Force
}

Write-Log "Running: $PSCommandPath..."

# Initialize data disks

Write-Log "Looking for raw disks.."

$disks = Get-Disk | Where partitionstyle -eq 'raw' | sort number

if ($disks -ne $null)
{
    Write-Log $disks
}
else
{
    Write-Log 'No raw disks found.'
}

$letters = 70..89 | ForEach-Object { [char]$_ }
$count = 0

foreach ($disk in $disks) 
{
    $driveLetter = $letters[$count].ToString()

    Write-Log "Initializing disk..."
    Write-Log $disk

    try 
    {
        $disk | 
            Initialize-Disk -PartitionStyle MBR -PassThru | 
            New-Partition -UseMaximumSize -DriveLetter $driveLetter |
            Format-Volume -FileSystem NTFS -NewFileSystemLabel $driveLetter -Confirm:$false -Force
    }
    catch
    {
        $ErrorMessage = $_
        Write-Log "There was an exception during the process, please review"
        Write-Log "$ErrorMessage"
        Exit 2
    }
    
    $count++
}

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

Write-Log "Installing StorageDsc PowerShell module..."

try 
{
    Install-Module -Name StorageDsc -AllowClobber -Scope AllUsers
}
catch
{
    $ErrorMessage = $_
    Write-Log "There was an exception during the process, please review"
    Write-Log "$ErrorMessage"
    Exit 2
}

Write-Log "Exiting normally..."

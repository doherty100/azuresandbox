#Set Variables
$SharedFolderName = "MAC01"
$SharedFolderName = $SharedFolderName.ToLower()
$SharedFolderQuota = "100"
$SharedFolderChangeGroup = "SFS-SFS-MAC-C"
$SharedFolderReadGroup = "SFS-SFS-MAC-R"
$SharedFolderAccessTier = "TransactionOptimized" #Other options: "Hot", "Cool" 

$AzureSubscription = "b9162eca-49f5-4ab5-ab7f-b6e3881d5d2a"
$resourceGroupName = "core-northeurope-sfs-rg"
$storageAccountName = "coreazefs01stor"
$storageAccountFQDN = "coreazefs01stor.file.core.windows.net"


#Log into Azure
Login-AzAccount #This will launch an SSO logon window

#Set Azure Subscription
Select-AzSubscription -Subscription $AzureSubscription

#Create file share
# Assuming $resourceGroupName and $storageAccountName from earlier in this document have already
# been populated. The access tier parameter may be TransactionOptimized, Hot, or Cool for GPv2 
# storage accounts. Standard tiers are only available in standard storage accounts. 

$CreateShare = New-AzRmStorageShare `
        -ResourceGroupName $resourceGroupName `
        -StorageAccountName $storageAccountName `
        -Name $SharedFolderName `
        -AccessTier $SharedFolderAccessTier `
        -QuotaGiB $SharedFolderQuota | `
    Out-Default

#Mount file share
$connectTestResult = Test-NetConnection -ComputerName $storageAccountFQDN -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Mount the drive
    New-PSDrive -Name V -PSProvider FileSystem -Root "\\$storageAccountFQDN\$SharedFolderName" -Persist
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}

#The following is not yet working, need to investigate
#It contains hard coded groups for testing purposes

#Assign permissions
#-------------------------------------#
$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]::ContainerInherit -bor [System.Security.AccessControl.InheritanceFlags]::ObjectInherit
$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
# Allow access to this object
$objType =[System.Security.AccessControl.AccessControlType]::Allow 

# Add change group
#$colRights = [System.Security.AccessControl.FileSystemRights]"Modify, ReadAndExecute, ListDirectory, Read, Write, Synchronize"
$colRights = [System.Security.AccessControl.FileSystemRights]"Modify, ReadAndExecute, ListDirectory, Read, Write, Synchronize" 
$objUser = New-Object System.Security.Principal.NTAccount($SharedFolderChangeGroup) 
$objACE = New-Object System.Security.AccessControl.FileSystemAccessRule ($objUser, $colRights, $InheritanceFlag, $PropagationFlag, $objType) 
$objACL = Get-ACL V:\
$objACL.AddAccessRule($objACE) 

Set-ACL -Path "V:\" $objACL


# Add read group
$colRights = [System.Security.AccessControl.FileSystemRights]"ReadAndExecute, Read, Synchronize" 
$objUser = New-Object System.Security.Principal.NTAccount($SharedFolderReadGroup) 
$objACE = New-Object System.Security.AccessControl.FileSystemAccessRule ($objUser, $colRights, $InheritanceFlag, $PropagationFlag, $objType) 
$objACL = Get-ACL V:
$objACL.AddAccessRule($objACE) 

Set-ACL V: $objACL



#Create/update DFS Link


#Unmount file share

#Install-Module -Name Az -Scope CurrentUser

#[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


#Get-InstalledModule

#update-Module -Name Az.Storage 

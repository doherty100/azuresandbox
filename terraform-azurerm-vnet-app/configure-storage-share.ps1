Import-Module -Name ActiveDirectory

$ResourceGroupName = 'rg-vdc-nonprod-01'
$StorageAccountName = 'sti6i0znzbefco4'
$Domain = 'mytestlab.local'
$path = 'DC=mytestlab,DC=local'
$kerb1Key = 'cxtqiA6Uf0n2c3lqx4Xb3U6rmA+3Tiet+3kj0vKrYJ6sT+Avy+jtWvn8th1nlij3PckeNhm2kfAhrH6zrwk2VA=='
$password = ConvertTo-SecureString $kerb1Key -AsPlainText -Force
$spnValue = "cifs/$StorageAccountName.file.core.windows.net"

New-ADComputer `
    -SAMAccountName $StorageAccountName `
    -Path $path `
    -Name $StorageAccountName `
    -AccountPassword $password `
    -AllowReversiblePasswordEncryption $false `
    -Description "Computer account object for Azure storage account '$StorageAccountName'." `
    -ServicePrincipalNames $spnValue `
    -Server $Domain `
    -Enabled $true `
    -ErrorAction Stop

$computer = Get-ADComputer -Identity $StorageAccountName
$azureStorageSid = $computer.SID.Value
$domainInformation = Get-ADDomain -Server $Domain
$domainGuid = $domainInformation.ObjectGUID.ToString()
$domainName = $domainInformation.DNSRoot
$domainSid = $domainInformation.DomainSID.Value
$forestName = $domainInformation.Forest
$netBiosDomainName = $domainInformation.DnsRoot
$subscriptionId = 'f6d69ee2-34d5-4ca8-a143-7a2fc1aeca55'
$defaultPermission = "StorageFileDataSmbShareContributor" 

Import-Module -Name Az

Connect-AzAccount -Subscription $subscriptionId

Set-AzStorageAccount `
    -ResourceGroupName $ResourceGroupName `
    -AccountName $StorageAccountName `
    -EnableActiveDirectoryDomainServicesForFile $true `
    -ActiveDirectoryDomainName $domainName `
    -ActiveDirectoryNetBiosDomainName $netBiosDomainName `
    -ActiveDirectoryForestName $forestName `
    -ActiveDirectoryDomainGuid $domainGuid `
    -ActiveDirectoryDomainSid $domainSid `
    -ActiveDirectoryAzureStorageSid $azureStorageSid `
    -DefaultSharePermission $defaultPermission `
    -ErrorAction Stop

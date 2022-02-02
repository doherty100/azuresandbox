# Import-Module -Name ActiveDirectory

$subscriptionId = 'f6d69ee2-34d5-4ca8-a143-7a2fc1aeca55'
$ResourceGroupName = 'rg-vdc-nonprod-01'
$StorageAccountName = 'str4uyycbe9zl6r'
$Domain = 'mytestlab.local'
$path = 'DC=mytestlab,DC=local'
$kerb1Key = 'jXVqjgLlpeteFD2QRpY3Hg4RYT1MjIJ6MNDtPLPDOqq/LcuVwGHCxWLQt62ieyLVyWHnMHw3CKMIY3eKjYvUDw=='
$password = ConvertTo-SecureString $kerb1Key -AsPlainText -Force
$spnValue = "cifs/$StorageAccountName.file.core.windows.net"
$defaultPermission = "StorageFileDataSmbShareContributor" 

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

#Import-Module -Name Az

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

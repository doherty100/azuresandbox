$rg = 'rg-sandbox-01'
$containerUri = 'https://st7b0cj7lpgfybl.blob.core.windows.net/scripts'
$cmd = 'configure-storage-kerberos'
$domain = 'mysandbox.local'

$runCmdParams = @(
    @{
        name = 'TenantId'
        value = '72f988bf-86f1-41af-91ab-2d7cd011db47'
    }, 
    @{
        name = 'SubscriptionId'
        value = 'f6d69ee2-34d5-4ca8-a143-7a2fc1aeca55'
    }, 
    @{
        name = 'AppId'
        value = 'd25bde0d-086a-44fe-aca2-9e3d930b5ede'
    }, 
    @{
        name = 'ResourceGroupName'
        value = $rg
    }, 
    @{
        name = 'StorageAccountName'
        value = 'st7b0cj7lpgfybl'
    }, 
    @{
        name = 'Domain'
        value = $domain
    }
)

$runCmdParamsSecret = @(
    @{
        name = 'AppSecret'
        value = 'FN32Vw-UNfEDPM.~AxwdZ8DXyoCWblXMmf'
    }, 
    @{
        name = 'StorageAccountKerbKey'
        value = 'Ao3sNAcyhwgSLTH/5d+oe1lJ7Qa0Wgzo7Mxz7trULiJ9CdiV5GkMR3INJeItLSRw1eG8B1HEVL/y+ASt94FvqA=='
    }
)

Set-AzVmRunCommand `
    -ResourceGroupName $rg `
    -RunCommandName "$cmd-3" `
    -VMName 'jumpwin1' `
    -Location 'eastus' `
    -ErrorBlobUri "$containerUri/$cmd.err" `
    -OutputBlobUri "$containerUri/$cmd.out" `
    -Parameter $runCmdParams `
    -ProtectedParameter $runCmdParamsSecret `
    -RunAsUser "$domain\bootstrapadmin" `
    -RunAsPassword '7S+1NXBYfl<y' `
    -SourceScript $(Get-Content -Raw './configure-storage-kerberos.ps1')

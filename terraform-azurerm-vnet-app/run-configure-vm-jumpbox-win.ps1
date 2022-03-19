$params = @{
    TenantId = "72f988bf-86f1-41af-91ab-2d7cd011db47"
    SubscriptionId = "f6d69ee2-34d5-4ca8-a143-7a2fc1aeca55"
    ResourceGroupName = "rg-vdc-nonprod-01"
    Location = "eastus"
    AutomationAccountName = "auto-88f3b16f6f28799d-01"
    VirtualMachineName = "jumpwin1" 
    AppId = "42fca019-fa00-4805-b2a7-a0029486300c"
    AppSecret = "w_B.Fg0Sif9wnY3zffipQV3w~DPRNC_1m5"
    DscConfigurationName = "JumpBoxConfig"
    StorageAccountName = "stb4owg5mb8kvxf"
    StorageAccountKerbKey = "nW65NKKbbJVSV/ZbQlQ05syeNSqUodZrGg9VM7qlO6k2MzjIPrm5r4izWUK1ClwFC+OzKO/iNafu+AStXcOHJA=="
    Domain = "mytestlab.local"
    AdminUser = "bootstrapadmin"
    AdminUserSecret = "7S+1NXBYfl<y"
}

./configure-vm-jumpbox-win.ps1 @params

# Azure Automation account

resource "random_id" "automation_account_01_name" {
  byte_length = 8
}

resource "azurerm_automation_account" "automation_account_01" {
  name                = "auto-${random_id.automation_account_01_name.hex}-01"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Basic"
  tags                = var.tags

  # Bootstrap automation account
  # Important: Discontinue use of device authentication and remove "nonsensitive()" function for production use
  provisioner "local-exec" {
    command     = <<EOT
        $params = @{
        TenantId = "${var.aad_tenant_id}"
        SubscriptionId = "${var.subscription_id}"
        ResourceGroupName = "${var.resource_group_name}"
        Location = "${var.location}"
        AutomationAccountName = "${azurerm_automation_account.automation_account_01.name}"
        Domain = "${var.adds_domain_name}"
        VirtualMachineName = "${var.vm_adds_name}"
        AdminUserName = "${nonsensitive(data.azurerm_key_vault_secret.adminuser.value)}"
        AdminPwd = "${nonsensitive(data.azurerm_key_vault_secret.adminpassword.value)}"
        }
        ${path.root}/configure-automation.ps1 @params 
   EOT
    interpreter = ["pwsh", "-Command"]
  }
}

output "automation_account_01_name" {
  value = azurerm_automation_account.automation_account_01.name
}

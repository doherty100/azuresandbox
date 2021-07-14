resource "random_id" "random_id_automation_account_01_name" {
  byte_length = 8
}

resource "azurerm_automation_account" "automation_account_01" {
  name                = "auto-${random_id.random_id_automation_account_01_name.hex}-01"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Basic"
  tags                = var.tags
}

output "automation_account_01_dsc_name" {
  value = azurerm_automation_account.automation_account_01.name
}

resource "azurerm_key_vault_secret" "automation_account_01_dsc_primary_access_key" {
  name         = azurerm_automation_account.automation_account_01.name
  value        = azurerm_automation_account.automation_account_01.dsc_primary_access_key
  key_vault_id = var.key_vault_id
}

resource "azurerm_automation_credential" "automation_credential_01" {
  name                    = var.automation_credential_name
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation_account_01.name
  username                = data.azurerm_key_vault_secret.adminuser.value
  password                = data.azurerm_key_vault_secret.adminpassword.value
  description             = "Bootstrap admin account credential."
}

resource "azurerm_automation_variable_string" "automation_variable_aad_tenant_id" {
  name                    = "aad_tenant_id"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation_account_01.name
  value                   = var.aad_tenant_id
}

resource "azurerm_automation_variable_string" "automation_variable_account_name" {
  name                    = "automation_account_name"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation_account_01.name
  value                   = azurerm_automation_account.automation_account_01.name
}

resource "azurerm_automation_variable_string" "automation_variable_adds_domain_name" {
  name                    = "adds_domain_name"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation_account_01.name
  value                   = var.adds_domain_name
}

resource "azurerm_automation_variable_string" "automation_variable_adds_dsc_config_name" {
  name                    = "adds_dsc_config_name"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation_account_01.name
  value                   = var.adds_dsc_config_name
}

resource "azurerm_automation_variable_string" "automation_variable_resource_group_name" {
  name                    = "resource_group_name"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation_account_01.name
  value                   = var.resource_group_name
}

resource "azurerm_automation_variable_string" "automation_variable_subscription_id" {
  name                    = "subscription_id"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation_account_01.name
  value                   = var.subscription_id
}

resource "azurerm_automation_module" "automation_module_Az_Automation" {
  name                    = "Az.Automation"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation_account_01.name
  module_link {
    uri = var.automation_module_Az_Automation_uri
  }
}

resource "azurerm_automation_module" "automation_module_ActiveDirectoryDsc" {
  name                    = "ActiveDirectoryDsc"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation_account_01.name
  module_link {
    uri = var.automation_module_ActiveDirectoryDsc_uri
  }
}

resource "azurerm_automation_dsc_configuration" "automation_configuration_LabDomainConfig" {
  name                    = "LabDomainConfig"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation_account_01.name
  location                = var.location
  content_embedded        = file("${path.cwd}/LabDomainConfig.ps1")
  depends_on = [
    azurerm_automation_variable_string.automation_variable_adds_domain_name,
    azurerm_automation_credential.automation_credential_01,
    azurerm_automation_module.automation_module_ActiveDirectoryDsc
  ]
}

resource "azurerm_automation_runbook" "automation_runbook_configuration_LabDomainConfig_compile" {
  name                    = "LabDomainConfig-compile"
  location                = var.location
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation_account_01.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "Compiles a DSC configuration."
  runbook_type            = "PowerShell"
  content                 = file("${path.cwd}/LabDomainConfig-compile-Az-MSI.ps1")
  depends_on = [
    azurerm_automation_dsc_configuration.automation_configuration_LabDomainConfig
  ]
}

resource "azurerm_automation_runbook" "automation_runbook_Update-AutomationAzureModulesForAccount" {
  name                    = "Update-AutomationAzureModulesForAccount"
  location                = var.location
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation_account_01.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "Updates the Azure PowerShell modules in the automation account."
  runbook_type            = "PowerShell"
  content                 = file("${path.cwd}/Update-AutomationAzureModulesForAccount.ps1")
}

resource "azurerm_automation_runbook" "automation_runbook_Create-RunAsAccount" {
  name                    = "Create-RunAsAccount"
  location                = var.location
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation_account_01.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "Creates a RunAs account."
  runbook_type            = "PowerShell"
  content                 = file("${path.cwd}/Create-RunAsAccount.ps1")
}

# Azure SQL Datbase Server
data "azurerm_key_vault_secret" "adminpassword" {
  name         = var.sql_admin_password_secret
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "adminuser" {
  name         = var.sql_admin_username_secret
  key_vault_id = var.key_vault_id
}

resource "random_id" "random_id_sql_server_01_name" {
  byte_length = 8
}

resource "azurerm_sql_server" "sql_server_01" {
  name                         = "sql-${random_id.random_id_sql_server_01_name.hex}-001"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = data.azurerm_key_vault_secret.adminuser.value
  administrator_login_password = data.azurerm_key_vault_secret.adminpassword.value
  tags                         = var.tags
}

output "sql_server_01_fqdn" {
  value = azurerm_sql_server.sql_server_01.fully_qualified_domain_name
}

output "sql_server_01_id" {
  value = azurerm_sql_server.sql_server_01.id
}

output "sql_server_01_name" {
  value = azurerm_sql_server.sql_server_01.name
}

# Azure SQL Database
resource "azurerm_sql_database" "sql_database_01" {
  name                = var.sql_database_name
  resource_group_name = var.resource_group_name
  location            = var.location
  server_name         = azurerm_sql_server.sql_server_01.name
  tags                = var.tags
}

output "sql_database_01_id" {
  value = azurerm_sql_database.sql_database_01.id
}

output "sql_database_01_name" {
  value = azurerm_sql_database.sql_database_01.name
}
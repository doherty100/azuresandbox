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

# Azure SQL Database logical server private endpoint
resource "random_id" "random_id_sql_server_01_private_endpoint_name" {
  byte_length = 8
}

resource "azurerm_private_endpoint" "sql_server_01_private_endpoint" {
  name                = "pend-${random_id.random_id_sql_server_01_private_endpoint_name.hex}-002"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoints_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "azure_sql_database_logical_server"
    private_connection_resource_id = azurerm_sql_server.sql_server_01.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }
}

output "sql_server_01_private_endpoint_id" {
  value = azurerm_private_endpoint.sql_server_01_private_endpoint.id
}

output "sql_server_01_private_endpoint_name" {
  value = azurerm_private_endpoint.sql_server_01_private_endpoint.name
}

output "sql_server_01_private_endpoint_prvip" {
  value = azurerm_private_endpoint.sql_server_01_private_endpoint.private_service_connection[0].private_ip_address
}

# Private dns zone
resource "azurerm_private_dns_zone" "private_dns_zone_2" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

output "private_dns_zone_2_id" {
  value = azurerm_private_dns_zone.private_dns_zone_2.id
}

output "private_dns_zone_2_name" {
  value = azurerm_private_dns_zone.private_dns_zone_2.name
}

resource "azurerm_private_dns_a_record" "private_dns_a_record_2" {
  name                = azurerm_sql_server.sql_server_01.name
  zone_name           = azurerm_private_dns_zone.private_dns_zone_2.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.sql_server_01_private_endpoint.private_service_connection[0].private_ip_address]
}

output "private_dns_a_record_2_id" {
  value = azurerm_private_dns_a_record.private_dns_a_record_2.id
}

output "private_dns_a_record_2_name" {
  value = azurerm_private_dns_a_record.private_dns_a_record_2.name
}

# Private DNS zone virtual network link
resource "azurerm_private_dns_zone_virtual_network_link" "virtual_network_link_vnet_spoke_01" {
  name                  = "pdnslnk-${var.vnet_spoke_01_name}-002"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone_2.name
  virtual_network_id    = var.vnet_spoke_01_id
  registration_enabled  = false
  tags                  = var.tags
}

output "virtual_network_link_vnet_spoke_01_id" {
  value = azurerm_private_dns_zone_virtual_network_link.virtual_network_link_vnet_spoke_01.id
}

output "virtual_network_link_vnet_spoke_01_name" {
  value = azurerm_private_dns_zone_virtual_network_link.virtual_network_link_vnet_spoke_01.name
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


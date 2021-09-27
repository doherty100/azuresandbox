# Azure SQL Database
resource "azurerm_sql_database" "sql_database_01" {
  name                = var.sql_database_name
  resource_group_name = var.resource_group_name
  location            = var.location
  server_name         = azurerm_sql_server.sql_server_01.name
  tags                = var.tags
}

# Azure SQL Database logical server
resource "random_id" "random_id_sql_server_01_name" {
  byte_length = 8
}

resource "azurerm_sql_server" "sql_server_01" {
  name                         = "sql-${random_id.random_id_sql_server_01_name.hex}-01"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = data.azurerm_key_vault_secret.adminuser.value
  administrator_login_password = data.azurerm_key_vault_secret.adminpassword.value
  tags                         = var.tags
}

resource "azurerm_private_endpoint" "sql_server_01" {
  name                = "pend-${azurerm_sql_server.sql_server_01.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = azurerm_subnet.vnet_app_01_subnets["PrivateLink"].id
  tags                = var.tags

  private_service_connection {
    name                           = "azure_sql_database_logical_server"
    private_connection_resource_id = azurerm_sql_server.sql_server_01.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }
}

# Azure SQL Database private DNS zone
resource "azurerm_private_dns_zone" "database_windows_net" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_a_record" "sql_server_01" {
  name                = azurerm_sql_server.sql_server_01.name
  zone_name           = azurerm_private_dns_zone.database_windows_net.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.sql_server_01.private_service_connection[0].private_ip_address]
}

# Private DNS zone virtual network link
resource "azurerm_private_dns_zone_virtual_network_link" "database_windows_net_to_vnet_app_01" {
  name                  = "pdnslnk-${var.vnet_name}-01"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.database_windows_net.name
  virtual_network_id    = azurerm_virtual_network.vnet_app_01.id
  registration_enabled  = false
  tags                  = var.tags
}

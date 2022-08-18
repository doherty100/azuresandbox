resource "random_id" "random_id_mysql_server_01_name" {
  byte_length = 8
}

# Azure Database for MySQL Flexible Server
resource "azurerm_mysql_flexible_server" "mysql_server_01" {
  name                   = "mysql-${random_id.random_id_mysql_server_01_name.hex}"
  resource_group_name    = var.resource_group_name
  location               = var.location
  administrator_login    = data.azurerm_key_vault_secret.adminuser.value
  administrator_password = data.azurerm_key_vault_secret.adminpassword.value
  delegated_subnet_id    = azurerm_subnet.vnet_app_01_subnets["snet-mysql-01"].id
  private_dns_zone_id    = azurerm_private_dns_zone.private_dns_zones["private.mysql.database.azure.com"].id
  sku_name               = "B_Standard_B1s"

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.private_dns_zone_virtual_network_links_vnet_app_01
  ]
}

#Azure Database for MySQL test database
resource "azurerm_mysql_database" "mysql_database_01" {
  name                = var.mysql_database_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.mysql_server_01.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

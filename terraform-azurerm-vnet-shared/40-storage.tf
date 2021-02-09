# Shared storage account
resource "random_id" "random_id_storage_account_01_name" {
  byte_length = 8
}

resource "azurerm_storage_account" "storage_account_01" {
  name                     = "st${random_id.random_id_storage_account_01_name.hex}001"
  resource_group_name      = azurerm_resource_group.resource_group_01.name
  location                 = azurerm_resource_group.resource_group_01.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  access_tier              = var.storage_access_tier
  account_replication_type = var.storage_replication_type
  tags                     = var.tags
}

output "storage_account_01_blob_endpoint" {
  value = azurerm_storage_account.storage_account_01.primary_blob_endpoint
}

output "storage_account_01_id" {
  value = azurerm_storage_account.storage_account_01.id
}

output "storage_account_01_name" {
  value = azurerm_storage_account.storage_account_01.name
}

output "storage_account_01_key" {
  value = azurerm_storage_account.storage_account_01.primary_access_key
  sensitive = true
}

# Shared blob container

resource "azurerm_storage_container" "storage_container_01" {
  name                  = var.storage_container_name
  storage_account_name  = azurerm_storage_account.storage_account_01.name
  container_access_type = "private"
}

output "storage_container_01_name" {
  value = azurerm_storage_container.storage_container_01.name
}

output "storage_container_01_id" {
  value = azurerm_storage_container.storage_container_01.resource_manager_id
}

# Shared private endpoint
resource "random_id" "random_id_storage_account_01_private_endpoint_file_name" {
  byte_length = 8
}

resource "azurerm_private_endpoint" "storage_account_01_private_endpoint_file" {
  name                = "pend-${random_id.random_id_storage_account_01_private_endpoint_file_name.hex}-001"
  resource_group_name = azurerm_resource_group.resource_group_01.name
  location            = azurerm_resource_group.resource_group_01.location
  subnet_id           = azurerm_subnet.vnet_shared_01_subnets["PrivateLink"].id
  tags                = var.tags

  private_service_connection {
    name                           = "azure_files"
    private_connection_resource_id = azurerm_storage_account.storage_account_01.id
    is_manual_connection           = false
    subresource_names              = ["file"]
  }
}

output "storage_account_01_private_endpoint_file_id" {
  value = azurerm_private_endpoint.storage_account_01_private_endpoint_file.id
}

output "storage_account_01_private_endpoint_file_name" {
  value = azurerm_private_endpoint.storage_account_01_private_endpoint_file.name
}

output "storage_account_01_private_endpoint_file_prvip" {
  value = azurerm_private_endpoint.storage_account_01_private_endpoint_file.private_service_connection[0].private_ip_address
}

# Shared file share
resource "random_id" "random_id_storage_share_01_name" {
  byte_length = 8
}

resource "azurerm_storage_share" "storage_share_01" {
  name                 = "fs-${random_id.random_id_storage_share_01_name.hex}-001"
  storage_account_name = azurerm_storage_account.storage_account_01.name
  quota                = var.storage_share_quota_gb
}

output "storage_share_01_id" {
  value = azurerm_storage_share.storage_share_01.resource_manager_id
}

output "storage_share_01_name" {
  value = azurerm_storage_share.storage_share_01.name
}

output "storage_share_01_url" {
  value = azurerm_storage_share.storage_share_01.url
}

# Shared private dns zone
resource "azurerm_private_dns_zone" "private_dns_zone_1" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.resource_group_01.name
  tags                = var.tags
}

output "private_dns_zone_1_id" {
  value = azurerm_private_dns_zone.private_dns_zone_1.id
}

output "private_dns_zone_1_name" {
  value = azurerm_private_dns_zone.private_dns_zone_1.name
}

resource "azurerm_private_dns_a_record" "private_dns_a_record_1" {
  name                = azurerm_storage_account.storage_account_01.name
  zone_name           = azurerm_private_dns_zone.private_dns_zone_1.name
  resource_group_name = azurerm_resource_group.resource_group_01.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.storage_account_01_private_endpoint_file.private_service_connection[0].private_ip_address]
}

output "private_dns_a_record_1_id" {
  value = azurerm_private_dns_a_record.private_dns_a_record_1.id
}

output "private_dns_a_record_1_name" {
  value = azurerm_private_dns_a_record.private_dns_a_record_1.name
}

# Private DNS zone virtual network link
resource "azurerm_private_dns_zone_virtual_network_link" "virtual_network_link_vnet_shared_01" {
  name                  = "pdnslnk-${azurerm_virtual_network.vnet_shared_01.name}-001"
  resource_group_name   = azurerm_resource_group.resource_group_01.name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone_1.name
  virtual_network_id    = azurerm_virtual_network.vnet_shared_01.id
  registration_enabled  = false
  tags                  = var.tags
}

output "virtual_network_link_vnet_shared_01_id" {
  value = azurerm_private_dns_zone_virtual_network_link.virtual_network_link_vnet_shared_01.id
}

output "virtual_network_link_vnet_shared_01_name" {
  value = azurerm_private_dns_zone_virtual_network_link.virtual_network_link_vnet_shared_01.name
}

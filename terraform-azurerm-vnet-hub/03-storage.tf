resource "random_id" "random_id_storage_account_01_name" {
  byte_length = 8
}

resource "azurerm_storage_account" "storage_account_01" {
  name                     = random_id.random_id_storage_account_01_name.hex
  resource_group_name      = azurerm_resource_group.resource_group_01.name
  location                 = azurerm_resource_group.resource_group_01.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  access_tier              = var.storage_access_tier
  account_replication_type = var.storage_replication_type
  tags                     = var.tags
}

resource "azurerm_storage_share" "storage_share_01" {
  name                 = "share-${random_id.random_id_storage_account_01_name.hex}-01"
  storage_account_name = azurerm_storage_account.storage_account_01.name
  quota                = var.storage_share_quota
}

resource "azurerm_private_endpoint" "storage_account_01_private_endpoint_file" {
  name                = "endpoint-${azurerm_storage_account.storage_account_01.name}"
  location            = azurerm_resource_group.resource_group_01.location
  resource_group_name = azurerm_resource_group.resource_group_01.name
  subnet_id           = azurerm_subnet.vnet_hub_subnets["PrivateLinkStorage"].id

  private_service_connection {
    name                           = "azure_files"
    private_connection_resource_id = azurerm_storage_account.storage_account_01.id
    is_manual_connection           = false
    subresource_names              = ["file"]
  }
}

output "storage_account_01_id" {
  value = azurerm_storage_account.storage_account_01.id
}

output "storage_account_01_name" {
  value = azurerm_storage_account.storage_account_01.name
}

output "storage_share_01_id" {
  value = azurerm_storage_share.storage_share_01.id
}

output "storage_share_01_name" {
  value = azurerm_storage_share.storage_share_01.name
}

output "storage_account_01_private_endpoint_file_id" {
  value = azurerm_private_endpoint.storage_account_01_private_endpoint_file.id
}

output "storage_account_01_private_endpoint__file_privateip" {
  value = azurerm_private_endpoint.storage_account_01_private_endpoint_file.private_service_connection[0].private_ip_address
}
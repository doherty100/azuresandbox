resource "random_id" "random_id_01" {
  byte_length = 8
}

resource "azurerm_storage_account" "storage_account_01" {
  name                     = "${random_id.random_id_01.hex}"
  resource_group_name      = "${azurerm_resource_group.resource_group_01.name}"
  location                 = "${azurerm_resource_group.resource_group_01.location}"
  account_tier             = "${var.storage_account_tier}"
  access_tier              = "${var.storage_access_tier}"
  account_replication_type = "${var.storage_replication_type}"
  
  tags                     = "${var.tags}"
}

output "storage_account_01_id" {
  value = "${azurerm_storage_account.storage_account_01.id}"
}

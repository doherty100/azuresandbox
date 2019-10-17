resource "random_id" "random_id_key_vault_01_name" {
  byte_length = 8
}

resource "azurerm_key_vault" "key_vault_01" {
  name                = "kv-${random_id.random_id_key_vault_01_name.hex}-kv"
  location            = "${azurerm_resource_group.resource_group_01.location}"
  resource_group_name = "${azurerm_resource_group.resource_group_01.name}"
  tenant_id           = "${var.aad_tenant_id}"
  sku_name            = "${var.key_vault_sku_name}"

  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true

  tags = "${var.tags}"
}

resource "azurerm_key_vault_access_policy" "key_vault_01_access_policy_secrets_admin" {
  key_vault_id = "${azurerm_key_vault.key_vault_01.id}"
  tenant_id = "${var.aad_tenant_id}"
  object_id = "${var.key_vault_admin_object_id}"

  secret_permissions = [
    "backup",
    "delete",
    "get",
    "list",
    "purge",
    "recover",
    "restore",
    "set"
  ]
}
output "key_vault_01_id" {
  value = "${azurerm_key_vault.key_vault_01.id}"
}

output "key_vault_01_name" {
  value = "${azurerm_key_vault.key_vault_01.name}"
}

output "key_vault_01_uri" {
  value = "${azurerm_key_vault.key_vault_01.vault_uri}"
}

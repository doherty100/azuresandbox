resource "azurerm_key_vault" "key_vault_01" {
  name                = "${var.key_vault_name}"
  location            = "${azurerm_resource_group.resource_group_01.location}"
  resource_group_name = "${azurerm_resource_group.resource_group_01.name}"
  tenant_id           = "${var.aad_tenant_id}"
  sku_name            = "${var.key_vault_sku_name}"

  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true

  tags = "${var.tags}"
}

output "key_vault_01_id" {
  value = "${azurerm_key_vault.key_vault_01.id}"
}

output "key_vault_01_uri" {
  value = "${azurerm_key_vault.key_vault_01.vault_uri}"
}

resource "azurerm_resource_group" "resource_group_01" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

output "resource_group_01_id" {
  value = azurerm_resource_group.resource_group_01.id
}

output "resource_group_01_location" {
  value = azurerm_resource_group.resource_group_01.location
}

output "resource_group_01_name" {
  value = azurerm_resource_group.resource_group_01.name
}

resource "azurerm_role_assignment" "resource_group_01_owner" {
  scope = azurerm_resource_group.resource_group_01.id
  role_definition_name = "Owner"
  principal_id = var.owner_object_id
}

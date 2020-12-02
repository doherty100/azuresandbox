# Resource group

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

# Role assignment

resource "azurerm_role_assignment" "resource_group_01_role_assignment_owner" {
  scope                = azurerm_resource_group.resource_group_01.id
  role_definition_name = "Owner"
  principal_id         = var.owner_object_id
}

output "resource_group_01_role_assignment_owner_id" {
  value = azurerm_role_assignment.resource_group_01_role_assignment_owner.id
}

output "resource_group_01_role_assignment_owner_principal_type" {
  value = azurerm_role_assignment.resource_group_01_role_assignment_owner.principal_type
}

output "resource_group_01_role_assignment_owner_principal_id" {
  value = azurerm_role_assignment.resource_group_01_role_assignment_owner.principal_id
}

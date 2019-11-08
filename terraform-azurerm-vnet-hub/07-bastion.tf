resource "azurerm_bastion_host" "bastion_host_01" {
  name                = var.bastion_host_name
  location            = azurerm_resource_group.resource_group_01.location
  resource_group_name = azurerm_resource_group.resource_group_01.name
  tags = var.tags

  ip_configuration {
    name                 = "${var.bastion_host_name}ipconfig01"
    subnet_id            = azurerm_subnet.vnet_hub_subnets["AzureBastionSubnet"].id
    public_ip_address_id = azurerm_public_ip.public_ip_azure_bastion.id
  }
}

output "bastion_host_01_id" {
  value = azurerm_bastion_host.bastion_host_01.id
}

output "bastion_host_01_dns_name" {
  value = azurerm_bastion_host.bastion_host_01.dns_name
}

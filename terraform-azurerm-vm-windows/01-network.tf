# Create network related dependencies

# Create the primary nic, bind it to the subnet and the public ip
resource "azurerm_network_interface" "nic1" {
  name                = "${var.vm_name}-nic1"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "${var.vm_name}-nic1-ipconfig-1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

output "nic1_id" {
  value = azurerm_network_interface.nic1.id
}

output "nic1_mac_address" {
  value = azurerm_network_interface.nic1.mac_address
}

output "nic1_private_ip_addresses" {
  value = azurerm_network_interface.nic1.private_ip_addresses
}

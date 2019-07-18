# Create network related dependencies

# Create public ip for rdp traffic
resource "azurerm_public_ip" "pip1" {
  name                = "${var.vm_name}-pip1"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  allocation_method   = "Dynamic"
}

# Create the primary nic, bind it to the subnet and the public ip
resource "azurerm_network_interface" "nic1" {
  name                = "${var.vm_name}-nic1"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  ip_configuration {
    name                          = "${var.vm_name}-nic1-ipconfig-1"
    subnet_id                     = "${var.subnet_id}"
    public_ip_address_id          = "${azurerm_public_ip.pip1.id}"
    private_ip_address_allocation = "Dynamic"
  }
}


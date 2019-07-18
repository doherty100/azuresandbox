# Create compute related dependencies

# Create OS disk

resource "azurerm_virtual_machine" "vm1" {
  name                          = "${var.vm_name}"
  location                      = "${var.location}"
  resource_group_name           = "${var.resource_group_name}"
  network_interface_ids         = ["${azurerm_network_interface.nic1.id}"]
  vm_size                       = "${var.vm_size}"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "${var.vm_image_publisher}"
    offer     = "${var.vm_image_offer}"
    sku       = "${var.vm_image_sku}"
    version   = "${var.vm_image_version}"
  }

  storage_os_disk {
    name              = "${var.vm_name}-osdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "${var.vm_storage_replication_type}"
  }

  os_profile {
    computer_name  = "${var.vm_name}"
    admin_username = "${data.azurerm_key_vault_secret.adminuser.value}"
    admin_password = "${data.azurerm_key_vault_secret.adminpassword.value}"
  }

  os_profile_windows_config {
    provision_vm_agent = true
  }
}

resource "azurerm_managed_disk" "datadisk" {
    count                = "${var.vm_data_disk_count}"
    name                 = "${var.vm_name}-datadisk${count.index+1}"
    location             = "${var.location}"
    resource_group_name  = "${var.resource_group_name}"
    storage_account_type = "${var.vm_storage_replication_type}"
    create_option        = "Empty"
    disk_size_gb         = "${var.vm_data_disk_size_gb}"
}

resource "azurerm_virtual_machine_data_disk_attachment" "external" {
    count              = "${var.vm_data_disk_count}"
    managed_disk_id    = "${azurerm_managed_disk.datadisk.*.id[count.index]}"
    virtual_machine_id = "${azurerm_virtual_machine.vm1.id}"
    lun                = "${count.index}"
    caching            = "ReadWrite"
}
resource "azurerm_shared_image_gallery" "shared_image_gallery_01" {
  name                = "${var.shared_image_gallery_name}"
  resource_group_name = "${azurerm_resource_group.resource_group_01.name}"
  location            = "${azurerm_resource_group.resource_group_01.location}"
  description         = "Shared virtual machine images."
  tags                = "${var.tags}"
}

output "shared_image_gallery_01_id" {
  value = "${azurerm_shared_image_gallery.shared_image_gallery_01.id}"
}

output "shared_image_gallery_01_unique_name" {
  value = "${azurerm_shared_image_gallery.shared_image_gallery_01.unique_name}"
}

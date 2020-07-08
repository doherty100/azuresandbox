# Shared image gallery
resource "random_id" "random_id_shared_image_gallery_01_name" {
  byte_length = 8
}

resource "azurerm_shared_image_gallery" "shared_image_gallery_01" {
  name                = "sig${random_id.random_id_shared_image_gallery_01_name.hex}001"
  resource_group_name = azurerm_resource_group.resource_group_01.name
  location            = azurerm_resource_group.resource_group_01.location
  description         = "Shared virtual machine images."
  tags                = var.tags
}

output "shared_image_gallery_01_id" {
  value = azurerm_shared_image_gallery.shared_image_gallery_01.id
}

output "shared_image_gallery_01_name" {
  value = azurerm_shared_image_gallery.shared_image_gallery_01.name
}

output "shared_image_gallery_01_unique_name" {
  value = azurerm_shared_image_gallery.shared_image_gallery_01.unique_name
}

# Storage Account 1
resource "azurerm_storage_account" "sa1" {
  name                            = "saazurelocalimages${var.site}"
  resource_group_name             = azurerm_resource_group.images.name
  location                        = azurerm_resource_group.images.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false

  min_tls_version               = "TLS1_2"
  public_network_access_enabled = false
  tags                          = var.tags

}
resource "azurerm_storage_container" "sa1_images" {
  name                  = "images"
  storage_account_id    = azurerm_storage_account.sa1.id
  container_access_type = "private"
}

# Private Endpoint for Storage Account 1 (Blob)
resource "azurerm_private_endpoint" "sa1_blob_pe" {
  name                = "pe-${azurerm_storage_account.sa1.name}-blob"
  location            = azurerm_resource_group.images.location
  resource_group_name = azurerm_resource_group.images.name
  subnet_id           = data.azurerm_subnet.other_3_subnet.id

  private_service_connection {
    name                           = "psc-${azurerm_storage_account.sa1.name}-blob"
    private_connection_resource_id = azurerm_storage_account.sa1.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      private_dns_zone_group
    ]
  }
}
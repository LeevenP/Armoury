resource "azurerm_stack_hci_cluster" "mal_hci_clus" {

  name                = "mal-al-clus-01"
  resource_group_name = azurerm_resource_group.cluster[0].name
  location            = azurerm_resource_group.cluster[0].location
  identity {
    type = "SystemAssigned"
  }
  lifecycle {
    ignore_changes = [
      client_id
    ]
  }
  tags = var.tags
}


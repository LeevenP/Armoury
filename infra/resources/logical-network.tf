resource "azurerm_stack_hci_logical_network" "mal_hci_clus_logical_network_mngmnt" {
  name                = "mal-management-prod-ln"
  resource_group_name = azurerm_resource_group.vms[0].name
  location            = azurerm_resource_group.vms[0].location
  custom_location_id  = data.azurerm_extended_location_custom_location.mal_hci_clus_custom_location.id
  virtual_switch_name = "ConvergedSwitch(compute_management)"
  dns_servers         = ["10.40.4.xx", "10.40.4.xx"]

  subnet {
    ip_allocation_method = "Static"
    address_prefix       = "10.223.xx.0/24"
    vlan_id              = 21
    ip_pool {
      start = "10.223.21.xx"
      end   = "10.223.21.xx"
    }
    route {
      address_prefix      = "0.0.0.0/0"
      next_hop_ip_address = "10.223.21.xx"
    }
  }
  tags = var.tags
}


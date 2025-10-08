terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    random = {
      source = "hashicorp/random"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "core"
}

locals {
  resource_group_name = "Virtual-Network"
  region_prefix       = lookup(local.all_regions, var.location)["prefix"]
  regions = {
    "eastus2" = {
      prefix = "azeus2"
    }
    "northeurope" = {
      prefix = "azne"
    }
    "westeurope" = {
      prefix = "azwe"
    }
    "westus3" = {
      prefix = "azwus3"
    }
  }
}

# Each key is equals to the location.
locals {
  all_regions = { for k, v in local.regions : k => v if var.location == k }
}

data "azurerm_client_config" "current" {}
data "azurerm_subscription" "primary" {}

data "azurerm_resource_group" "gangway_resource_group" {
  name = "Gangway-Resources"
}

data "azurerm_resource_group" "lz_vnet_resource_group" {
  name = "Virtual-Network"
}

data "azurerm_virtual_network" "lz_vnet" {
  name                = lower("${lookup(local.all_regions, var.location)["prefix"]}-${lower(replace(var.name, " ", "-"))}-${lower(var.environment)}-vnet")
  resource_group_name = data.azurerm_resource_group.lz_vnet_resource_group.name
}

data "azurerm_subnet" "fronting_subnet" {
  name                 = "fronting_subnet"
  virtual_network_name = data.azurerm_virtual_network.lz_vnet.name
  resource_group_name  = data.azurerm_resource_group.lz_vnet_resource_group.name
}

data "azurerm_subnet" "delegation_1_subnet" {
  name                 = "delegation_1_subnet"
  virtual_network_name = data.azurerm_virtual_network.lz_vnet.name
  resource_group_name  = data.azurerm_resource_group.lz_vnet_resource_group.name
}

data "azurerm_subnet" "delegation_2_subnet" {
  name                 = "delegation_2_subnet"
  virtual_network_name = data.azurerm_virtual_network.lz_vnet.name
  resource_group_name  = data.azurerm_resource_group.lz_vnet_resource_group.name
}

data "azurerm_subnet" "other_1_subnet" {
  name                 = "other_1_subnet"
  virtual_network_name = data.azurerm_virtual_network.lz_vnet.name
  resource_group_name  = data.azurerm_resource_group.lz_vnet_resource_group.name
}

data "azurerm_subnet" "other_2_subnet" {
  name                 = "other_2_subnet"
  virtual_network_name = data.azurerm_virtual_network.lz_vnet.name
  resource_group_name  = data.azurerm_resource_group.lz_vnet_resource_group.name
}

data "azurerm_subnet" "other_3_subnet" {
  name                 = "other_3_subnet"
  virtual_network_name = data.azurerm_virtual_network.lz_vnet.name
  resource_group_name  = data.azurerm_resource_group.lz_vnet_resource_group.name
}

data "azurerm_network_security_group" "frontend_nsg" {
  name                = "frontend_nsg"
  resource_group_name = data.azurerm_resource_group.lz_vnet_resource_group.name
}

data "azurerm_network_security_group" "other_nsg" {
  name                = "other_nsg"
  resource_group_name = data.azurerm_resource_group.lz_vnet_resource_group.name
}

data "azurerm_resource_group" "private_dns_resource_group" {
  count = var.create_private_dns_zone ? 1 : 0
  name  = "Private-DNS"
}

data "azurerm_private_dns_zone" "aks_private_dns_zone" {
  count               = var.create_private_dns_zone ? 1 : 0
  name                = "${var.name}-${var.environment}.privatelink.${var.location}.azmk8s.io"
  resource_group_name = data.azurerm_resource_group.private_dns_resource_group[0].name
}

data "azurerm_key_vault" "key_vault" {
  name                = "kvazureloc13hwe${lower(var.environment)}"
  resource_group_name = data.azurerm_resource_group.gangway_resource_group.name
}

data "azurerm_storage_account" "storage_account" {
  name                = "saazureloc13hwe${lower(var.environment)}"
  resource_group_name = data.azurerm_resource_group.gangway_resource_group.name
}

data "azurerm_extended_location_custom_location" "mal_hci_clus_custom_location" {
  name                = var.hcicluster.customlocation
  resource_group_name = azurerm_resource_group.cluster[0].name
}

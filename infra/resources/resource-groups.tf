locals {
  cluster_count = 1
}

resource "azurerm_resource_group" "cluster" {
  count    = local.cluster_count
  name     = "Cluster-0${count.index + 1}"
  location = var.location

  tags = var.tags
}

resource "azurerm_resource_group" "vms" {
  count    = local.cluster_count
  name     = "Cluster-0${count.index + 1}-VMs"
  location = var.location

  tags = var.tags
}

resource "azurerm_resource_group" "sql" {
  count    = local.cluster_count
  name     = "Cluster-0${count.index + 1}-SQL"
  location = var.location

  tags = var.tags
}

resource "azurerm_resource_group" "aks" {
  count    = local.cluster_count
  name     = "Cluster-0${count.index + 1}-AKS"
  location = var.location

  tags = var.tags
}

resource "azurerm_resource_group" "migrate" {
  count    = local.cluster_count
  name     = "Cluster-0${count.index + 1}-Migrate"
  location = var.location

  tags = var.tags
}

resource "azurerm_resource_group" "images" {
  name     = "Images"
  location = var.location

  tags = var.tags
}
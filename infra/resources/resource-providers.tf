# Registers required Azure Resource Providers for Azure Local onboarding
# See docs/azure_local_onboarding.md for context

resource "azurerm_resource_provider_registration" "hybrid_compute" {
  name = "Microsoft.HybridCompute"
}

resource "azurerm_resource_provider_registration" "hybrid_connectivity" {
  name = "Microsoft.HybridConnectivity"
}

resource "azurerm_resource_provider_registration" "azurestack_hci" {
  name = "Microsoft.AzureStackHCI"
}

resource "azurerm_resource_provider_registration" "kubernetes" {
  name = "Microsoft.Kubernetes"
}

resource "azurerm_resource_provider_registration" "kubernetes_configuration" {
  name = "Microsoft.KubernetesConfiguration"
}

resource "azurerm_resource_provider_registration" "extended_location" {
  name = "Microsoft.ExtendedLocation"
}

resource "azurerm_resource_provider_registration" "resource_connector" {
  name = "Microsoft.ResourceConnector"
}

resource "azurerm_resource_provider_registration" "hybrid_container_service" {
  name = "Microsoft.HybridContainerService"
}

resource "azurerm_resource_provider_registration" "attestation" {
  name = "Microsoft.Attestation"
}

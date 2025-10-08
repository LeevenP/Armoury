# Role assignments for az-azurelocal-prod-sup 
resource "azurerm_role_assignment" "az_azurelocalmal_prod_sup_contributor" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = ""
}

resource "azurerm_role_assignment" "az_azurelocalmal_prod_sup_arc_onboarding" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Azure Connected Machine Onboarding"
  principal_id         = ""
}

resource "azurerm_role_assignment" "az_azurelocalmal_prod_sup_arc_resource_admin" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Azure Connected Machine Resource Administrator"
  principal_id         = ""
}

resource "azurerm_role_assignment" "az_azurelocalmal_prod_sup_local_admin" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Azure Stack HCI Administrator"
  principal_id         = ""
}

resource "azurerm_role_assignment" "az_azurelocalmal_prod_sup_kv_data_access" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Key Vault Data Access Administrator"
  principal_id         = ""
}

resource "azurerm_role_assignment" "az_azurelocalmal_prod_sup_kv_contrib" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Key Vault Contributor"
  principal_id         = ""
}

resource "azurerm_role_assignment" "az_azurelocalmal_prod_sup_sa_contrib" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = ""
}

resource "azurerm_role_assignment" "az_azurelocalmal_prod_sup_kv" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = ""
}

resource "azurerm_role_assignment" "az_azurelocalmal_prod_sup_wac" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Windows Admin Center Administrator Login"
  principal_id         = ""
}

resource "azurerm_role_assignment" "az_azurelocalmal_k8s_runtime_writer" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Azure Arc Kubernetes Cluster Admin"
  principal_id         = ""
}

resource "azurerm_role_assignment" "az_azurelocalmal_sp_storage_blob_data_contributor" {
  scope                = azurerm_storage_account.sa1.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "az_azurelocalmal_prod_sup_sb_data_owner" {
  scope                = azurerm_storage_account.sa1.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = ""
}

resource "azurerm_role_assignment" "az_azurelocalrepo_sp_storage_blob_data_contributor" {
  scope                = azurerm_storage_account.sa1.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = ""
}
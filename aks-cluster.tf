# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "random_pet" "prefix" {}



data "hcp_vault_secrets_secret" "appId" {
  app_name    = "aks"
  secret_name = "appId"
}
data "hcp_vault_secrets_secret" "password" {
  app_name    = "aks"
  secret_name = "password"
}

resource "azurerm_resource_group" "aksrg" {
  name     = "${random_pet.prefix.id}-rg"
  location = "Australia East"

  tags = {
    environment = "Dev"
  }
}

resource "azurerm_container_registry" "woolsacr" {
  name                = "woolsdevacr"
  resource_group_name = azurerm_resource_group.aksrg.name
  location            = azurerm_resource_group.aksrg.location
  sku                 = "Basic"
}

resource "azurerm_kubernetes_cluster" "akscluster" {
  name                = "${random_pet.prefix.id}-aks"
  location            = azurerm_resource_group.aksrg.location
  resource_group_name = azurerm_resource_group.aksrg.name
  dns_prefix          = "${random_pet.prefix.id}-k8s"
  kubernetes_version  = "1.26.3"

  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = "Standard_D2_v2"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = var.appId
    client_secret = var.password
  }

  role_based_access_control_enabled = true

  tags = {
    environment = "Dev"
  }
}

/*
resource "azurerm_role_assignment" "woolsaksrole" {
  principal_id                     = azurerm_kubernetes_cluster.akscluster.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.woolsacr.id
  skip_service_principal_aad_check = true
}
*/

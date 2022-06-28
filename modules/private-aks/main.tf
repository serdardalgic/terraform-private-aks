data "azurerm_kubernetes_service_versions" "current" {
  location       = var.location
  version_prefix = var.kube_version_prefix
}

resource "azurerm_kubernetes_cluster" "privateaks" {
  name                    = "private-aks"
  location                = var.location
  kubernetes_version      = data.azurerm_kubernetes_service_versions.current.latest_version
  resource_group_name     = var.resource_group_name
  dns_prefix              = "private-aks"
  private_cluster_enabled = true

  default_node_pool {
    name                = "default"
    node_count          = var.nodepool_nodes_count
    vm_size             = var.nodepool_vm_size
    vnet_subnet_id      = var.subnet_id
    min_count           = var.nodepool_min_count
    max_count           = var.nodepool_max_count
    enable_auto_scaling = true
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    docker_bridge_cidr = var.network_docker_bridge_cidr
    dns_service_ip     = var.network_dns_service_ip
    network_plugin     = "azure"
    outbound_type      = "userDefinedRouting"
    service_cidr       = var.network_service_cidr
  }

  # When auto_scaling is enabled, ignore changes in the node count.
  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
    ]
  }

}

# TODO:
# Check in the future if the problem continues
# https://github.com/Azure/AKS/issues/1557
#
resource "azurerm_role_assignment" "netcontributor" {
  role_definition_name = "Network Contributor"
  scope                = var.subnet_id
  principal_id         = azurerm_kubernetes_cluster.privateaks.identity[0].principal_id
}

output "kube_config" {
  value       = azurerm_kubernetes_cluster.privateaks.kube_config_raw
  description = "Copy this kube_config to Jumpbox in order to interact with the private Kubernetes cluster"
  sensitive   = true
}

output "private_fqdn" {
  value       = azurerm_kubernetes_cluster.privateaks.private_fqdn
  description = "The FQDN for the Kubernetes Cluster when private link has been enabled"
}

output "node_resource_group" {
  value       = azurerm_kubernetes_cluster.privateaks.node_resource_group
  description = "The auto-generated Resource Group which contains the resources for this Managed Kubernetes Cluster."
}



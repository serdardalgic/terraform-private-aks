output "ssh_command" {
  value = "ssh ${module.jumpbox.jumpbox_username}@${module.jumpbox.jumpbox_ip}"
}

output "jumpbox_password" {
  description = "Jumpbox Admin Passowrd"
  value       = module.jumpbox.jumpbox_password
  sensitive   = true
}

output "kube_config" {
  value       = azurerm_kubernetes_cluster.privateaks.kube_config_raw
  description = "Copy this kube_config to Jumpbox in order to interact with the private Kubernetes cluster"
  sensitive   = true
}

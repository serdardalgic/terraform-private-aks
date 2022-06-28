variable "location" {
  description = "The resource group location"
  default     = "West Europe"
}

variable "vnet_resource_group_name" {
  description = "The resource group name to be created"
  default     = "serdar-networks"
}

variable "hub_vnet_name" {
  description = "Hub VNET name"
  default     = "hub1-firewalvnet"
}

variable "kube_vnet_name" {
  description = "AKS VNET name"
  default     = "spoke1-kubevnet"
}

variable "kube_version_prefix" {
  description = "AKS Kubernetes version prefix. Formatted '[Major].[Minor]' like '1.'. Patch version part (as in '[Major].[Minor].[Patch]') will be set to latest automatically."
  default     = "1.23"
}

variable "kube_resource_group_name" {
  description = "The resource group name to be created"
  default     = "serdar-nopublicipaks"
}

variable "nodepool_nodes_count" {
  description = "Default nodepool nodes count"
  default     = 1
}

variable "nodepool_min_count" {
  description = "Minimum count for the nodepool nodes, used within autoscaling"
  default     = 1
}

variable "nodepool_max_count" {
  description = "Maximum count for the nodepool nodes, used within autoscaling"
  default     = 2
}

variable "nodepool_vm_size" {
  description = "Default nodepool VM size"
  default     = "Standard_D2_v2"
}

variable "network_docker_bridge_cidr" {
  description = "CNI Docker bridge cidr"
  default     = "172.17.0.1/16"
}

variable "network_dns_service_ip" {
  description = "CNI DNS service IP"
  default     = "10.2.0.10"
}

variable "network_service_cidr" {
  description = "CNI service cidr"
  default     = "10.2.0.0/24"
}

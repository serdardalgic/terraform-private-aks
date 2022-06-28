resource "azurerm_resource_group" "vnet" {
  name     = var.vnet_resource_group_name
  location = var.location
  # TODO: Tag Resources in a more general way
  tags = {
    env       = "serdar-test"
    ManagedBy = "serdar.dalgic@enterprisedb.com"
  }
}

resource "azurerm_resource_group" "kube" {
  name     = var.kube_resource_group_name
  location = var.location
  tags = {
    env       = "serdar-test"
    ManagedBy = "serdar.dalgic@enterprisedb.com"
  }
}

########################################
# Virtual Networks
########################################
module "hub_network" {
  source              = "./modules/vnet"
  resource_group_name = azurerm_resource_group.vnet.name
  location            = var.location
  vnet_name           = var.hub_vnet_name
  address_space       = ["10.0.0.0/22"]
  subnets = [
    {
      name : "AzureFirewallSubnet"
      address_prefixes : ["10.0.0.0/24"]
    },
    {
      name : "jumpbox-subnet"
      address_prefixes : ["10.0.1.0/24"]
    }
  ]
}

module "kube_network" {
  source              = "./modules/vnet"
  resource_group_name = azurerm_resource_group.kube.name
  location            = var.location
  vnet_name           = var.kube_vnet_name
  address_space       = ["10.0.4.0/22"]
  subnets = [
    {
      name : "aks-subnet"
      address_prefixes : ["10.0.5.0/24"]
    }
  ]
}

########################################
# Virtual Network Peering
########################################
module "vnet_peering" {
  source              = "./modules/vnet_peering"
  vnet_1_name         = var.hub_vnet_name
  vnet_1_id           = module.hub_network.vnet_id
  vnet_1_rg           = azurerm_resource_group.vnet.name
  vnet_2_name         = var.kube_vnet_name
  vnet_2_id           = module.kube_network.vnet_id
  vnet_2_rg           = azurerm_resource_group.kube.name
  peering_name_1_to_2 = "HubToSpoke1"
  peering_name_2_to_1 = "Spoke1ToHub"
}

########################################
# Firewall
########################################
module "firewall" {
  source         = "./modules/firewall"
  resource_group = azurerm_resource_group.vnet.name
  location       = var.location
  pip_name       = "azureFirewalls-ip"
  fw_name        = "kubenetfw"
  subnet_id      = module.hub_network.subnet_ids["AzureFirewallSubnet"]
}

########################################
# Route Table
########################################
module "routetable" {
  source             = "./modules/route_table"
  resource_group     = azurerm_resource_group.vnet.name
  location           = var.location
  rt_name            = "kubenetfw_fw_rt"
  r_name             = "kubenetfw_fw_r"
  firewal_private_ip = module.firewall.fw_private_ip
  subnet_id          = module.kube_network.subnet_ids["aks-subnet"]
}

########################################
# Private Kubernetes Cluster
########################################

module "kubernetes_cluster" {
  source              = "./modules/private-aks"
  location            = var.location
  resource_group_name = azurerm_resource_group.kube.name
  subnet_id           = module.kube_network.subnet_ids["aks-subnet"]

  # To be able to set the userDefinedRouting outbound type,
  #   route table should be created beforehand
  depends_on = [module.routetable]
}

########################################
# Jumpbox
########################################
module "jumpbox" {
  source                  = "./modules/jumpbox"
  location                = var.location
  resource_group          = azurerm_resource_group.vnet.name
  vnet_id                 = module.hub_network.vnet_id
  subnet_id               = module.hub_network.subnet_ids["jumpbox-subnet"]
  dns_zone_name           = join(".", slice(split(".", module.kubernetes_cluster.private_fqdn), 1, length(split(".", module.kubernetes_cluster.private_fqdn))))
  dns_zone_resource_group = module.kubernetes_cluster.node_resource_group
}

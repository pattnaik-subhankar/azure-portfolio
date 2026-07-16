locals {
  name_prefix = "${var.workload_name}-${var.environment}"
  tags = merge(var.tags, {
    workload = var.workload_name
    environment = var.environment
    managed-by = "terraform"
    data-classification = "confidential"
  })
}

resource "azurerm_resource_group" "spoke" {
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.tags
}

module "network" {
  source              = "./modules/network"
  name_prefix         = local.name_prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.spoke.name
  spoke_vnet_cidr     = var.spoke_vnet_cidr
  tags                = local.tags
}

module "data" {
  source              = "./modules/data"
  name_prefix         = local.name_prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.spoke.name
  private_endpoint_subnet_id = module.network.private_endpoint_subnet_id
  tags                = local.tags
}

# API, Firewall, DNS Resolver and Policy assignment modules are intentionally
# parameterized next additions; see ARCHITECTURE.md for the enterprise boundary.

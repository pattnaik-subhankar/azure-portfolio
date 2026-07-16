variable "location" { type = string }
variable "environment" { type = string }
variable "workload_name" { type = string, default = "edgeforge" }
variable "tags" { type = map(string), default = {} }

locals {
  prefix = "${var.workload_name}-${var.environment}"
  tags = merge(var.tags, {
    workload = var.workload_name
    environment = var.environment
    managed-by = "terraform"
    criticality = "high"
  })
}

resource "azurerm_resource_group" "workload" {
  name     = "rg-${local.prefix}"
  location = var.location
  tags     = local.tags
}

module "observability" {
  source              = "./modules/observability"
  name_prefix         = local.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.workload.name
  tags                = local.tags
}

# Network, Event Hubs, ADLS and AKS modules are introduced only after an
# approved landing-zone subscription, CIDR plan, private DNS, and operating model exist.

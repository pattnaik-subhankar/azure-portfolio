variable "name_prefix" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "spoke_vnet_cidr" { type = string }
variable "tags" { type = map(string) }

resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.spoke_vnet_cidr]
  tags                = var.tags
}

resource "azurerm_subnet" "app_gateway" {
  name                 = "snet-appgw"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [cidrsubnet(var.spoke_vnet_cidr, 4, 0)]
}

resource "azurerm_subnet" "apim" {
  name                 = "snet-apim"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [cidrsubnet(var.spoke_vnet_cidr, 4, 1)]
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-private-endpoints"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [cidrsubnet(var.spoke_vnet_cidr, 4, 2)]
  private_endpoint_network_policies = "Disabled"
}

output "vnet_id" { value = azurerm_virtual_network.spoke.id }
output "private_endpoint_subnet_id" { value = azurerm_subnet.private_endpoints.id }

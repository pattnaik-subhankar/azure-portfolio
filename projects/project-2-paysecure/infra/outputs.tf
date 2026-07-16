output "spoke_resource_group_name" { value = azurerm_resource_group.spoke.name }
output "spoke_vnet_id" { value = module.network.vnet_id }
output "sql_server_fqdn" { value = module.data.sql_server_fqdn }

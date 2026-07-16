variable "name_prefix" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "private_endpoint_subnet_id" { type = string }
variable "tags" { type = map(string) }
variable "enable_sql_deployment" {
  description = "Safety switch: false keeps this portfolio skeleton non-deploying."
  type        = bool
  default     = false
}
variable "sql_administrator_login" {
  type      = string
  sensitive = true
  default   = null
}
variable "sql_administrator_password" {
  type      = string
  sensitive = true
  default   = null
}

resource "azurerm_mssql_server" "this" {
  count                        = var.enable_sql_deployment ? 1 : 0
  name                         = lower("sql${replace(var.name_prefix, "-", "")}")
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.sql_administrator_login
  administrator_login_password = var.sql_administrator_password
  public_network_access_enabled = false
  tags                         = var.tags

  lifecycle {
    precondition {
      condition     = var.sql_administrator_login != null && var.sql_administrator_password != null
      error_message = "Supply deployment-time credentials through a secure secret provider, then configure an Entra administrator before application onboarding."
    }
  }
}

# The disabled-by-default safety switch prevents accidental portfolio deployment.
# A production module adds Entra administrator configuration, private endpoint, and private DNS zone groups.

output "sql_server_fqdn" { value = try(azurerm_mssql_server.this[0].fully_qualified_domain_name, null) }

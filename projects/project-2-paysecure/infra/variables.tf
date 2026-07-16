variable "location" { type = string }
variable "environment" { type = string }
variable "workload_name" { type = string, default = "paysecure" }
variable "hub_vnet_cidr" { type = string }
variable "spoke_vnet_cidr" { type = string }
variable "tags" { type = map(string), default = {} }

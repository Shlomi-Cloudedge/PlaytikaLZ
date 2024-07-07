variable "location" {
  description = "region to deploy the managed identity."
  type = string
}

variable "hub_vnet_name" {
  description = "The name of the Hub VNet."
  type        = string
}

variable "hub_vnet_resource_group_name" {
  description = "The name of the resource group containing the Hub VNet."
  type        = string
}

variable "listOfAllowedSKUs" {
  description = "List of allowed VMs SkUs"
}
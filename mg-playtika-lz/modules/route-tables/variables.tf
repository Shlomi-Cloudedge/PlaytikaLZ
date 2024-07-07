# route-table/variables.tf

variable "subnets" {
  description = "Map of subnets to create routes for"
  type        = map(object({
    address_prefixes = list(string)
    delegations      = list(object({
      name              = string
      service_delegation = object({
        name    = string
        actions = list(string)
      })
    }))
  }))
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "fws_or_load_balancer_ip" {
  description = "IP address of the load balancer or FW"
  type        = string
}

variable "suffix" {
  description = "suffix of the route tables names"
  type = string
}

variable "tags" {
  description = "tags of the route tables"
}
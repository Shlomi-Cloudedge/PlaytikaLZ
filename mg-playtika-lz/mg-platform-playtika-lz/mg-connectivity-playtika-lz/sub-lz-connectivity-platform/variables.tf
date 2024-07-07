variable "subnets" {
  description = "Map of subnets to create routes for"
  type = map(object({
    name             = optional(string)
    address_prefixes = list(string)
    delegations = optional(list(object({
      name = string
      service_delegation = object({
        name    = string
        actions = list(string)
      })
    })))
  }))
}

# variable "fws_or_load_balancer_ip" {
#   description = "IP address of the load balancer or FW"
#   type        = string
# }

variable "virtual_network_address_space" {
  description = "VNet CIDR"
  type        = list(string)
}

variable "client_secret_service_principal" {
  description = "Service principal client_secret to authenticate to azure."
  type        = string
  nullable    = false
}

variable "tenant_id" {
  description = "The id of Playtika LTD Tenant in Azure"
  type        = string
}

variable "connectivity_subscription_id" {
  description = "The subscription ID of the workload"
  type        = string
}

variable "service_principal_client_id" {
  description = "Service principal ID to authenticate to Azure."
  type        = string
}


variable "password_length" {
  description = "The length of the random password."
  type        = number
  default     = 12
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "location" {
  description = "The location for all resources."
  type        = string
  default     = "westeurope"
}

variable "environment" {
  description = "The environment tag."
  type        = string
}

variable "public_ip_name" {
  description = "The name of the public IP."
  type        = string
}

variable "vm_name" {
  description = "The name of the virtual machine."
  type        = string
}

variable "vm_size" {
  description = "The size of the virtual machine."
  type        = string
}

variable "admin_username" {
  description = "The admin username for the virtual machine."
  type        = string
}

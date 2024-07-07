variable "location" {
  description = "region to deploy the azure resources."
  type = string
}

variable "log_analytics_sku" {
  description = "the log analytics sku (required)"
  type = string
}

variable "client_secret_service_principal" {
  description = "the client secret of the service principal to authenticate for the subscription"
  type = string
  nullable = false
}

variable "subnets" {
  description = "Map of subnets to create routes for"
  type = map(object({
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

variable "virtual_network_address_space" {
  description = "VNet CIDR"
  type        = list(string)
}

variable "fws_or_load_balancer_ip" {
  description = "trusted NIC ip of the FW"
  type = string
}
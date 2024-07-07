provider "azurerm" {
  alias = "connectivity-subscription"
  subscription_id = "0c518f2b-6f6d-412b-8408-faddb4fc5b99"

  features {}
}

data "azurerm_virtual_network" "hub-vnet" {
  provider = azurerm.connectivity-subscription
  name = "vnet-hub-prod-we-001"
  resource_group_name = "rg-netsec-hub-prod-we-001"
}

data "azurerm_private_dns_zone" "events-hub-dns-zone" {
  provider = azurerm.connectivity-subscription
  name = "privatelink.servicebus.windows.net"
  resource_group_name = "rg-dns-hub-prod-we-001"
}
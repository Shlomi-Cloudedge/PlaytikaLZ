data "azurerm_client_config" "current" {}

data "azurerm_virtual_network" "mgmt-vnet" {
  provider            = azurerm.mgmnt-subscription
  name                = "vnet-netsec-mgmt-prod-we-001"
  resource_group_name = "rg-netsec-mgmt-prod-we-001"
}

provider "azurerm" {
  alias           = "mgmnt-subscription"
  subscription_id = "d2b9ffa4-5f45-4b08-9429-6d18e4767db7"
  features {}
}
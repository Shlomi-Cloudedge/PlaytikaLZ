#_______________Azure naming convention_______________

module "hub_rg_naming" {
  source = "Azure/naming/azurerm"
  suffix = ["netsec", "hub", "prod", "we"]
}

module "hub_resource_naming" {
  source = "Azure/naming/azurerm"
  suffix = ["hub", "prod", "we"]
}
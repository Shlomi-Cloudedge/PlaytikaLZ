module "monitor_naming" {
  source = "Azure/naming/azurerm"
  suffix = ["monitor" ,"mgmt" , "prod" , "we"]
}


module "management_naming" {
  source = "Azure/naming/azurerm"
  suffix = ["mgmt", "prod", "we"]
}

module "netsec_rg_naming" {
  source = "Azure/naming/azurerm"
  suffix = ["netsec", "mgmt", "prod", "we"]
}
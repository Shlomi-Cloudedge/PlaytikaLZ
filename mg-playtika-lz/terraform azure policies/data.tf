provider "azurerm" {
  alias           = "management-subscription"
  subscription_id = "d2b9ffa4-5f45-4b08-9429-6d18e4767db7"
  features {}
}

provider "azurerm" {
  alias           = "connectivity-subscription"
  subscription_id = "0c518f2b-6f6d-412b-8408-faddb4fc5b99"
  features {}
}

data "azurerm_management_group" "mg-playtika-lz" {
  name = "mg-playtika-lz"
}

data "azurerm_management_group" "mg-business-units" {
  name = "mg-business-units-playtika-lz"
}

data "azurerm_management_group" "mg-playground-playtika-lz" {
  name = "mg-playground-playtika-lz"
}

data "azurerm_management_group" "mg-connectivity-playtika-lz" {
  name = "mg-connectivity-playtika-lz"
}

data "azurerm_management_group" "mg-platform-playtika-lz" {
  name = "mg-platform-playtika-lz"
}

output "playground_mg_id" {
  value = data.azurerm_management_group.mg-playground-playtika-lz.id
}

data "azurerm_log_analytics_workspace" "landing-zones-log-analytics" {
  provider            = azurerm.management-subscription
  resource_group_name = "rg-monitor-mgmt-prod-we-001"
  name                = "log-monitor-mgmt-prod-we-001"
}

data "azurerm_eventhub" "azure-activity-logs-eventhub" {
  provider = azurerm.management-subscription
  name = "splunk-event-hub"
  namespace_name = "evh-monitor-mgmt-prod-we-001"
  resource_group_name = "rg-monitor-mgmt-prod-we-001"
}

data "azurerm_eventhub_namespace" "azure-activity-logs-eventhubs"{
  provider = azurerm.management-subscription
  name = "evh-monitor-mgmt-prod-we-001"
  resource_group_name = "rg-monitor-mgmt-prod-we-001"
}
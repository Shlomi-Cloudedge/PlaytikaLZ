resource "azurerm_resource_group" "monitor_rg" {
  name     = "${module.monitor_naming.resource_group.name}-001"
  location = var.location
  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })
    lifecycle {
    ignore_changes = [ tags["auto_creation_date"] ]
  }
}



resource "azurerm_log_analytics_workspace" "management-monitor" {
  name                = "${module.monitor_naming.log_analytics_workspace.name}-001"
  location            = azurerm_resource_group.monitor_rg.location
  resource_group_name = azurerm_resource_group.monitor_rg.name
  sku                 = var.log_analytics_sku
  retention_in_days   = 30
  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })
    lifecycle {
    ignore_changes = [ tags["auto_creation_date"] ]
  }
}

# Event Hub

resource "azurerm_eventhub_namespace" "azure-activity-logs-eventhubs" {
  name                = "${module.monitor_naming.eventhub.name}-001"
  location            = azurerm_resource_group.monitor_rg.location
  resource_group_name = azurerm_resource_group.monitor_rg.name
  sku                 = "Standard"
  capacity            = 1
  auto_inflate_enabled = true
  maximum_throughput_units = 1
  public_network_access_enabled = true

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [ tags["auto_creation_date"] ]
  }
}

resource "azurerm_eventhub" "azure-activity-logs-eventhub" {
  name                = "splunk-event-hub"
  namespace_name      = azurerm_eventhub_namespace.azure-activity-logs-eventhubs.name
  resource_group_name = azurerm_resource_group.monitor_rg.name
  partition_count     = 1
  message_retention   = 1
}

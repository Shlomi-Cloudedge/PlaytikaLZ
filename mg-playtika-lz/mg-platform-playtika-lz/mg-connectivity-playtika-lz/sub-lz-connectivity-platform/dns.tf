#_____________________________________DNS Private Resolver_____________________________

module "hub_dns_resource_naming" {
  source = "Azure/naming/azurerm"
  suffix = ["dns", "hub", "prod", "we"]
}

resource "azurerm_resource_group" "dns_rg" {
  name     = "${module.hub_dns_resource_naming.resource_group.name}-001"
  location = var.location

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })
}


resource "azurerm_private_dns_resolver" "hub_dns_private_resolver" {
  name                = "dspr-dns-hub-prod-we-001"
  resource_group_name = azurerm_resource_group.dns_rg.name
  location            = var.location
  virtual_network_id  = azurerm_virtual_network.hub-vnet.id

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}

#inbound_endpoint
resource "azurerm_private_dns_resolver_inbound_endpoint" "dns-resolver-inbound-endpoint" {
  name                    = "private-dns-resolver-inbound-001"
  private_dns_resolver_id = azurerm_private_dns_resolver.hub_dns_private_resolver.id
  location                = var.location
  ip_configurations {
    private_ip_allocation_method = "Dynamic"
    subnet_id                    = azurerm_subnet.subnet["dns-private-resolver-inbound-subnet"].id
  }

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}


#outbound_endpoint
resource "azurerm_private_dns_resolver_outbound_endpoint" "dns-resolver-outbound-endpoint" {
  name                    = "private-dns-resolver-outbound-001"
  private_dns_resolver_id = azurerm_private_dns_resolver.hub_dns_private_resolver.id
  location                = var.location
  subnet_id               = azurerm_subnet.subnet["dns-private-resolver-outbound-subnet"].id

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}


#route tables



################### AZURE PRIVATE DNS ZONES ###################

resource "azurerm_private_dns_zone" "storage-account-blobs-dns-zone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.dns_rg.name

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob-private-dns-zone-hub-link" {
  name                  = "hub-link"
  resource_group_name   = azurerm_resource_group.dns_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.storage-account-blobs-dns-zone.name
  virtual_network_id    = azurerm_virtual_network.hub-vnet.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob-private-dns-zone-mgmt-link" {
  name                  = "mgmt-link"
  resource_group_name   = azurerm_resource_group.dns_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.storage-account-blobs-dns-zone.name
  virtual_network_id    = data.azurerm_virtual_network.mgmt-vnet.id
}


resource "azurerm_private_dns_a_record" "tfstates-a-record" {
  name                = "stpttfstateswe001"
  zone_name           = azurerm_private_dns_zone.storage-account-blobs-dns-zone.name
  resource_group_name = azurerm_resource_group.dns_rg.name
  ttl                 = 3600
  records             = ["10.49.202.4"]
}


resource "azurerm_private_dns_zone" "event-hubs-dns-zone" {
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = azurerm_resource_group.dns_rg.name

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "event-hubs-dns-zone-hub-link" {
  name                  = "hub-link"
  resource_group_name   = azurerm_resource_group.dns_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.event-hubs-dns-zone.name
  virtual_network_id    = azurerm_virtual_network.hub-vnet.id

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "event-hubs-dns-zone-mgmt-link" {
  name                  = "mgmt-link"
  resource_group_name   = azurerm_resource_group.dns_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.event-hubs-dns-zone.name
  virtual_network_id    = data.azurerm_virtual_network.mgmt-vnet.id

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}


#Key Vault DNS Zone

resource "azurerm_private_dns_zone" "key-vaults-dns-zone" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.dns_rg.name

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvaults-dns-zone-hub-link" {
  name                  = "hub-link"
  resource_group_name   = azurerm_resource_group.dns_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.key-vaults-dns-zone.name
  virtual_network_id    = azurerm_virtual_network.hub-vnet.id

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvaults-dns-zone-mgmt-link" {
  name                  = "mgmt-link"
  resource_group_name   = azurerm_resource_group.dns_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.key-vaults-dns-zone.name
  virtual_network_id    = data.azurerm_virtual_network.mgmt-vnet.id

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}

#OpenAI Private DNS Zone

resource "azurerm_private_dns_zone" "open-ai-dns-zone" {
  name                = "privatelink.openai.azure.com"
  resource_group_name = azurerm_resource_group.dns_rg.name

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "openai-dns-zone-hub-link" {
  name                  = "hub-link"
  resource_group_name   = azurerm_resource_group.dns_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.open-ai-dns-zone.name
  virtual_network_id    = azurerm_virtual_network.hub-vnet.id

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "openai-dns-zone-mgmt-link" {
  name                  = "mgmt-link"
  resource_group_name   = azurerm_resource_group.dns_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.open-ai-dns-zone.name
  virtual_network_id    = data.azurerm_virtual_network.mgmt-vnet.id

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}


#Azure Bot Services Private DNS Zone

resource "azurerm_private_dns_zone" "azure-bot-services-dns-zone" {
  name                = "privatelink.directline.botframework.com"
  resource_group_name = azurerm_resource_group.dns_rg.name

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "azure-bot-services-dns-zone-hub-link" {
  name                  = "hub-link"
  resource_group_name   = azurerm_resource_group.dns_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.azure-bot-services-dns-zone.name
  virtual_network_id    = azurerm_virtual_network.hub-vnet.id

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "azure-bot-services-dns-zone-mgmt-link" {
  name                  = "mgmt-link"
  resource_group_name   = azurerm_resource_group.dns_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.azure-bot-services-dns-zone.name
  virtual_network_id    = data.azurerm_virtual_network.mgmt-vnet.id

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}


#Azure App services/Function apps Private DNS Zone

resource "azurerm_private_dns_zone" "apps-services-dns-zone" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.dns_rg.name

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "apps-dns-zone-hub-link" {
  name                  = "hub-link"
  resource_group_name   = azurerm_resource_group.dns_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.apps-services-dns-zone.name
  virtual_network_id    = azurerm_virtual_network.hub-vnet.id

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "apps-dns-zone-mgmt-link" {
  name                  = "mgmt-link"
  resource_group_name   = azurerm_resource_group.dns_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.apps-services-dns-zone.name
  virtual_network_id    = data.azurerm_virtual_network.mgmt-vnet.id

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}


#Azure Arc Kubernetes dns zone

resource "azurerm_private_dns_zone" "arc-kubernetes-dns-zone" {
  name                = "privatelink.dp.kubernetesconfiguration.azure.com"
  resource_group_name = azurerm_resource_group.dns_rg.name

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "arc-kubernetes-zone-hub-link" {
  name                  = "hub-link"
  resource_group_name   = azurerm_resource_group.dns_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.arc-kubernetes-dns-zone.name
  virtual_network_id    = azurerm_virtual_network.hub-vnet.id

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "arc-kubernetes-dns-zone-mgmt-link" {
  name                  = "mgmt-link"
  resource_group_name   = azurerm_resource_group.dns_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.arc-kubernetes-dns-zone.name
  virtual_network_id    = data.azurerm_virtual_network.mgmt-vnet.id

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}


#Azure Arc compute dns zone

resource "azurerm_private_dns_zone" "arc-compute-dns-zone" {
  name                = "privatelink.guestconfiguration.azure.com"
  resource_group_name = azurerm_resource_group.dns_rg.name

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "arc-compute-zone-hub-link" {
  name                  = "hub-link"
  resource_group_name   = azurerm_resource_group.dns_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.arc-compute-dns-zone.name
  virtual_network_id    = azurerm_virtual_network.hub-vnet.id

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "arc-compute-zone-mgmt-link" {
  name                  = "mgmt-link"
  resource_group_name   = azurerm_resource_group.dns_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.arc-compute-dns-zone.name
  virtual_network_id    = data.azurerm_virtual_network.mgmt-vnet.id

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}


#Azure Arc hybrid his compute dns zone

resource "azurerm_private_dns_zone" "arc-his-dns-zone" {
  name                = "privatelink.his.arc.azure.com"
  resource_group_name = azurerm_resource_group.dns_rg.name

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "arc-his-zone-hub-link" {
  name                  = "hub-link"
  resource_group_name   = azurerm_resource_group.dns_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.arc-his-dns-zone.name
  virtual_network_id    = azurerm_virtual_network.hub-vnet.id

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "arc-his-zone-mgmt-link" {
  name                  = "mgmt-link"
  resource_group_name   = azurerm_resource_group.dns_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.arc-his-dns-zone.name
  virtual_network_id    = data.azurerm_virtual_network.mgmt-vnet.id

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}


#Azure Search Services dns zone

resource "azurerm_private_dns_zone" "search-services-dns-zone" {
  name                = "privatelink.search.windows.net"
  resource_group_name = azurerm_resource_group.dns_rg.name

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "search-services-zone-hub-link" {
  name                  = "hub-link"
  resource_group_name   = azurerm_resource_group.dns_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.search-services-dns-zone.name
  virtual_network_id    = azurerm_virtual_network.hub-vnet.id

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "search-services-zone-mgmt-link" {
  name                  = "mgmt-link"
  resource_group_name   = azurerm_resource_group.dns_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.search-services-dns-zone.name
  virtual_network_id    = data.azurerm_virtual_network.mgmt-vnet.id

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}

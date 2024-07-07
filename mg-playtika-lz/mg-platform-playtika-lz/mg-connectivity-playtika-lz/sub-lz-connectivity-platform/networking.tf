resource "azurerm_resource_group" "netsec_rg" {
  name     = "${module.hub_rg_naming.resource_group.name}-001"
  location = var.location

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}

resource "azurerm_virtual_network" "hub-vnet" {
  name                = "${module.hub_resource_naming.virtual_network.name}-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.netsec_rg.name
  address_space       = var.virtual_network_address_space

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })
  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}

resource "azurerm_subnet" "subnet" {
  for_each             = var.subnets
  name                 = each.key
  resource_group_name  = azurerm_resource_group.netsec_rg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefixes     = each.value.address_prefixes

  dynamic "delegation" {
    for_each = coalesce(each.value.delegations, []) # Use coalesce to handle null delegations
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}

#______________________KEY VAULT__________________________

resource "azurerm_key_vault" "hub_kv" {
  name                       = "kv-pt-hub-prod-we-001"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.netsec_rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 45
  sku_name                   = "premium"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Get",
    ]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover"
    ]
  }
  network_acls {
    ip_rules = ["194.90.247.32", "93.173.250.236", "62.0.120.222"]

    default_action = "Deny"

    bypass = "None"
  }

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}

resource "azurerm_key_vault_secret" "fw_password_secret" {
  name         = "fw-password"
  value        = random_password.random_password.result
  key_vault_id = azurerm_key_vault.hub_kv.id
}


module "route-tables" {
  source                  = "../../../modules/route-tables"
  subnets                 = var.subnets
  location                = var.location
  resource_group_name     = azurerm_resource_group.netsec_rg.name
  suffix                  = azurerm_virtual_network.hub-vnet.name
  fws_or_load_balancer_ip = azurerm_network_interface.trusted_nic.private_ip_address
  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })
}


resource "azurerm_subnet_route_table_association" "subnet_route_table_association" {
  for_each = { for k, v in azurerm_subnet.subnet : k => v if k != "untrusted-fw-subnet" && k != "trusted-fw-subnet" && k != "mgmt-fw-subnet" }

  subnet_id      = each.value.id
  route_table_id = module.route-tables.route_table_ids[each.key]
}

#Peering to Hub VNet
resource "azurerm_virtual_network_peering" "hub-to-mgmt" {
  name                      = "${azurerm_virtual_network.hub-vnet.name}-to-${data.azurerm_virtual_network.mgmt-vnet.name}"
  resource_group_name       = azurerm_resource_group.netsec_rg.name
  virtual_network_name      = azurerm_virtual_network.hub-vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.mgmt-vnet.id
  allow_forwarded_traffic   = true
}
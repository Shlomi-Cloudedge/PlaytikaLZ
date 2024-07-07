#_____________________________________PALO ALTO FW_____________________________

resource "random_password" "random_password" {
  length = var.password_length
}

resource "azurerm_public_ip" "mgmt-pip-fw" {
  name                = "pip-mgmt-fw-hub-prod-we-001"
  resource_group_name = azurerm_resource_group.netsec_rg.name
  location            = var.location
  allocation_method   = "Static"

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}

resource "azurerm_public_ip" "untrusted-pip-fw" {
  name                = "pip-untrusted-fw-hub-prod-we-001"
  resource_group_name = azurerm_resource_group.netsec_rg.name
  location            = var.location
  allocation_method   = "Static"

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}

resource "azurerm_network_interface" "mgmt_nic" {
  name                = "nic-${azurerm_subnet.subnet["mgmt-fw-subnet"].name}-hub-prod-we-001"
  location            = azurerm_resource_group.netsec_rg.location
  resource_group_name = azurerm_resource_group.netsec_rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet["mgmt-fw-subnet"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mgmt-pip-fw.id
  }


  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })


  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}

resource "azurerm_network_interface" "untrusted_nic" {
  name                 = "nic-${azurerm_subnet.subnet["untrusted-fw-subnet"].name}-hub-prod-we-001"
  location             = azurerm_resource_group.netsec_rg.location
  resource_group_name  = azurerm_resource_group.netsec_rg.name
  enable_ip_forwarding = true
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet["untrusted-fw-subnet"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.untrusted-pip-fw.id
  }

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}

resource "azurerm_network_interface" "trusted_nic" {
  name                 = "nic-${azurerm_subnet.subnet["trusted-fw-subnet"].name}-hub-prod-we-001"
  location             = azurerm_resource_group.netsec_rg.location
  resource_group_name  = azurerm_resource_group.netsec_rg.name
  enable_ip_forwarding = true
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet["trusted-fw-subnet"].id
    private_ip_address_allocation = "Dynamic"
  }

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}


resource "azurerm_linux_virtual_machine" "palo-alto-vm" {
  name                            = "fw-${module.hub_resource_naming.virtual_machine.name}-001"
  resource_group_name             = azurerm_resource_group.netsec_rg.name
  location                        = var.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_password                  = azurerm_key_vault_secret.fw_password_secret.value
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.mgmt_nic.id,
    azurerm_network_interface.trusted_nic.id,
    azurerm_network_interface.untrusted_nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "paloaltonetworks"
    offer     = "vmseries-flex"
    sku       = "byol"
    version   = "latest"
  }

  plan {
    name      = "byol"
    publisher = "paloaltonetworks"
    product   = "vmseries-flex"
  }

  tags = merge(local.tags, {
    "Created By" = "shlomil@playtika.com"
  })

  lifecycle {
    ignore_changes = [tags["auto_creation_date"]]
  }
}
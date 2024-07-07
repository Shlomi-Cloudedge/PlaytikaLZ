#_________________________HUB AND SPOKE POLICY_____________________________

# Define a custom policy to deny peering between spoke VNets and restrict peering to only approved VNets (Hub VNets).
resource "azurerm_policy_definition" "deny-peering-between-spokes" {
  management_group_id = data.azurerm_management_group.mg-playtika-lz.id
  name                = "deny-peering-between-spokes"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "deny-peering-between-spokes"
  description         = "This policy denied you from peering to a VNet that's not on the list of approved VNets. (Hub virtual networks)"

  # Reference to the metadata file defining additional information about the policy
  metadata = file("./policy-defenitions/allow-peering-only-to-hubs/azurepolicy.json")

  # Reference to the parameters file specifying input parameters for the policy
  parameters = file("./policy-defenitions/allow-peering-only-to-hubs/azurepolicy.parameters.json")

  # Reference to the policy rule file defining the conditions and actions of the policy
  policy_rule = file("./policy-defenitions/allow-peering-only-to-hubs/azurepolicy.rules.json")

}

# Retrieve details of the Hub VNet to be used as an approved peering target
data "azurerm_virtual_network" "hub-vnet" {
  provider = azurerm.connectivity-subscription
  name                = var.hub_vnet_name
  resource_group_name = var.hub_vnet_resource_group_name
}

# Assign the custom policy to the management group to enforce the restriction to the selected scope
resource "azurerm_management_group_policy_assignment" "deny-peering-between-spokes-assignment" {
  name         = "peering-to-hub"
  display_name = "deny-peering-between-spokes-assignment"

  # Specify scope for the assignment
  management_group_id  = data.azurerm_management_group.mg-playtika-lz.id
  description          = "This policy denied you from peering to a VNet that's not on the list of approved VNets. (Hub virtual networks)"
  policy_definition_id = azurerm_policy_definition.deny-peering-between-spokes.id

  # Specify scopes that are exempt from this policy
  not_scopes = [data.azurerm_management_group.mg-playground-playtika-lz.id , data.azurerm_virtual_network.hub-vnet.id]

  # Define the parameters for the policy assignment, including the list of allowed VNets and the policy effect
  parameters = <<PARAMETERS
  {
    "allowedVNets": {
      "value": [
        "${data.azurerm_virtual_network.hub-vnet.id}"
      ]
    },
    "effect": {
      "value": "Deny"
    }
  }
  PARAMETERS
}

#_________________________Allowed Location Policy_____________________________

resource "azurerm_management_group_policy_assignment" "allowed-regions-for-resource-creation" {
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
  management_group_id = data.azurerm_management_group.mg-playtika-lz.id
  display_name = "allowed-regions-for-resource-creation"
  description = "This policy enables you to restrict the locations your organization can specify when deploying resources. Use to enforce your geo-compliance requirements. Excludes resource groups, Microsoft.AzureActiveDirectory/b2cDirectories, and resources that use the 'global' region."
  not_scopes = [data.azurerm_management_group.mg-playground-playtika-lz.id]
  name                 = "allowed-locations"

parameters = <<PARAMETERS
{
  "listOfAllowedLocations": {
    "value": [
      "global",
      "westEurope",
      "northeurope",
      "BelgiumCentral",
      "DenmarkEast",
      "FinlandCentral",
      "FranceCentral",
      "francesouth",
      "germanycentral",
      "germanynorth",
      "germanynortheast",
      "germanywestcentral",
      "greececentral",
      "italynorth",
      "norwayeast",
      "norwaywest",
      "polandcentral",
      "spaincentral",
      "swedencentral",
      "swedensouth",
      "switzerlandnorth",
      "switzerlandwest",
      "uksouth",
      "ukwest",
      "austriaeast",
      "centralus",
      "eastus",
      "eastus2",
      "eastus3",
      "northcentralus",
      "southcentralus",
      "westcentralus",
      "westus",
      "westus2",
      "westus3",
      "canadacentral",
      "canadaeast",
      "Australia",
      "canada",
      "israelCentral"
    ]
  }
}
PARAMETERS
}

#_________________________Not Allowed Resource types Policy_____________________________

# Define a policy assignment to restrict the deployment of certain resource types within a selected scope.
resource "azurerm_management_group_policy_assignment" "deny-not-allowed-resource-types-assignment" {
  name                 = "not-allowed-resources"
  display_name         = "deny-not-allowed-resource-types-assignment"
  description          = "Restrict which resource types can be deployed in your environment. Limiting resource types can reduce the complexity and attack surface of your environment while also helping to manage costs. Compliance results are only shown for non-compliant resources."
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/6c112d4e-5bc7-47ae-a041-ea2d9dccd749"

  # Specify the management group to which the policy assignment applies.
  management_group_id = data.azurerm_management_group.mg-business-units.id

  # Define parameters for the policy assignment to specify the list of disallowed resource types.
  parameters = <<PARAMETERS
  {
    "listOfResourceTypesNotAllowed": {
      "value": [
        "Microsoft.Network/virtualNetworkGateways",
        "Microsoft.Network/applicationGateways",
        "Microsoft.Network/dnsResolvers",
        "Microsoft.Network/dnsZones",
        "Microsoft.Network/azureFirewalls",
        "Microsoft.Network/publicIPAddresses",
        "Microsoft.Network/frontDoors"
      ]
    }
  }
  PARAMETERS
}

#_________________________Require Tags on resources_____________________________

# Define a policy to deny resources without required tags.
resource "azurerm_policy_definition" "deny-resources-without-required-tags" {
  name        = "deny-resources-without-required-tags"
  description = "Deny resources without required tags"

  # Define scope for the policy definition
  management_group_id = data.azurerm_management_group.mg-playtika-lz.id
  mode                = "Indexed"
  display_name        = "deny-resources-without-required-tags"
  policy_type         = "Custom"
  metadata            = file("./policy-defenitions/deny-resources-without-tags/azurepolicy.json")
  policy_rule         = file("./policy-defenitions/deny-resources-without-tags/azurepolicy.rules.json")
  parameters          = file("./policy-defenitions/deny-resources-without-tags/azurepolicy.parameters.json")
}

# Assign the policy to a management group to enforce the restriction.
resource "azurerm_management_group_policy_assignment" "deny-resources-without-required-tags-assignment" {
  name         = "deny-tags"
  display_name = "deny-resources-without-required-tags-assignment"
  description  = "Deny resources without required tags , the required tags are : environment, project, owner, created by, location, creation date"
  # Specify the management group to which the policy assignment applies.
  management_group_id  = data.azurerm_management_group.mg-playtika-lz.id
  policy_definition_id = azurerm_policy_definition.deny-resources-without-required-tags.id
  not_scopes = ["/subscriptions/d2b9ffa4-5f45-4b08-9429-6d18e4767db7/resourceGroups/rg-dr-mgmt-prod-we-001",
                "/subscriptions/d2b9ffa4-5f45-4b08-9429-6d18e4767db7/resourceGroups/rg-compute-mgmt-prod-we-001"]
  # Define parameters for the policy assignment to specify the required tags and the effect of the policy.
  parameters           = <<PARAMETERS
    {
      "environment": {
       "value": "Env"
     },
     "business-criticality": {
       "value": "Business Criticality"
     },
     "owner": {
       "value": "Owner Email"
     },
     "createdBy": {
       "value": "Created By"
     },
     "Department": {
       "value": "Department"
     },
     "business-unit": {
       "value": "Business Unit"
     },
      "effect": {
       "value": "Deny"
     }
    }
    PARAMETERS
}

#_________________________Audit VMs that do not use managed disks_____________________________


############################# Not includes in the LLD doc #############################

# resource "azurerm_management_group_policy_assignment" "audit-vms-that-do-not-use-managed-disks" {
#   name = "audit-vms-that-do-not-use-managed-disks"
#   policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/06a78e20-9358-41c9-923c-fb736d382a4d"
#   management_group_id = "mg-playtika-lz" 
# }

#_________________________Audit unattached managed disks_____________________________

# Define a policy to audit unattached managed disks.
resource "azurerm_policy_definition" "audit-unattached-managed-disks" {
  name                = "audit-unattached-managed-disks"
  mode                = "All"
  description         = "This policy will audit all the unattached disks that can be deleted in order to save costs."

  # Specify the management group to which the policy definition belongs.
  management_group_id = data.azurerm_management_group.mg-playtika-lz.id
  display_name        = "audit-unattached-managed-disks"
  policy_type         = "Custom"
  policy_rule         = file("./policy-defenitions/audit-unattached-managed-disks/azurepolicy.rules.json")
  parameters          = file("./policy-defenitions/audit-unattached-managed-disks/azurepolicy.parameters.json")
}


# Assign the policy to a management group to enforce the auditing of unattached managed disks.
resource "azurerm_management_group_policy_assignment" "audit-unattached-managed-disks-assignment" {
  name                 = "audit-disks"
  display_name         = "audit-unattached-managed-disks-assignment"
  description          = "This policy will audit all the unattached disks that can be deleted in order to save costs."
  policy_definition_id = azurerm_policy_definition.audit-unattached-managed-disks.id

  # Specify the scope to which the policy assignment applies.
  management_group_id  = data.azurerm_management_group.mg-playtika-lz.id
}

# #_________________________Enforce Diagnostic setting on Subscriptions_____________________________

# Define a policy to configure diagnostic settings on subscriptions.
resource "azurerm_policy_definition" "set-diagnostic-setting-on-subscriptions" {
  name                = "set-diagnostic-setting-on-subscriptions"
  # Specify the scope to which the policy definition belongs.
  management_group_id = data.azurerm_management_group.mg-playtika-lz.id
  mode                = "All"
  description         = "This policy configures diagnostic settings for all subscriptions within the scope, directing logs to the dedicated Log Analytics workspace."
  display_name        = "set-diagnostic-setting-on-subscriptions"
  policy_type         = "Custom"
  metadata            = file("./policy-defenitions/set-diagnostic-settings-on-subscriptions/azurepolicy.json")
  policy_rule         = file("./policy-defenitions/set-diagnostic-settings-on-subscriptions/azurepolicy.rules.json")
  parameters          = file("./policy-defenitions/set-diagnostic-settings-on-subscriptions/azurepolicy.parameters.json")
}

# Assign the policy to a management group to enforce the configuration of diagnostic settings on subscriptions to the selected Log Analytics.
resource "azurerm_management_group_policy_assignment" "set-diagnostic-setting-on-subscriptions-assignment" {
  name                 = "logging-subs"
  display_name         = "set-diagnostic-setting-on-subscriptions-assignment"
  description          = "This policy configures diagnostic settings for all subscriptions within the scope, directing logs to the management Log Analytics workspace."
  policy_definition_id = azurerm_policy_definition.set-diagnostic-setting-on-subscriptions.id
  # Specify the scope to which the policy assignment applies.
  management_group_id  = data.azurerm_management_group.mg-playtika-lz.id
  # Location of the system-assigned managed identity.
  location             = var.location
  # Enable system-assigned managed identity for the policy assignment.
  identity {
    type = "SystemAssigned"
  }
  # Specify scopes that are exempt from this policy.
  not_scopes = [data.azurerm_management_group.mg-business-units.id]
  # Define parameters for the policy assignment to specify the Log Analytics workspace ID.
  parameters = <<PARAMETERS
    {
      "workspaceId": {
       "value": "${data.azurerm_log_analytics_workspace.landing-zones-log-analytics.id}"
     }
    }
    PARAMETERS
}

#DeployIfNotExists policies required managed identity with the following RBAC roles, in the code below we are assigning the required roles for the policy to take effect

resource "azurerm_role_assignment" "managed-identity-role-assignment_monitoring_cont_diag_sub" {
  scope                = data.azurerm_management_group.mg-playtika-lz.id
  principal_id         = azurerm_management_group_policy_assignment.set-diagnostic-setting-on-subscriptions-assignment.identity[0].principal_id
  role_definition_name = "Monitoring Contributor"
}

resource "azurerm_role_assignment" "managed-identity-role-assignment-log_analytics_cont_cont_diag_sub" {
  scope                = data.azurerm_management_group.mg-playtika-lz.id
  principal_id         = azurerm_management_group_policy_assignment.set-diagnostic-setting-on-subscriptions-assignment.identity[0].principal_id
  role_definition_name = "Log Analytics Contributor"
}

# #_________________________Network interfaces should not have public IPs_____________________________

# Define a policy assignment to deny public IPs from being attached to network interfaces.
resource "azurerm_management_group_policy_assignment" "deny-network-interface-public-ip-assignment" {
  name                 = "deny-nic-pip"
  display_name         = "deny-network-interface-public-ip-assignment"
  description          = "Deny public ips to be attached on network interfaces"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/83a86a26-fd1f-447c-b59d-e51f44264114"
  management_group_id  = data.azurerm_management_group.mg-business-units.id
}

# #_________________________Deny NSG allowing RDP and SSH from any source_____________________________

# Define a policy to deny allowing RDP and SSH from any source on NSGs.
resource "azurerm_policy_definition" "deny-nsg-allow-rdp-ssh-any" {
  management_group_id = data.azurerm_management_group.mg-playtika-lz.id
  name                = "deny-nsg-allow-rdp-ssh-any"
  mode                = "All"
  display_name        = "deny-nsg-allow-rdp-ssh-any"
  description         = "Deny RDP and SSH to be allowed from any source on NSGs."
  policy_type         = "Custom"
  metadata            = file("./policy-defenitions/deny-nsg-allowing-ssh-rdp-any/azurepolicy.json")
  policy_rule         = file("./policy-defenitions/deny-nsg-allowing-ssh-rdp-any/azurepolicy.rules.json")
  parameters          = file("./policy-defenitions/deny-nsg-allowing-ssh-rdp-any/azurepolicy.parameters.json")
}

# Assign the policy to a management group to enforce the denial of allowing RDP and SSH from any source on NSGs.
resource "azurerm_management_group_policy_assignment" "deny-nsg-allow-rdp-ssh-any-assignment" {
  name                 = "deny-nsg-any"
  display_name         = "deny-nsg-allow-rdp-ssh-any-assignment"
  policy_definition_id = azurerm_policy_definition.deny-nsg-allow-rdp-ssh-any.id
  description          = "Deny RDP and SSH to be allowed from any source on NSGs."
  # Specify the management group to which the policy assignment applies.
  management_group_id  = data.azurerm_management_group.mg-playtika-lz.id
  # Specify scopes that are exempt from this policy.
  not_scopes           = [data.azurerm_management_group.mg-playground-playtika-lz.id]

 # Define parameters for the policy assignment to specify the effect of the policy.
  parameters = <<PARAMETERS
    {
      "effect": {
       "value": "Deny"
     }
    }
    PARAMETERS
}

# #_________________________Secure transfer to storage accounts should be enabled_____________________________

# Define a policy assignment to enforce secure transfer to storage accounts.
resource "azurerm_management_group_policy_assignment" "secure-transfer-to-storage-accounts-assignment" {
  name                 = "secure-storage"
  description          = "This policy will force storage accounts to accept requests only from secure connections (HTTPS)"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9"
  # Specify the scope to which the policy assignment applies.
  management_group_id  = data.azurerm_management_group.mg-playtika-lz.id
}


# #_________________________Storage Accounts should not allow public blobs_____________________________

# Define a policy to deny public access to storage account blobs excluding those with the tag 'DataSecurity:Public'.
resource "azurerm_policy_definition" "deny-pulic-blobs-exlude-tag" {
  # Specify the scope to which the policy definition belongs.
  management_group_id = data.azurerm_management_group.mg-playtika-lz.id
  name                = "deny-pulic-blobs-exlude-tag"
  mode                = "Indexed"
  description         = "Prevent public access to storage accounts blob, will ignore storage accounts with the tag DataSecurity:Pulic"
  display_name        = "deny-pulic-blobs-exlude-tag"
  policy_type         = "Custom"
  metadata            = file("./policy-defenitions/deny-public-blobs/azurepolicy.json")
  policy_rule         = file("./policy-defenitions/deny-public-blobs/azurepolicy.rules.json")
  parameters          = file("./policy-defenitions/deny-public-blobs/azurepolicy.parameters.json")
}

# Assign the policy to a management group to enforce the denial of public access to storage account blobs, excluding those with the tag 'DataSecurity:Public'.
resource "azurerm_management_group_policy_assignment" "deny-pulic-blobs-exlude-tag-assignment" {
  name                 = "deny-pulic-blobs-tag"
  display_name         = "deny-pulic-blobs-exlude-tag-assignment"
  description          = "Prevent public access to storage accounts blob, will ignore storage accounts with the tag DataSecurity:Pulic"
  policy_definition_id = azurerm_policy_definition.deny-pulic-blobs-exlude-tag.id
  # Specify the scope to which the policy assignment applies.
  management_group_id  = data.azurerm_management_group.mg-playtika-lz.id
  # Specify scopes that are exempt from this policy.
  not_scopes           = [data.azurerm_management_group.mg-playground-playtika-lz.id]
  parameters           = <<PARAMETERS
    {
      "effect": {
      "value": "Deny"
     },
     "public": {
      "value": "DataSecurity"
     }
    }
  PARAMETERS
}

#   #_________________________Automation account variables should be encrypted_____________________________

# Define a policy assignment to audit automation accounts with unencrypted variables.
resource "azurerm_management_group_policy_assignment" "audit-automation-account-variables-encryption-assignment" {
  name                 = "auto-vars-encryption"
  display_name         = "audit-automation-account-variables-encryption-assignment"
  description          = "Audits automation accounts with not encrypted variables."
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/3657f5a0-770e-44a3-b44e-9431ba1e9735"

   # Specify the scope to which the policy assignment applies.
  management_group_id  = data.azurerm_management_group.mg-playtika-lz.id

  # Define parameters for the policy assignment to specify the effect as "Audit".
  parameters = <<PARAMETERS
    {
      "effect": {
    "value": "Audit"
      }
    }
    PARAMETERS
}


#_________________________Key vault Certificates should not expire within the specified number of days_____________________________

# Define a policy assignment to audit key vaults with certificates expiring in 45 days.
resource "azurerm_management_group_policy_assignment" "key-vault-certificates-expiration-audit-45day" {
  name                 = "kv-certs-45"
  display_name         = "key-vault-certificates-expiration-audit-45day"
  description          = "Audits key vaults with 45 days left certificate expiration date."
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/f772fb64-8e40-40ad-87bc-7706e1949427"
  # Specify the scope to which the policy assignment applies.
  management_group_id  = data.azurerm_management_group.mg-playtika-lz.id

# Define parameters for the policy assignment to specify the effect as "Audit" and the number of days to expire.
  parameters = <<PARAMETERS
    {
      "effect": {
        "value": "Audit"
      },
      "daysToExpire":{
        "value": 45
      }
    }
    PARAMETERS
}

#_________________________Defender for cloud enforcement_____________________________

# Defender for cloud will be enabled on these plans :
# App services , Databases , storage , key vaults , resource manager

resource "azurerm_management_group_policy_assignment" "deploy-defender-for-cloud-plans" {
  name                 = "defender-for-cloud"
  display_name         = "deploy-defender-for-cloud-plans"
  description          = "Deploys defener for cloud on subscriptions with those plans : App services, Databases, storage, key vaults, resource manager."
  policy_definition_id = "/providers/Microsoft.Management/managementGroups/mg-playtika-lz/providers/Microsoft.Authorization/policySetDefinitions/fcc07614bac84e3a83e6d92b"
  management_group_id  = data.azurerm_management_group.mg-playtika-lz.id

  # Location of the managed identity
  location             = var.location

  # Enables managed idenity on the policy assignment.
  identity {
    type = "SystemAssigned"
  }

}

#DeployIfNotExists policies required managed identity with the following RBAC roles, in the code below we are assigning the required roles for the policy to take effect

resource "azurerm_role_assignment" "managed-identity-role-assignment_owner" {
  scope                = data.azurerm_management_group.mg-playtika-lz.id
  principal_id         = azurerm_management_group_policy_assignment.deploy-defender-for-cloud-plans.identity[0].principal_id
  role_definition_name = "Owner"
}

resource "azurerm_role_assignment" "managed-identity-role-assignment-sec-admin" {
  scope                = data.azurerm_management_group.mg-playtika-lz.id
  principal_id         = azurerm_management_group_policy_assignment.deploy-defender-for-cloud-plans.identity[0].principal_id
  role_definition_name = "Security Admin"
}


#_________________________Enforce locks on key-vault_____________________________

# Define a policy to deny allowing RDP and SSH from any source on NSGs.
resource "azurerm_policy_definition" "enforce-resource-locks-on-key-vault" {
  management_group_id = data.azurerm_management_group.mg-playtika-lz.id
  name                = "enforce-resource-locks-on-key-vault"
  mode                = "All"
  display_name        = "enforce-resource-locks-on-key-vault"
  description         = "This policy will enforce Key vault locks."
  policy_type         = "Custom"
  metadata            = file("./policy-defenitions/enfore-locks-on-keyvault/azurepolicy.json")
  policy_rule         = file("./policy-defenitions/enfore-locks-on-keyvault/azurepolicy.rules.json")
}

resource "azurerm_management_group_policy_assignment" "locks-on-kv" {
  name                 = "locks-on-kv"
  display_name         = "enforce-resource-locks-on-key-vault"
  description          = "This policy will enforce Key vault locks."
  policy_definition_id = azurerm_policy_definition.enforce-resource-locks-on-key-vault.id
  management_group_id  = data.azurerm_management_group.mg-playtika-lz.id

  # Location of the managed identity
  location             = var.location

  # Enables managed idenity on the policy assignment.
  identity {
    type = "SystemAssigned"
  }

}


resource "azurerm_role_assignment" "managed-identity-role-assignment-backup-operator" {
  scope                = data.azurerm_management_group.mg-playtika-lz.id
  principal_id         = azurerm_management_group_policy_assignment.locks-on-kv.identity[0].principal_id
  role_definition_id = "/providers/Microsoft.Authorization/roleDefinitions/00c29273-979b-4161-815c-10b084fb9324"
}

resource "azurerm_role_assignment" "managed-identity-role-assignment-backup-user-acc-admin" {
  scope                = data.azurerm_management_group.mg-playtika-lz.id
  principal_id         = azurerm_management_group_policy_assignment.locks-on-kv.identity[0].principal_id
  role_definition_id = "/providers/Microsoft.Authorization/roleDefinitions/18d7d88d-d35e-4fb5-a5c3-7773c20a72d9"
}


#_________________________Enforce locks on VNets_____________________________


resource "azurerm_policy_definition" "enforce-resource-locks-on-vnets" {
  management_group_id = data.azurerm_management_group.mg-playtika-lz.id
  name                = "enforce-resource-locks-on-virtual-networks"
  mode                = "Indexed"
  display_name        = "enforce-resource-locks-on-virtual-networks"
  description         = "This policy will enforce Virtual Network locks."
  policy_type         = "Custom"
  metadata            = file("./policy-defenitions/resource-locks-on-vnet/azurepolicy.json")
  policy_rule         = file("./policy-defenitions/resource-locks-on-vnet/azurepolicy.rules.json")
  parameters          = file("./policy-defenitions/resource-locks-on-vnet/azurepolicy.parameters.json")
}


resource "azurerm_management_group_policy_assignment" "locks-on-vnets" {
  name                 = "locks-on-vnets"
  display_name         = "enforce-resource-locks-on-virtual-networks-assignment"
  description          = "This policy will enforce Virtual Network locks."
  policy_definition_id = azurerm_policy_definition.enforce-resource-locks-on-vnets.id
  management_group_id  = data.azurerm_management_group.mg-playtika-lz.id

  # Location of the managed identity
  location             = var.location

  # Enables managed idenity on the policy assignment.
  identity {
    type = "SystemAssigned"
  }

}

resource "azurerm_role_assignment" "managed-identity-role-assignment-owner" {
  scope                = data.azurerm_management_group.mg-playtika-lz.id
  principal_id         = azurerm_management_group_policy_assignment.locks-on-vnets.identity[0].principal_id
  role_definition_name = "Owner"
}


#_________________________Enforce Hybrid use benefits_____________________________

resource "azurerm_policy_definition" "enforce-hybrid-use-benefits" {
  # Specify the scope to which the policy definition belongs.
  management_group_id = data.azurerm_management_group.mg-playtika-lz.id
  name                = "enforce-hybrid-use-benefits"
  mode                = "All"
  description         = "This policy will enforce usage of hybrid use benefit."
  display_name        = "enforce-hybrid-use-benefits"
  policy_type         = "Custom"
  metadata            = file("./policy-defenitions/enforce-hybrid-benefits/azurepolicy.json")
  policy_rule         = file("./policy-defenitions/enforce-hybrid-benefits/azurepolicy.rules.json")
}

resource "azurerm_management_group_policy_assignment" "enforce-hybrid-use-benefits-assignment" {
  name                 = "enforce-hybrid-use"
  display_name         = "enforce-hybrid-use-benefits-assignment"
  description          = "This policy will enforce usage of hybrid use benefit."
  policy_definition_id = azurerm_policy_definition.enforce-hybrid-use-benefits.id
  # Specify the scope to which the policy assignment applies.
  management_group_id  = data.azurerm_management_group.mg-playtika-lz.id
  # Specify scopes that are exempt from this policy.
  not_scopes           = [data.azurerm_management_group.mg-playground-playtika-lz.id]
}


#_________________________Allowed VMs Skus_____________________________

# resource "azurerm_management_group_policy_assignment" "allowed-vms-skus-assignment" {
#   name                 = "allowed-vms-skus"
#   display_name         = "allowed-vms-skus-assignment"
#   description          = "Allows deploy VMs with approved SKUs"
#   policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/cccc23c7-8427-4f53-ad12-b6a63eb452b3"
#   # Specify the scope to which the policy assignment applies.
#   management_group_id  = data.azurerm_management_group.mg-playtika-lz.id
#   not_scopes = [ data.azurerm_management_group.mg-connectivity-playtika-lz.id ]
# # Define parameters for the policy assignment to specify the effect as "Audit" and the number of days to expire.
#   parameters = <<PARAMETERS
#   {
#     "listOfAllowedSKUs": {
#       "value": [
#         "${join("," , var.listOfAllowedSKUs)}"
#       ]
#     }
#   }
#   PARAMETERS
# }

#Storage account Diagnostic Settings

resource "azurerm_policy_definition" "storage-account-logging" {
  # Specify the scope to which the policy definition belongs.
  management_group_id = data.azurerm_management_group.mg-playtika-lz.id
  name                = "storage-account-logs-to-monitor"
  mode                = "Indexed"
  description         = "Deploys the diagnostic settings for Azure Storage, including blobs, files, tables, and queues to stream to a regional Log Analytics workspace when any Azure Storage which is missing this diagnostic settings is created or updated."
  display_name        = "storage-account-logs-to-log-analytics"
  policy_type         = "Custom"
  metadata            = file("./policy-defenitions/storage-account-diagnostic/azurepolicy.json")
  policy_rule         = file("./policy-defenitions/storage-account-diagnostic/azurepolicy.rules.json")
  parameters          = file("./policy-defenitions/storage-account-diagnostic/azurepolicy.parameters.json")
}

resource "azurerm_management_group_policy_assignment" "storage-account-logging-assignment" {
  name                 = "storage-account-logs"
  display_name         = "storage-account-logs-to-monitor"
  description          = "Deploys the diagnostic settings for Azure Storage, including blobs, files, tables, and queues to stream to a regional Log Analytics workspace when any Azure Storage which is missing this diagnostic settings is created or updated."
  policy_definition_id = azurerm_policy_definition.storage-account-logging.id
  # Specify the scope to which the policy assignment applies.
  management_group_id  = data.azurerm_management_group.mg-platform-playtika-lz.id


    # Location of the managed identity
  location             = var.location

  # Enables managed idenity on the policy assignment.
  identity {
    type = "SystemAssigned"
  }


  parameters = <<PARAMETERS
    {
      "logAnalytics": {
       "value": "${data.azurerm_log_analytics_workspace.landing-zones-log-analytics.id}"
     }
    }
    PARAMETERS
}

resource "azurerm_role_assignment" "managed-identity-role-assignment_monitoring_cont_diag_storage" {
  scope                = data.azurerm_management_group.mg-playtika-lz.id
  principal_id         = azurerm_management_group_policy_assignment.storage-account-logging-assignment.identity[0].principal_id
  role_definition_name = "Monitoring Contributor"
}

resource "azurerm_role_assignment" "managed-identity-role-assignment-log_analytics_cont_cont_diag_storage" {
  scope                = data.azurerm_management_group.mg-playtika-lz.id
  principal_id         = azurerm_management_group_policy_assignment.storage-account-logging-assignment.identity[0].principal_id
  role_definition_name = "Log Analytics Contributor"
}


#Diagnostic settings for Key vault

resource "azurerm_management_group_policy_assignment" "key-vault-logging-assignment" {
  name                 = "key-vault-account-logs"
  display_name         = "key-vault-logs-to-monitor"
  description          = "Deploys the diagnostic settings for Key Vault to stream to a regional Log Analytics workspace when any Key Vault which is missing this diagnostic settings is created or updated."
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/6b359d8f-f88d-4052-aa7c-32015963ecc1"
  # Specify the scope to which the policy assignment applies.
  management_group_id  = data.azurerm_management_group.mg-platform-playtika-lz.id


    # Location of the managed identity
  location             = var.location

  # Enables managed idenity on the policy assignment.
  identity {
    type = "SystemAssigned"
  }


  parameters = <<PARAMETERS
    {
      "logAnalytics": {
       "value": "${data.azurerm_log_analytics_workspace.landing-zones-log-analytics.id}"
     }
    }
    PARAMETERS
}

resource "azurerm_role_assignment" "managed-identity-role-assignment_monitoring_cont_diag_keyvault" {
  scope                = data.azurerm_management_group.mg-playtika-lz.id
  principal_id         = azurerm_management_group_policy_assignment.key-vault-logging-assignment.identity[0].principal_id
  role_definition_name = "Monitoring Contributor"
}

resource "azurerm_role_assignment" "managed-identity-role-assignment-log_analytics_cont_cont_diag_keyvault" {
  scope                = data.azurerm_management_group.mg-playtika-lz.id
  principal_id         = azurerm_management_group_policy_assignment.key-vault-logging-assignment.identity[0].principal_id
  role_definition_name = "Log Analytics Contributor"
}


#Diagnostic settings for Public IPs

resource "azurerm_management_group_policy_assignment" "public-ip-logging-assignment" {
  name                 = "public-ip-account-logs"
  display_name         = "public-ip-logs-to-monitor"
  description          = "Deploys the diagnostic settings for Key Vault to stream to a regional Log Analytics workspace when any Key Vault which is missing this diagnostic settings is created or updated."
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/1513498c-3091-461a-b321-e9b433218d28"
  # Specify the scope to which the policy assignment applies.
  management_group_id  = data.azurerm_management_group.mg-platform-playtika-lz.id


    # Location of the managed identity
  location             = var.location

  # Enables managed idenity on the policy assignment.
  identity {
    type = "SystemAssigned"
  }


  parameters = <<PARAMETERS
    {
      "logAnalytics": {
       "value": "${data.azurerm_log_analytics_workspace.landing-zones-log-analytics.id}"
     }
    }
    PARAMETERS
}

resource "azurerm_role_assignment" "managed-identity-role-assignment_monitoring_cont_diag_pip" {
  scope                = data.azurerm_management_group.mg-playtika-lz.id
  principal_id         = azurerm_management_group_policy_assignment.public-ip-logging-assignment.identity[0].principal_id
  role_definition_name = "Monitoring Contributor"
}

resource "azurerm_role_assignment" "managed-identity-role-assignment-log_analytics_cont_cont_diag_pip" {
  scope                = data.azurerm_management_group.mg-playtika-lz.id
  principal_id         = azurerm_management_group_policy_assignment.public-ip-logging-assignment.identity[0].principal_id
  role_definition_name = "Log Analytics Contributor"
}


# #_________________________Enforce Diagnostic setting on Subscriptions to event hub_____________________________

# Define a policy to configure diagnostic settings on subscriptions.
resource "azurerm_policy_definition" "set-diagnostic-setting-on-subscriptions-to-event-hub" {
  name                = "set-diagnostic-setting-on-subscriptions-to-event-hub"
  # Specify the scope to which the policy definition belongs.
  management_group_id = data.azurerm_management_group.mg-playtika-lz.id
  mode                = "All"
  description         = "This policy configures diagnostic settings for all subscriptions within the scope, directing logs to the dedicated Event Hub workspace."
  display_name        = "set-diagnostic-setting-on-subscriptions-to-event-hub"
  policy_type         = "Custom"
  metadata            = file("./policy-defenitions/subscription-diagnostic-event-hub/azurepolicy.json")
  policy_rule         = file("./policy-defenitions/subscription-diagnostic-event-hub/azurepolicy.rules.json")
  parameters          = file("./policy-defenitions/subscription-diagnostic-event-hub/azurepolicy.parameters.json")
}

# Assign the policy to a management group to enforce the configuration of diagnostic settings on subscriptions to the selected Log Analytics.
resource "azurerm_management_group_policy_assignment" "set-diagnostic-setting-on-subscriptions-to-event-hub-assignment" {
  name                 = "logging-subs-to-evh"
  display_name         = "set-diagnostic-setting-on-subscriptions-to-event-hub-assignment"
  description          = "This policy configures diagnostic settings for all subscriptions within the scope, directing logs to the management Event hub workspace."
  policy_definition_id = azurerm_policy_definition.set-diagnostic-setting-on-subscriptions-to-event-hub.id
  # Specify the scope to which the policy assignment applies.
  management_group_id  = data.azurerm_management_group.mg-playtika-lz.id
  # Location of the system-assigned managed identity.
  location             = var.location
  # Enable system-assigned managed identity for the policy assignment.
  identity {
    type = "SystemAssigned"
  }
  # Specify scopes that are exempt from this policy.
  # Define parameters for the policy assignment to specify the Log Analytics workspace ID.
  parameters = <<PARAMETERS
    {
      "eventHubName": {
       "value": "${data.azurerm_eventhub.azure-activity-logs-eventhub.name}"
     },
      "eventHubRuleId": {
        "value": "${data.azurerm_eventhub_namespace.azure-activity-logs-eventhubs.id}/authorizationrules/RootManageSharedAccessKey"
      }
    }
    PARAMETERS
}

#DeployIfNotExists policies required managed identity with the following RBAC roles, in the code below we are assigning the required roles for the policy to take effect

resource "azurerm_role_assignment" "managed-identity-role-assignment_monitoring_cont_diag_sub-to_event_hub" {
  scope                = data.azurerm_management_group.mg-playtika-lz.id
  principal_id         = azurerm_management_group_policy_assignment.set-diagnostic-setting-on-subscriptions-to-event-hub-assignment.identity[0].principal_id
  role_definition_name = "Azure Event Hubs Data Owner"
}

resource "azurerm_role_assignment" "managed-identity-role-assignment-log_analytics_cont_cont_diag_sub-to_event_hub" {
  scope                = data.azurerm_management_group.mg-playtika-lz.id
  principal_id         = azurerm_management_group_policy_assignment.set-diagnostic-setting-on-subscriptions-to-event-hub-assignment.identity[0].principal_id
  role_definition_name = "Log Analytics Contributor"
}



#Allowed custom images 

resource "azurerm_policy_definition" "approved-vm-images" {
  # Specify the scope to which the policy definition belongs.
  management_group_id = data.azurerm_management_group.mg-playtika-lz.id
  name                = "approved-vm-images"
  mode                = "All"
  description         = "Deny deploy VMs with custom images that not allowed"
  display_name        = "Approved VM custom images"
  policy_type         = "Custom"
  metadata            = file("./policy-defenitions/approved-vm-images/azurepolicy.json")
  policy_rule         = file("./policy-defenitions/approved-vm-images/azurepolicy.rules.json")
  parameters          = file("./policy-defenitions/approved-vm-images/azurepolicy.parameters.json")
}

resource "azurerm_management_group_policy_assignment" "approved-vm-images-assignment" {
  name                 = "approved-vm-images"
  display_name         = "approved-vm-images-assignment"
  description          = "Deny deploy VMs with custom images that not allowed"
  policy_definition_id = azurerm_policy_definition.approved-vm-images.id
  # Specify the scope to which the policy assignment applies.
  management_group_id  = data.azurerm_management_group.mg-playtika-lz.id

  parameters = <<PARAMETERS
    {
      "Effect": {
       "value": "Audit"
     },
      "imageIds": {
        "value": [
        "/subscriptions/d2b9ffa4-5f45-4b08-9429-6d18e4767db7/resourceGroups/rg-compute-mgmt-prod-we-001/providers/Microsoft.Compute/galleries/gal_compute_mgmt_poc_we_001/images/it-templateaz-hrz-compute-mgmt-poc-we-001",
        "/subscriptions/e3dfe043-dd19-4f4a-94f6-f7fbea3b5697/Providers/Microsoft.Compute/Locations/westeurope/Publishers/paloaltonetworks/ArtifactTypes/VMImage/Offers/vmseries-flex/Skus/byol/Versions/11.2.0"
        ]
      }
    }
    PARAMETERS
}
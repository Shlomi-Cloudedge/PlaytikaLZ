Azure Policies Deployment with Terraform
========================================

This project deploys multiple Azure policies using Terraform. These policies are defined in JSON files and are applied to your Azure subscription to enforce various rules and configurations. The main objective is to ensure compliance and enhance the security and management of your Azure resources.

For more information about Terraform azure policy definition :[click here](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_definition)  
For more information about Terraform azure policy for subscription assignment: [click here](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_policy_assignment)  
For more information about Terraform azure policy for management group assignment: [click here](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group_policy_assignment)  

Table of Contents
-----------------

1. [Prerequisites](#prerequisites)
2. [Project Structure](#project-structure)
3. [Getting Started](#getting-started)
4. [Adding New Policies](#adding-new-policies)
5. [Policy Definitions and Assignments](#policy-definitions-and-assignments)

## Prerequisites

-------------

*   Terraform installed on your local machine.
    
*   An Azure subscription with sufficient permissions to create and assign policies.
    
*   Azure CLI installed and authenticated.
    

## Project Structure
-----------------

```css
.
├── main.tf
├── policy-definitions/
│   ├── allow-peering-only-to-hubs/
│   │   ├── azurepolicy.json
│   │   ├── azurepolicy.parameters.json
│   │   └── azurepolicy.rules.json
│   ├── deny-resources-without-tags/
│   │   ├── azurepolicy.parameters.json
│   │   └── azurepolicy.rules.json
│   ├── deny-public-blobs/
│   │   ├── azurepolicy.json
│   │   ├── azurepolicy.parameters.json
│   │   └── azurepolicy.rules.json
│   └── ... (other policy folders)
└── README.md

```

## Getting Started
---------------

1.   ```git clone```
    
2.  ```terraform init```
    
3.  ```terraform plan```
    
4.  ```terraform apply```

### Note for Deployment in Different Scopes
If you want to deploy policies to a another management group , follow these steps:
1. Add a Data resource to the management group in your data.tf file. For example:
   ```hcl
        data "azurerm_management_group" "mg-playtika-lz" {
       name = "mg-playtika-lz"
        }
   ```
2. Modify Resource Types:
For example:
   ```hcl
       resource "azurerm_management_group_policy_assignment" "example-policy-assignment" {
          name                 = "example-policy-assignment"
          management_group_id  = data.azurerm_management_group.mg-playground-playtika-lz.id
          policy_definition_id = azurerm_policy_definition.example-policy.id
        
          parameters = <<PARAMETERS
          {
            "exampleParameter": {
              "value": "exampleValue"
            },
            "effect": {
              "value": "Deny"
            }
          }
          PARAMETERS
        }
   ```
3. Ensure that you replace "your-management-group-id" with the appropriate management group ID.

To exclude subscription or nested management group from the policy use `not_scopes` 

## Adding New Policies
-------------------

To add a new policy, follow these steps:

1.  **Create Policy Definition JSON Files**:
    
    *   Navigate to **policy-definitions** directory.
        
    *   Create a new folder for the policy.
        
    *   Add the required JSON files (**azurepolicy.json**, **azurepolicy.parameters.json**, and **azurepolicy.rules.json**).
        
2.  **Update main.tf**:
    
    *   Define a new **azurerm\_policy\_definition** resource.
        
    *   Define a new **azurerm\_subscription\_policy\_assignment** resource.
        

### Example

If you want to add a new policy named **example-policy**:

1.  **Create policy JSON files** in **policy-definitions/example-policy/**.
    
2.  ```hcl
    resource "azurerm_policy_definition" "example-policy" {
      name         = "example-policy"
      policy_type  = "Custom"
      mode         = "All"
      display_name = "Example Policy"
    
      metadata     = file("./policy-definitions/example-policy/azurepolicy.json")
      parameters   = file("./policy-definitions/example-policy/azurepolicy.parameters.json")
      policy_rule  = file("./policy-definitions/example-policy/azurepolicy.rules.json")
    }
    
    resource "azurerm_subscription_policy_assignment" "example-policy-assignment" {
      name                 = "example-policy-assignment"
      subscription_id      = data.azurerm_subscription.current.id
      policy_definition_id = azurerm_policy_definition.example-policy.id
    
      parameters = <<PARAMETERS
      {
        "exampleParameter": {
          "value": "exampleValue"
        },
        "effect": {
          "value": "Deny"
        }
      }
      PARAMETERS
    }
    ```
    

## Policy Definitions and Assignments
----------------------------------

The **main.tf** file contains various Azure policy definitions and assignments:

### Hub and Spoke Policy

Enforces that virtual network peering is only allowed to hub networks.

### Allowed Location Policy

Restricts resource creation to specified locations.

### Allowed Resource Types Policy

Restricts the types of resources that can be created.

### Require Tags on Resources

Ensures resources are tagged appropriately.

### Audit VMs Without Managed Disks

Audits virtual machines that are not using managed disks.

### Audit Unattached Managed Disks

Audits managed disks that are not attached to any virtual machines.

### Enforce Diagnostic Setting on Subscriptions

Ensures diagnostic settings are applied to subscriptions.

### Network Interfaces Should Not Have Public IPs

Denies network interfaces with public IPs.

### Deny NSG Allowing RDP and SSH from Any Source

Denies network security groups that allow RDP and SSH from any source.

### Secure Transfer to Storage Accounts

Enforces secure transfer to storage accounts.

### Storage Accounts Should Not Allow Public Blobs

Denies public access to blobs in storage accounts, unless tagged otherwise.

### Automation Account Variables Should Be Encrypted

Requires encryption of variables in automation accounts.

### Key Vault Certificates Expiration Audit

Audits key vault certificates that are set to expire within a specified number of days.

This setup ensures that your Azure environment adheres to the defined policies, providing a robust and secure configuration management framework.

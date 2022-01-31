# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }
  required_version = ">= 0.14.9"


  backend "remote" {
    organization = "jcetina"

    workspaces {
      name = "gh_jcetina_policy_testing"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  storage_accounts = {
    audit_log_storage = {
      name                     = "jcetinapoltestast"
      account_tier             = "Standard"
      access_tier              = "Cool"
      account_replication_type = "LRS"
    }
    func_app_storage = {
      name                     = "jcetinapoltestbst"
      account_tier             = "Standard"
      access_tier              = "Cool"
      account_replication_type = "LRS"
    }
  }
}

data "azurerm_resource_group" "rg" {
  name = "rg-gh-jcetina-policy-testing"
}

data "azurerm_client_config" "current" {}

resource "azurerm_storage_account" "storage_accounts" {
  for_each = local.storage_accounts

  name                      = each.value.name
  resource_group_name       = data.azurerm_resource_group.rg.name
  location                  = data.azurerm_resource_group.rg.location
  account_tier              = each.value.account_tier
  access_tier               = each.value.access_tier
  account_replication_type  = each.value.account_replication_type
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
}

resource "azurerm_policy_definition" "activitylogstostorage" {
  name         = "activity-logs-to-storage"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Activity Logs -> Storage"
  depends_on = [
    azurerm_storage_account.storage_accounts
  ]

  policy_rule = <<POLICY_RULE
{
  "if": {
    "field": "type",
    "equals": "Microsoft.Resources/subscriptions"
  },
  "then": {
    "effect": "[parameters('effect')]",
    "details": {
      "type": "microsoft.insights/diagnosticSettings",
      "existenceCondition": {
        "allOf": [
          {
            "anyOf": [
              {
              "field": "Microsoft.Insights/diagnosticSettings.storageAccountId",
              "equals": "[parameters('storageAccountId')]"
              }
            ],
            "anyOf": [
              {
              "field": "Microsoft.Insights/diagnosticSettings.storageAccountId",
              "equals": "[parameters('storageAccountId2')]"
              }
            ]
          }
        ]
      },
      "roleDefinitionIds": [
        "/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa",
        "/providers/Microsoft.Authorization/roleDefinitions/17d1049b-9a84-46fb-8f53-869881c3d3ab"
      ],
      "deployment": {
        "properties": {
          "mode": "incremental",
          "template": {
            "$schema": "https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#",
            "contentVersion": "1.0.0.0",
            "parameters": {
              "profileName": {
                "type": "string"
              },
              "storageAccountId": {
                "type": "string"
              },
              "storageAccountId2": {
                "type": "string"
              }
            },
            "variables": {},
            "resources": [
              {
                "type": "microsoft.insights/diagnosticSettings",
                "apiVersion": "2017-05-01-preview",
                "name": "[parameters('profileName')]",
                "properties": {
                  "storageAccountId": "[parameters('storageAccountId')]",
                  "logs": [
                    {
                      "category": "Administrative",
                      "enabled": true
                    },
                    {
                      "category": "Security",
                      "enabled": true
                    },
                    {
                      "category": "ServiceHealth",
                      "enabled": true
                    },
                    {
                      "category": "Alert",
                      "enabled": true
                    },
                    {
                      "category": "Recommendation",
                      "enabled": true
                    },
                    {
                      "category": "Policy",
                      "enabled": true
                    },
                    {
                      "category": "Autoscale",
                      "enabled": true
                    },
                    {
                      "category": "ResourceHealth",
                      "enabled": true
                    }
                  ]
                }
              },
              {
                "type": "microsoft.insights/diagnosticSettings",
                "apiVersion": "2017-05-01-preview",
                "name": "[concat(parameters('profileName'), '2')]",
                "properties": {
                  "storageAccountId": "[parameters('storageAccountId2')]",
                  "logs": [
                    {
                      "category": "Administrative",
                      "enabled": true
                    },
                    {
                      "category": "Security",
                      "enabled": true
                    },
                    {
                      "category": "ServiceHealth",
                      "enabled": true
                    },
                    {
                      "category": "Alert",
                      "enabled": true
                    },
                    {
                      "category": "Recommendation",
                      "enabled": true
                    },
                    {
                      "category": "Policy",
                      "enabled": true
                    },
                    {
                      "category": "Autoscale",
                      "enabled": true
                    },
                    {
                      "category": "ResourceHealth",
                      "enabled": true
                    }
                  ]
                }
              }
            ],
            "outputs": {}
          },
          "parameters": {
            "storageAccountId": {
              "value": "[parameters('storageAccountId')]"
            },
            "storageAccountId2": {
              "value": "[parameters('storageAccountId2')]"
            },
            "profileName": {
              "value": "[parameters('profileName')]"
            }
          }
        },
        "location": "eastus"
      },
      "deploymentScope": "subscription"
    }
  }
}
POLICY_RULE

  parameters = <<PARAMETERS
{
  "effect": {
    "type": "String",
    "metadata": {
      "displayName": "Effect",
      "description": "Enable or disable the execution of the policy"
    },
    "allowedValues": [
      "DeployIfNotExists",
      "AuditIfNotExists",
      "Disabled"
    ],
    "defaultValue": "DeployIfNotExists"
  },
  "profileName": {
    "type": "String",
    "metadata": {
      "displayName": "Profile name",
      "description": "The diagnostic settings profile name"
    },
    "defaultValue": "setbypolicy_Diagnostics2Storage"
  },
  "storageAccountId": {
    "type": "String",
    "metadata": {
      "displayName": "Storage Account resource ID",
      "description": "Select Storage account from dropdown list. If this account is outside of the scope of the assignment you must manually grant 'Contributor' permissions (or similar) to the policy assignment's principal ID.",
      "strongType": "Microsoft.Storage/storageAccounts"
    }
  },
  "storageAccountId2": {
    "type": "String",
    "metadata": {
      "displayName": "Storage Account resource ID",
      "description": "Select Storage account from dropdown list. If this account is outside of the scope of the assignment you must manually grant 'Contributor' permissions (or similar) to the policy assignment's principal ID.",
      "strongType": "Microsoft.Storage/storageAccounts"
    }
  }
}
PARAMETERS
}


resource "azurerm_policy_assignment" "activitylogstostorage" {
  name                 = "activity-logs-to-storage"
  location             = data.azurerm_resource_group.rg.location
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  policy_definition_id = azurerm_policy_definition.activitylogstostorage.id
  description          = "Policy Assignment for Activity Logs -> Storage Account"
  display_name         = "Activity Logs -> Storage across tenant"

  identity {
    type = "SystemAssigned"
  }


  parameters = <<PARAMETERS
  {
    "effect": {
      "value": "DeployIfNotExists"
    },
    "profileName": {
      "value": "setbypolicy_Diagnostics2Storage"
    },
    "storageAccountId": {
      "value": "/subscriptions/ad3b85d9-1354-4383-a30c-6383716082e4/resourceGroups/rg-gh-jcetina-policy-testing/providers/Microsoft.Storage/storageAccounts/jcetinapoltestast"
    },
    "storageAccountId2": {
      "value": "/subscriptions/ad3b85d9-1354-4383-a30c-6383716082e4/resourceGroups/rg-gh-jcetina-policy-testing/providers/Microsoft.Storage/storageAccounts/jcetinapoltestbst"
    }
  }
PARAMETERS
}



resource "azurerm_role_assignment" "SecurityTelemetryRemediationStorageContributor" {
  principal_id         = azurerm_policy_assignment.activitylogstostorage.identity.0.principal_id
  role_definition_name = "Storage Account Contributor"
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  description          = "terraform-managed: security_telemetry_remediation role Storage Account Contributor"
}

resource "azurerm_role_assignment" "SecurityTelemetryRemediationMonitorContributor" {
  principal_id         = azurerm_policy_assignment.activitylogstostorage.identity.0.principal_id
  role_definition_name = "Monitoring Contributor"
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  description          = "terraform-managed: security_telemetry_remediation role Monitoring Contributor"
}

/*
resource "azurerm_policy_remediation" "remediateactivitylogs" {
  name                    = "remediate-activity-logs"
  scope                   = azurerm_policy_assignment.activitylogstostorage.scope
  policy_assignment_id    = azurerm_policy_assignment.activitylogstostorage.id
  resource_discovery_mode = "ExistingNonCompliant"
}
*/
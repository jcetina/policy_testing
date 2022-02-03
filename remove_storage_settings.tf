resource "azurerm_policy_definition" "modify-activity-log-settings" {
  name         = "modify-activity-logs"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Modify Activity Log Settings"

  policy_rule = <<POLICY_RULE
{
  "if": {
    "allOf": [
      {
        "field": "type",
        "equals": "Microsoft.Resources/subscriptions"
      },
      {
        "value": "Microsoft.Insights/diagnosticSettings.name",
        "equals": "[parameters('profileName')]"
      }
    ]
  },
  "then": {
    "effect": "[parameters('effect')]",
    "details": {
      "roleDefinitionIds": [
        "/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa"
      ],
      "operations": [
        {
          "operation": "remove",
          "field": "[concat('Microsoft.Insights/diagnosticSettings/', parameters('profileName'))]"
        }
      ]
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
      "Modify"
    ],
    "defaultValue": "Modify"
  },
  "profileName": {
    "type": "String",
    "metadata": {
      "displayName": "Profile name",
      "description": "The diagnostic settings profile name"
    },
    "defaultValue": "setbypolicy_Diagnostics2Storage"
  }
}
PARAMETERS
}

resource "azurerm_policy_assignment" "modify-activity-log-settings" {
  name                 = "modify-activity-logs"
  location             = data.azurerm_resource_group.rg.location
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  policy_definition_id = azurerm_policy_definition.modify-activity-log-settings.id
  description          = "modify-activity-log-settings"
  display_name         = "modify-activity-log-settings"

  identity {
    type = "SystemAssigned"
  }


  parameters = <<PARAMETERS
  {
    "effect": {
      "value": "Modify"
    },
    "profileName": {
      "value": "setbypolicy_Diagnostics2Storage"
    }
  }
PARAMETERS
}

resource "azurerm_role_assignment" "modify-activity-log-settings-role-assignment" {
  principal_id         = azurerm_policy_assignment.modify-activity-log-settings.identity.0.principal_id
  role_definition_name = "Monitoring Contributor"
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  description          = "modify-activity-log-settings"
}
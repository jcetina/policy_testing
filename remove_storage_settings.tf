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
        "/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa",
        "/providers/Microsoft.Authorization/roleDefinitions/17d1049b-9a84-46fb-8f53-869881c3d3ab"
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
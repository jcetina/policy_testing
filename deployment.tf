

resource "azurerm_policy_definition" "fix_activity_logs" {
  name         = "fix-activity-logs"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Fix Activity Logs -> Storage"

  policy_rule = <<POLICY_RULE
{
  "if": {
    "allOf": [
        {
            "field": "type",
            "equals": "Microsoft.Resources/deployments"
        }
    ]
  },
  "then": {
    "effect": "[parameters('effect')]"
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
      "Audit",
      "Disabled"
    ],
    "defaultValue": "Audit"
  }
}
PARAMETERS
}

/*
resource "azurerm_policy_assignment" "fixactivitylogstostorage" {
  name                 = "fix-activity-logs-to-storage"
  location             = data.azurerm_resource_group.rg.location
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  policy_definition_id = azurerm_policy_definition.fix_activity_logs.id
  description          = "Policy Assignment for Fixing Activity Logs -> Storage Account"
  display_name         = "Fix Activity Logs -> Storage across tenant"

  identity {
    type = "SystemAssigned"
  }


  parameters = <<PARAMETERS
  {
    "effect": {
      "value": "Audit"
    }
  }
PARAMETERS
}
*/


# resource "azurerm_role_assignment" "SecurityTelemetryRemediationStorageContributor" {
#   principal_id         = azurerm_policy_assignment.activitylogstostorage.identity.0.principal_id
#   role_definition_name = "Storage Account Contributor"
#   scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
#   description          = "terraform-managed: security_telemetry_remediation role Storage Account Contributor"
# }

# resource "azurerm_role_assignment" "SecurityTelemetryRemediationMonitorContributor" {
#   principal_id         = azurerm_policy_assignment.activitylogstostorage.identity.0.principal_id
#   role_definition_name = "Monitoring Contributor"
#   scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
#   description          = "terraform-managed: security_telemetry_remediation role Monitoring Contributor"
# }


# resource "azurerm_policy_remediation" "remediatefixactivitylogs" {
#   name                    = "remediate-activity-logs"
#   scope                   = azurerm_policy_assignment.activitylogstostorage.scope
#   policy_assignment_id    = azurerm_policy_assignment.activitylogstostorage.id
#   resource_discovery_mode = "ExistingNonCompliant"
# }


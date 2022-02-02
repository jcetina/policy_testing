resource "azurerm_eventhub_namespace" "evhns" {
  name                = "evhns-jcetina-policy-test"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "Basic"

}

resource "azurerm_eventhub" "eventhub" {
  name                = "evh-${policy-test}"
  namespace_name      = azurerm_eventhub_namespace.evhns.name
  resource_group_name = data.azurerm_resource_group.rg.name
}
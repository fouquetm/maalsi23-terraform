resource "azurerm_service_plan" "plan" {
  name                = var.asp_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.sku_name

  tags = var.tags
}

resource "azurerm_linux_web_app" "webapp" {
  name                = var.webapp_name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.plan.id

  tags = var.tags

  site_config {
  }

  app_settings = var.app_settings

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_key_vault_access_policy" "webapp" {
  key_vault_id = var.keyvault_id
  tenant_id    = azurerm_linux_web_app.webapp.identity[0].tenant_id
  object_id    = azurerm_linux_web_app.webapp.identity[0].principal_id

  secret_permissions = [
    "Get"
  ]
}
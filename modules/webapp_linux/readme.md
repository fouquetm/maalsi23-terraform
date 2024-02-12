module "webapp" {
  count = 3
  source = "./modules/webapp_linux"
  resource_group_name = azurerm_resource_group.app01.name
  location = azurerm_resource_group.app01.location
  webapp_name = "app-${var.project_name}-${var.environnement}-${count.index}"
  asp_name = "asp-${var.project_name}-${var.environnement}-${count.index}"
  sku_name = "P1v2"
  keyvault_id = azurerm_key_vault.kv01.id
  app_settings = {
      ApplicationInsights__InstrumentationKey = azurerm_application_insights.insights01.instrumentation_key
      DbConnectionString = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv01.name};SecretName=DbConnectionString)"
    }
  tags = local.tags  
}
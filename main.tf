resource "azurerm_resource_group" "app01" {
  name     = "rg-${var.project_name}-${var.environnement}-01"
  location = "West Europe"

  tags = local.tags
}

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

resource "azurerm_log_analytics_workspace" "loganalystics01" {
  name                = "logs-${var.project_name}-${var.environnement}-01"
  location            = azurerm_resource_group.app01.location
  resource_group_name = azurerm_resource_group.app01.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = local.tags
}

resource "azurerm_application_insights" "insights01" {
  name                = "insights-${var.project_name}-${var.environnement}-01"
  location            = azurerm_log_analytics_workspace.loganalystics01.location
  resource_group_name = azurerm_log_analytics_workspace.loganalystics01.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.loganalystics01.id
  application_type    = "web"

  tags = local.tags
}

resource "azurerm_key_vault" "kv01" {
  name                        = "kv-${var.project_name}-${var.environnement}-01"
  location                    = azurerm_resource_group.app01.location
  resource_group_name         = azurerm_resource_group.app01.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name = "standard"

  tags = local.tags
}

resource "random_password" "sql_login" {
  length           = 16
  special          = false
}

resource "azurerm_key_vault_secret" "sql_login" {
  name         = "sql-login"
  value        = random_password.sql_login.result
  key_vault_id = azurerm_key_vault.kv01.id
}

resource "random_password" "sql_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_key_vault_secret" "sql_password" {
  name         = "sql-password"
  value        = random_password.sql_password.result
  key_vault_id = azurerm_key_vault.kv01.id
}

resource "azurerm_mssql_server" "sql01" {
  name                         = "sqlsrev-${var.project_name}-${var.environnement}-01"
  resource_group_name          = azurerm_resource_group.app01.name
  location                     = azurerm_resource_group.app01.location
  version                      = "12.0"
  administrator_login          = azurerm_key_vault_secret.sql_login.value
  administrator_login_password = azurerm_key_vault_secret.sql_password.value

  tags = local.tags
}

resource "azurerm_mssql_database" "db01" {
  name           = "db-${var.project_name}-${var.environnement}-01"
  server_id      = azurerm_mssql_server.sql01.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  sku_name       = "S0"
  enclave_type   = "VBS"

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = false
  }

  tags = local.tags
}

resource "azurerm_key_vault_secret" "app_db_connectionstring" {
  name         = "DbConnectionString"
  value        = "Server=tcp:${azurerm_mssql_server.sql01.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.db01.name};Persist Security Info=False;User ID=${azurerm_mssql_server.sql01.administrator_login};Password=${azurerm_mssql_server.sql01.administrator_login_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  key_vault_id = azurerm_key_vault.kv01.id
}
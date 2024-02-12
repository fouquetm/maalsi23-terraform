variable "project_name" {
  type = string
  description = "Détermine le nom du projet qui sera utilisé pour générer le nom des ressources."
  default = "mfolabs"
}

resource "azurerm_resource_group" "app01" {
  name     = "rg-${var.project_name}-01"
  location = "West Europe"
}

resource "azurerm_service_plan" "plan01" {
  name                = "asp-${var.project_name}-01"
  resource_group_name = azurerm_resource_group.app01.name
  location            = azurerm_resource_group.app01.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}

resource "azurerm_linux_web_app" "webapp01" {
  name                = "app-${var.project_name}-01"
  resource_group_name = azurerm_resource_group.app01.name
  location            = azurerm_service_plan.plan01.location
  service_plan_id     = azurerm_service_plan.plan01.id

  site_config {
  }

  app_settings = {
    ApplicationInsights__InstrumentationKey = azurerm_application_insights.insights01.instrumentation_key
  }
}

resource "azurerm_log_analytics_workspace" "loganalystics01" {
  name                = "logs-${var.project_name}-01"
  location            = azurerm_resource_group.app01.location
  resource_group_name = azurerm_resource_group.app01.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "insights01" {
  name                = "insights-${var.project_name}-01"
  location            = azurerm_log_analytics_workspace.loganalystics01.location
  resource_group_name = azurerm_log_analytics_workspace.loganalystics01.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.loganalystics01.id
  application_type    = "web"
}
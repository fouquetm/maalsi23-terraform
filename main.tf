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

  site_config {}
}
output "webapp_principal_id" {
  value = azurerm_linux_web_app.webapp.identity[0].principal_id
}

output "webapp_tenant_id" {
  value = azurerm_linux_web_app.webapp.identity[0].tenant_id
}

output "webapp_id" {
  value = azurerm_linux_web_app.webapp.id
}

output "asp_id" {
  value = azurerm_service_plan.plan.id
}
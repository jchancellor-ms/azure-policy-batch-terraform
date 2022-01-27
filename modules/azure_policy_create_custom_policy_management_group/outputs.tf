output "policy_definition_id" {
  value = azurerm_policy_definition.this.id
}

output "policy_definition_display_name" {
  value = var.policy_definition_display_name
}
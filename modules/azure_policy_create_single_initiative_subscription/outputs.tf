output "id" {
  value = azurerm_policy_set_definition.this.id
  #value = local.policies
}

output "display_name" {
  value = azurerm_policy_set_definition.this.display_name
}

output "policies" {
  value = local.policies
}


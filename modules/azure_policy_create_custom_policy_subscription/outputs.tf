output "policy_definition_id" {
  value = azurerm_policy_definition.this.id
}

output "policy_definition_display_name" {
  value = var.policy_definition_display_name
}

output "github_repo" {
  value = data.github_repository_file.this_policy_rule.content
  #value = file("git::https://github.com/jchancellor-ms/azure-policy/storage/require_enabled_empty_storage_firewall/require_enabled_empty_storage_firewall.policy_parameters.json")
}
output "policy_definition_id" {
  value = azurerm_policy_definition.this.id
}


output "github_repo" {
  value = data.github_repository_file.this_policy_rule.content
  #value = file("git::https://github.com/jchancellor-ms/azure-policy/storage/require_enabled_empty_storage_firewall/require_enabled_empty_storage_firewall.policy_parameters.json")
}
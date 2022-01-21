output "policy_id_map" {
  description = "List of policy names mapped to policy ids"
  #value = data.azurerm_policy_definition.builtin_policy.id
  #value = values(data.azurerm_policy_definition.builtin_policy)[*]
  value = zipmap(values(data.azurerm_policy_definition.policies)[*].display_name, values(data.azurerm_policy_definition.policies)[*].id)

}


output "custom_policies" {
  value = local.policies
  #value = var.policy_definitions
}

output "custom_policy_ids_subscription" {
  #map of policy display name to id for subscriptions
  value = zipmap(values(module.custom_policy_creation_subscription)[*].policy_definition_display_name, values(module.custom_policy_creation_subscription)[*].policy_definition_id)
}

output "custom_policy_ids_management_group" {
  #map of policy display name to id for management groups
  value = zipmap(values(module.custom_policy_creation_management_group)[*].policy_definition_display_name, values(module.custom_policy_creation_management_group)[*].policy_definition_id)
}

output "custom_policy_ids_all" {
  #map of policy display name to id for all
  value = merge(zipmap(values(module.custom_policy_creation_subscription)[*].policy_definition_display_name, values(module.custom_policy_creation_subscription)[*].policy_definition_id), zipmap(values(module.custom_policy_creation_management_group)[*].policy_definition_display_name, values(module.custom_policy_creation_management_group)[*].policy_definition_id))
}
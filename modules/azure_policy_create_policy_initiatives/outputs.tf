output "policy_initiative_ids_subscription" {
  value = values(module.create_policy_initiative_subscription)[*].id
}

output "policy_initiative_name_id_map_subscription" {
  value = zipmap(values(module.create_policy_initiative_subscription)[*].display_name, values(module.create_policy_initiative_subscription)[*].id)
}

output "policy_initiative_ids_management_group" {
  value = values(module.create_policy_initiative_management_group)[*].id
}

output "policy_initiative_name_id_map_management_group" {
  value = zipmap(values(module.create_policy_initiative_management_group)[*].display_name, values(module.create_policy_initiative_management_group)[*].id)
}

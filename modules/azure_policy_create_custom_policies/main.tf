locals {
  policies                  = { for policy in var.policy_definitions : (length("${policy.name}-${local.short_scope}") < 64 ? "${policy.name}-${local.short_scope}" : substr("${policy.name}-${local.short_scope}", 0, 63)) => policy if policy.type == "Custom" }
  null_policies             = {}
  management_group_policies = (var.scope == "management_group" ? local.policies : local.null_policies)
  subscription_policies     = (var.scope == "subscription" ? local.policies : local.null_policies)
  short_scope               = element(split("/", var.scope_target), length(split("/", var.scope_target)) - 1)
}



module "custom_policy_creation_subscription" {
  source = "../azure_policy_create_custom_policy_subscription"

  for_each = local.subscription_policies

  policy_definition_name         = length("${each.value.name}-${local.short_scope}") < 64 ? "${each.value.name}-${local.short_scope}" : substr("${each.value.name}-${local.short_scope}", 0, 63)
  policy_definition_display_name = each.value.display_name
  policy_mode                    = each.value.mode
  policy_description             = each.value.description
  custom_policy_github_repo      = each.value.github_repo
  github_repo_branch             = each.value.github_repo_branch
  policy_rule_filename           = each.value.policy_rule_filename
  policy_parameters_filename     = each.value.policy_parameters_filename
  policy_metadata_filename       = each.value.policy_metadata_filename
}

module "custom_policy_creation_management_group" {
  source = "../azure_policy_create_custom_policy_management_group"

  for_each = local.management_group_policies

  policy_definition_name         = length("${each.value.name}-${local.short_scope}") < 64 ? "${each.value.name}-${local.short_scope}" : substr("${each.value.name}-${local.short_scope}", 0, 63)
  policy_definition_display_name = each.value.display_name
  policy_mode                    = each.value.mode
  policy_description             = each.value.description
  custom_policy_github_repo      = each.value.github_repo
  github_repo_branch             = each.value.github_repo_branch
  policy_rule_filename           = each.value.policy_rule_filename
  policy_parameters_filename     = each.value.policy_parameters_filename
  policy_metadata_filename       = each.value.policy_metadata_filename
  scope                          = var.scope
  scope_target                   = local.short_scope
}


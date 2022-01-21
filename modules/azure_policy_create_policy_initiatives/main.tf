#create each policy initiative configured in the definition file

locals {
  subscription_initiatives     = { for initiative in var.initiative_details : (length("${initiative.name}-${(element(split("/", initiative.scope_target), length(split("/", initiative.scope_target)) - 1))}") < 64 ? "${initiative.name}-${(element(split("/", initiative.scope_target), length(split("/", initiative.scope_target)) - 1))}" : substr("${initiative.name}-${(element(split("/", initiative.scope_target), length(split("/", initiative.scope_target)) - 1))}", 0, 63)) => initiative if initiative.scope == "subscription" }
  management_group_initiatives = { for initiative in var.initiative_details : (length("${initiative.name}-${(element(split("/", initiative.scope_target), length(split("/", initiative.scope_target)) - 1))}") < 64 ? "${initiative.name}-${(element(split("/", initiative.scope_target), length(split("/", initiative.scope_target)) - 1))}" : substr("${initiative.name}-${(element(split("/", initiative.scope_target), length(split("/", initiative.scope_target)) - 1))}", 0, 63)) => initiative if initiative.scope == "management_group" }
  #length("${initiative.name}-${(element(split("/", initiative.scope_target), length(split("/", initiative.scope_target)) - 1))}") < 64 ? "${initiative.name}-${(element(split("/", initiative.scope_target), length(split("/", initiative.scope_target)) - 1))}" : substr("${initiative.name}-${(element(split("/", initiative.scope_target), length(split("/", initiative.scope_target)) - 1))}", 0, 63)
}

#if the initiative has a management group scope call the management group initiative creation
#if the initiative has a subscription scope call the subscription initiative creation


module "create_policy_initiative_management_group" {
  source = "../azure_policy_create_single_initiative_management_group"

  for_each = local.management_group_initiatives

  initiative_definition = each.value
}

module "create_policy_initiative_subscription" {
  source = "../azure_policy_create_single_initiative_subscription"

  for_each = local.subscription_initiatives

  initiative_definition = each.value
}
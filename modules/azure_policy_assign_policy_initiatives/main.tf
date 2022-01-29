
#create subscription and management group values

locals {
  subscription_initiatives     = { for initiative in var.initiatives_details : (length("${initiative.name}-${(element(split("/", initiative.scope_target), length(split("/", initiative.scope_target)) - 1))}") < 64 ? "${initiative.name}-${(element(split("/", initiative.scope_target), length(split("/", initiative.scope_target)) - 1))}" : substr("${initiative.name}-${(element(split("/", initiative.scope_target), length(split("/", initiative.scope_target)) - 1))}", 0, 63)) => initiative if initiative.scope == "subscription" }
  management_group_initiatives = { for initiative in var.initiatives_details : (length("${initiative.name}-${(element(split("/", initiative.scope_target), length(split("/", initiative.scope_target)) - 1))}") < 64 ? "${initiative.name}-${(element(split("/", initiative.scope_target), length(split("/", initiative.scope_target)) - 1))}" : substr("${initiative.name}-${(element(split("/", initiative.scope_target), length(split("/", initiative.scope_target)) - 1))}", 0, 63)) => initiative if initiative.scope == "management_group" }
}


resource "azurerm_subscription_policy_assignment" "subscriptions" {
  for_each             = local.subscription_initiatives
  name                 = each.value.name
  policy_definition_id = lookup(var.initiative_name_id_map_subscription, "${each.value.display_name}-${(element(split("/", each.value.scope_target), length(split("/", each.value.scope_target)) - 1))}")
  subscription_id      = each.value.scope_target
  display_name         = each.value.display_name
  location             = each.value.location

  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_management_group_policy_assignment" "management_groups" {
  for_each             = local.management_group_initiatives
  name                 = each.value.name
  policy_definition_id = lookup(var.initiative_name_id_map_management_group, "${each.value.display_name}-${(element(split("/", each.value.scope_target), length(split("/", each.value.scope_target)) - 1))}")
  management_group_id  = each.value.scope_target
  display_name         = each.value.display_name
  location             = each.value.location

  identity {
    type = "SystemAssigned"
  }
}

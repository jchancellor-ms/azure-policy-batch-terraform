locals {
  policies         = var.initiative_definition.policies
  policy_name_list = [for policy in local.policies : policy.type == "Builtin" ? policy.display_name : "${policy.display_name}-${random_integer.display_name_uniqueness.result}"]
  subscription_id  = element(split("/", var.initiative_definition.scope_target), length(split("/", var.initiative_definition.scope_target)) - 1)
}


resource "random_integer" "display_name_uniqueness" {
  min  = 1
  max  = 100000
  seed = local.subscription_id
}

module "custom_policy_creation" {
  source             = "../azure_policy_create_custom_policies"
  policy_definitions = local.policies
  scope              = var.initiative_definition.scope
  scope_target       = var.initiative_definition.scope_target
}


#Get the policy IDs to use for creating the policy initiative
module "get_policy_ids" {
  source           = "../azure_policy_output_policy_id"
  policy_name_list = local.policy_name_list
  depends_on = [
    module.custom_policy_creation
  ]
}

resource "azurerm_policy_set_definition" "this" {
  name         = var.initiative_definition.name
  policy_type  = var.initiative_definition.type
  display_name = var.initiative_definition.display_name
  description  = var.initiative_definition.description

  dynamic "policy_definition_reference" {
    #for_each = var.policy_definitions
    for_each = local.policies
    content {
      parameter_values     = jsonencode(policy_definition_reference.value.parameters)
      policy_definition_id = lookup(module.get_policy_ids.policy_id_map, policy_definition_reference.value.type == "Builtin" ? policy_definition_reference.value.display_name : "${policy_definition_reference.value.display_name}-${random_integer.display_name_uniqueness.result}")

    }
  }
}


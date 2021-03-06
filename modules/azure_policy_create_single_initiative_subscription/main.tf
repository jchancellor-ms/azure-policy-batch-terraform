locals {
  policies        = var.initiative_definition.policies
  policy_object   = { for policy in local.policies : policy.display_name => tostring(policy.display_name) if policy.type == "Builtin" }
  subscription_id = element(split("/", var.initiative_definition.scope_target), length(split("/", var.initiative_definition.scope_target)) - 1)
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
  source             = "../azure_policy_output_policy_id"
  policy_name_object = local.policy_object
}

resource "azurerm_policy_set_definition" "this" {
  name         = var.initiative_definition.name
  policy_type  = var.initiative_definition.type
  display_name = "${var.initiative_definition.display_name}-${local.subscription_id}"
  description  = var.initiative_definition.description

  dynamic "policy_definition_reference" {
    for_each = local.policies
    content {
      parameter_values     = jsonencode(policy_definition_reference.value.parameters)
      policy_definition_id = lookup((merge(module.custom_policy_creation.custom_policy_ids_all, module.get_policy_ids.policy_id_map)), policy_definition_reference.value.type == "Builtin" ? policy_definition_reference.value.display_name : "${policy_definition_reference.value.display_name}-${random_integer.display_name_uniqueness.result}")
      reference_id         = lookup((merge(module.custom_policy_creation.custom_policy_ids_all, module.get_policy_ids.policy_id_map)), policy_definition_reference.value.type == "Builtin" ? policy_definition_reference.value.display_name : "${policy_definition_reference.value.display_name}-${random_integer.display_name_uniqueness.result}")
    }
  }
}


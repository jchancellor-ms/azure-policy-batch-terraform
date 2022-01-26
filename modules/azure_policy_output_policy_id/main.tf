
resource "random_integer" "display_name_uniqueness" {
  min  = 1
  max  = 100000
  seed = var.seed
}

data "azurerm_policy_definition" "policies" {
  #for_each = {for policy in local.builtinPolicyDefinitions : policy.policyName => policy }
  for_each     = toset(var.policy_name_list)
  display_name = "${each.key}-${random_integer.display_name_uniqueness.result}"
}


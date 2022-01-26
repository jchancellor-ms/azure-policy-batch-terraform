data "azurerm_policy_definition" "policies" {
  for_each     = var.policy_name_object
  display_name = each.value
}


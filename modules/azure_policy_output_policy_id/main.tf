data "azurerm_policy_definition" "policies" {
  for_each     = toset(var.policy_name_list)
  display_name = each.key
}


#create policy initiatives
module "create_all_policy_initiatives" {
  source = "../azure_policy_create_policy_initiatives"

  initiative_details = var.initiative_details.initiatives
}


module "assign_all_policy_initiatives" {
  source = "../azure_policy_assign_policy_initiatives"

  initiatives_details                     = var.initiative_details.initiatives
  initiative_name_id_map_subscription     = module.create_all_policy_initiatives.policy_initiative_name_id_map_subscription
  initiative_name_id_map_management_group = module.create_all_policy_initiatives.policy_initiative_name_id_map_management_group
}



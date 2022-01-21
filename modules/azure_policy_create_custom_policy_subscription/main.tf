#iterate through the policy list
#if type is custom
#create new policy definition 
### get policy rule from github location
### get policy parameters from github location

/*
locals{
  management_group = [for value in toset([var.scope]) : value if value == "management_group"]
  subscription = [for value in toset([var.scope]) : value if value == "subscription"]
}
*/

data "github_repository" "this" {
  full_name = var.custom_policy_github_repo
}



data "github_repository_file" "this_policy_rule" {
  repository = data.github_repository.this.id
  branch     = var.github_repo_branch
  file       = var.policy_rule_filename
}


data "github_repository_file" "this_policy_parameters" {
  repository = data.github_repository.this.id
  branch     = var.github_repo_branch
  file       = var.policy_parameters_filename
}

data "github_repository_file" "this_policy_metadata" {
  repository = data.github_repository.this.id
  branch     = var.github_repo_branch
  file       = var.policy_metadata_filename
}

resource "azurerm_policy_definition" "this" {
  name         = var.policy_definition_name
  policy_type  = "Custom"
  mode         = var.policy_mode
  description  = var.policy_description
  display_name = var.policy_definition_display_name

  metadata    = data.github_repository_file.this_policy_metadata.content
  policy_rule = data.github_repository_file.this_policy_rule.content
  parameters  = data.github_repository_file.this_policy_parameters.content

}

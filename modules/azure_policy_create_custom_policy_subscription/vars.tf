variable "policy_definition_name" {
  description = "Unique name given to the policy that will be used for uniqueness"
}

variable "policy_definition_display_name" {
  description = "Display name of the policy being created"
}

variable "policy_mode" {
  description = "Mode of the policy being implemented.  Typically this value is all or indexed"
}

variable "policy_description" {
  description = "Description of the policy being implemented."
}

variable "custom_policy_github_repo" {
  description = "Github Repo where the custom policy definition files are hosted"
}

variable "github_repo_branch" {
  description = "Branch of the repo where the referenced policy file versions are located"
  default     = "main"
}

variable "policy_rule_filename" {
  description = "Filename of the json file containing the policy rule details"
}

variable "policy_parameters_filename" {
  description = "Filename of the json file containing the policy parameters definition details"
}

variable "policy_metadata_filename" {
  description = "Filename of the json file containing the policy metadata definition details"
}




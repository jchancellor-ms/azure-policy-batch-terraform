#ingests a json file that contains a set of policy initiative definitions 
#creates and assigns the definitions
locals {
  initiative_details = jsondecode(file("./${var.input_filename}"))
}

module "create_initiative" {
  source             = "./modules/azure_policy_create_and_assign_initiatives"
  initiative_details = tomap(local.initiative_details)
}

variable "input_filename" {
}
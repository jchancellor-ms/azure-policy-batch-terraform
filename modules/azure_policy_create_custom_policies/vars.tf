variable "policy_definitions" {
  description = "Object containing all of the definitions to be created"
}

variable "scope" {
  description = "Scope of the policies being created (management_group or subscription)"
}

variable "scope_target" {
  description = "Name of the subscription or management group where policy is being created"
}
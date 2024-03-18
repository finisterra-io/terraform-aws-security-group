variable "enabled" {
  type        = bool
  description = "Set to false to prevent the module from creating any resources."
  default     = true
}

variable "target_security_group_id" {
  type        = list(string)
  description = <<-EOT
    The ID of an existing Security Group to which Security Group rules will be assigned.
    The Security Group's name and description will not be changed.
    Not compatible with `inline_rules_enabled` or `revoke_rules_on_delete`.
    If not provided (the default), this module will create a security group.
    EOT
  default     = []
  validation {
    condition     = length(var.target_security_group_id) < 2
    error_message = "Only 1 security group can be targeted."
  }
}

variable "security_group_name" {
  type        = string
  description = <<-EOT
    The name to assign to the security group. Must be unique within the VPC.
    If not provided, will be derived from the `null-label.context` passed in.
    If `create_before_destroy` is true, will be used as a name prefix.
    EOT
  default     = ""
}


variable "security_group_description" {
  type        = string
  description = <<-EOT
    The description to assign to the created Security Group.
    Warning: Changing the description causes the security group to be replaced.
    EOT
  default     = " "
}

variable "create_before_destroy" {
  type        = bool
  description = <<-EOT
    Set `true` to enable terraform `create_before_destroy` behavior on the created security group.
    We only recommend setting this `false` if you are importing an existing security group
    that you do not want replaced and therefore need full control over its name.
    Note that changing this value will always cause the security group to be replaced.
    EOT
  default     = false
}

variable "revoke_rules_on_delete" {
  type        = bool
  description = <<-EOT
    Instruct Terraform to revoke all of the Security Group's attached ingress and egress rules before deleting
    the security group itself. This is normally not needed.
    EOT
  default     = false
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the Security Group will be created."
  default     = null
}

variable "vpc_name" {
  type        = string
  default     = null
  description = <<-EOT
    The name of the VPC where the Security Group will be created.
    If not provided, will be derived from the `null-label.context` passed in.
    EOT
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources."
  default     = {}
}

variable "ingress_rules" {
  type        = any
  description = "A map of ingress rules to add to the security group."
  default     = {}
}

variable "egress_rules" {
  type        = any
  description = "A map of egress rules to add to the security group."
  default     = {}
}

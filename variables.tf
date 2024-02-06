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
  default     = "Managed by Terraform"
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

variable "preserve_security_group_id" {
  type        = bool
  description = <<-EOT
    When `false` and `create_before_destroy` is `true`, changes to security group rules
    cause a new security group to be created with the new rules, and the existing security group is then
    replaced with the new one, eliminating any service interruption.
    When `true` or when changing the value (from `false` to `true` or from `true` to `false`),
    existing security group rules will be deleted before new ones are created, resulting in a service interruption,
    but preserving the security group itself.
    **NOTE:** Setting this to `true` does not guarantee the security group will never be replaced,
    it only keeps changes to the security group rules from triggering a replacement.
    See the README for further discussion.
    EOT
  default     = false
}

variable "allow_all_egress" {
  type        = bool
  description = <<-EOT
    A convenience that adds to the rules specified elsewhere a rule that allows all egress.
    If this is false and no egress rules are specified via `rules` or `rule-matrix`, then no egress will be allowed.
    EOT
  default     = true
}

variable "rules" {
  type        = list(any)
  description = <<-EOT
    A list of Security Group rule objects. All elements of a list must be exactly the same type;
    use `rules_map` if you want to supply multiple lists of different types.
    The keys and values of the Security Group rule objects are fully compatible with the `aws_security_group_rule` resource,
    except for `security_group_id` which will be ignored, and the optional "key" which, if provided, must be unique
    and known at "plan" time.
    To get more info see the `security_group_rule` [documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule).
    ___Note:___ The length of the list must be known at plan time.
    This means you cannot use functions like `compact` or `sort` when computing the list.
    EOT
  default     = []
}

variable "rules_map" {
  type        = any
  description = <<-EOT
    A map-like object of lists of Security Group rule objects. All elements of a list must be exactly the same type,
    so this input accepts an object with keys (attributes) whose values are lists so you can separate different
    types into different lists and still pass them into one input. Keys must be known at "plan" time.
    The keys and values of the Security Group rule objects are fully compatible with the `aws_security_group_rule` resource,
    except for `security_group_id` which will be ignored, and the optional "key" which, if provided, must be unique
    and known at "plan" time.
    To get more info see the `security_group_rule` [documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule).
    EOT
  default     = {}
}

variable "rule_matrix" {
  type        = any
  description = <<-EOT
    A convenient way to apply the same set of rules to a set of subjects. See README for details.
    EOT
  default     = []
}

variable "security_group_create_timeout" {
  type        = string
  description = "How long to wait for the security group to be created."
  default     = "10m"
}

variable "security_group_delete_timeout" {
  type        = string
  description = <<-EOT
    How long to retry on `DependencyViolation` errors during security group deletion from
    lingering ENIs left by certain AWS services such as Elastic Load Balancing.
    EOT
  default     = "15m"
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

variable "inline_rules_enabled" {
  type        = bool
  description = <<-EOT
    NOT RECOMMENDED. Create rules "inline" instead of as separate `aws_security_group_rule` resources.
    See [#20046](https://github.com/hashicorp/terraform-provider-aws/issues/20046) for one of several issues with inline rules.
    See [this post](https://github.com/hashicorp/terraform-provider-aws/pull/9032#issuecomment-639545250) for details on the difference between inline rules and rule resources.
    EOT
  default     = false
}

variable "ingress_rules" {
  type    = any
  default = {}
}

variable "egress_rules" {
  type    = any
  default = {}
}

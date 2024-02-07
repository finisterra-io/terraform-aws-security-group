locals {
  enabled = var.enabled
  inline  = var.inline_rules_enabled

  # allow_all_egress = local.enabled && var.allow_all_egress
  allow_all_egress = false

  default_rule_description = "Managed by Terraform"

  create_security_group      = local.enabled && length(var.target_security_group_id) == 0
  sg_create_before_destroy   = var.create_before_destroy
  preserve_security_group_id = var.preserve_security_group_id || length(var.target_security_group_id) > 0

  target_security_group_id = try(var.target_security_group_id[0], "")

  # Setting `create_before_destroy` on the security group rules forces `create_before_destroy` behavior
  # on the security group, so we have to disable it on the rules if disabled on the security group.
  # It also forces a new security group to be created whenever any rule changes, so we disable it
  # when `local.preserve_security_group_id` is `true`. In the case where this Terraform module
  # did not create the security group, Terraform cannot replace the security group, and
  # `create_before_destroy` on the rules would fail due to duplicate rules being created, so again we must not allow it.
  rule_create_before_destroy = local.sg_create_before_destroy && !local.preserve_security_group_id
  # We also have to make it clear to Terraform that the "create before destroy" (CBD) rules
  # will never reference the "destroy before create" (DBC) security group (SG)
  # by keeping any conditional reference to the DBC SG out of the expression (unlike the `security_group_id` expression above).

  # The only way to guarantee success when creating new rules before destroying old ones
  # is to make the new rules part of a new security group.
  # See https://github.com/cloudposse/terraform-aws-security-group/issues/34
  rule_change_forces_new_security_group = local.enabled && local.rule_create_before_destroy
}


# You cannot toggle `create_before_destroy` based on input,
# you have to have a completely separate resource to change it.
resource "aws_security_group" "default" {
  # Because we have 2 almost identical alternatives, use x == false and x == true rather than x and !x
  count = local.create_security_group && local.sg_create_before_destroy == false ? 1 : 0

  name = var.security_group_name
  lifecycle {
    create_before_destroy = false
  }

  ########################################################################
  ## Everything from here to the end of this resource should be identical
  ## (copy and paste) in aws_security_group.default and aws_security_group.cbd

  description = var.security_group_description
  vpc_id      = var.vpc_name != null ? data.aws_vpc.default[0].id : var.vpc_id
  tags        = var.tags

  revoke_rules_on_delete = var.revoke_rules_on_delete

  ########################################################################

}

resource "aws_vpc_security_group_ingress_rule" "dbc" {
  for_each = var.ingress_rules

  lifecycle {
    # This has no actual effect, it is just here for emphasis
    create_before_destroy = false
  }
  security_group_id            = aws_security_group.default[0].id
  from_port                    = try(each.value.from_port, null)
  to_port                      = try(each.value.to_port, null)
  ip_protocol                  = each.value.ip_protocol
  description                  = try(each.value.description, null)
  cidr_ipv4                    = try(each.value.cidr_ipv4, null)
  cidr_ipv6                    = try(each.value.cidr_ipv6, null)
  prefix_list_id               = try(each.value.prefix_list_id, null)
  referenced_security_group_id = try(each.value.referenced_security_group_id, null) == "self" ? aws_security_group.default[0].id : try(each.value.referenced_security_group_id, null)
  tags                         = try(each.value.tags, null)
}

resource "aws_vpc_security_group_egress_rule" "dbc" {
  for_each = var.egress_rules

  lifecycle {
    # This has no actual effect, it is just here for emphasis
    create_before_destroy = false
  }
  security_group_id            = local.security_group_id
  from_port                    = try(each.value.from_port, null)
  to_port                      = try(each.value.to_port, null)
  ip_protocol                  = each.value.ip_protocol
  description                  = try(each.value.description, null)
  cidr_ipv4                    = try(each.value.cidr_ipv4, null)
  cidr_ipv6                    = try(each.value.cidr_ipv6, null)
  prefix_list_id               = try(each.value.prefix_list_id, null)
  referenced_security_group_id = try(each.value.referenced_security_group_id, null) == "self" ? aws_security_group.default[0].id : try(each.value.referenced_security_group_id, null)
  tags                         = try(each.value.tags, null)
}

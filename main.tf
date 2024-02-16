locals {
  sg_create_before_destroy = var.create_before_destroy
}


# You cannot toggle `create_before_destroy` based on input,
# you have to have a completely separate resource to change it.
resource "aws_security_group" "default" {
  # Because we have 2 almost identical alternatives, use x == false and x == true rather than x and !x
  count = var.enabled && local.sg_create_before_destroy == false ? 1 : 0

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
  description                  = try(each.value.description, "")
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
  security_group_id            = aws_security_group.default[0].id
  from_port                    = try(each.value.from_port, null)
  to_port                      = try(each.value.to_port, null)
  ip_protocol                  = each.value.ip_protocol
  description                  = try(each.value.description, "")
  cidr_ipv4                    = try(each.value.cidr_ipv4, null)
  cidr_ipv6                    = try(each.value.cidr_ipv6, null)
  prefix_list_id               = try(each.value.prefix_list_id, null)
  referenced_security_group_id = try(each.value.referenced_security_group_id, null) == "self" ? aws_security_group.default[0].id : try(each.value.referenced_security_group_id, null)
  tags                         = try(each.value.tags, null)
}

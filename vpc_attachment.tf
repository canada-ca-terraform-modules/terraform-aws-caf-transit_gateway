# VPC attachments - the resources that actually connect a VPC to this
# transit gateway (this is the "connect a VPC to another VPC" feature:
# attach two or more VPCs to the same hub, then route between them via
# route_table.tf). Map keyed by caller-chosen name so more than one VPC
# can attach to this hub.
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  for_each = lookup(var.transit_gateway, "vpc_attachments", {})

  transit_gateway_id = aws_ec2_transit_gateway.this.id
  # Each entry sets ONE of a literal vpc_id/subnet_ids or a vpc_key/subnet_keys resolved via var.vpc_ids/var.subnet_ids.
  vpc_id     = try(each.value.vpc_id, var.vpc_ids[each.value.vpc_key])
  subnet_ids = try(each.value.subnet_ids, [for s in each.value.subnet_keys : var.subnet_ids[each.value.vpc_key][s]])

  appliance_mode_support                          = try(each.value.appliance_mode_support, null)
  dns_support                                     = try(each.value.dns_support, null)
  ipv6_support                                    = try(each.value.ipv6_support, null)
  security_group_referencing_support              = try(each.value.security_group_referencing_support, null)
  transit_gateway_default_route_table_association = try(each.value.transit_gateway_default_route_table_association, null)
  transit_gateway_default_route_table_propagation = try(each.value.transit_gateway_default_route_table_propagation, null)

  tags = merge(var.tags, { Name = "${local.tgw-name}-${each.key}" }, try(each.value.tags, {}), local.module_tag)

  lifecycle {
    precondition {
      condition     = try(each.value.vpc_id, null) != null || contains(keys(var.vpc_ids), try(each.value.vpc_key, ""))
      error_message = "A vpc_attachments entry needs a literal vpc_id, or a vpc_key that exists in var.vpc_ids."
    }
    precondition {
      condition = try(each.value.subnet_ids, null) != null || (
        length(try(each.value.subnet_keys, [])) > 0 &&
        alltrue([for s in try(each.value.subnet_keys, []) : contains(keys(try(var.subnet_ids[each.value.vpc_key], {})), s)])
      )
      error_message = "A vpc_attachments entry needs literal subnet_ids, or subnet_keys that all exist under its vpc_key in var.subnet_ids."
    }
  }
}

# Accepter-side management of a cross-account VPC attachment that was
# automatically created in the peer account when the requester attached a
# VPC this account doesn't own. Only relevant when this module instance
# is managing the *accepting* account's side of a shared transit gateway.
resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "this" {
  for_each = lookup(var.transit_gateway, "vpc_attachment_accepters", {})

  transit_gateway_attachment_id = each.value.transit_gateway_attachment_id

  transit_gateway_default_route_table_association = try(each.value.transit_gateway_default_route_table_association, null)
  transit_gateway_default_route_table_propagation = try(each.value.transit_gateway_default_route_table_propagation, null)

  tags = merge(var.tags, { Name = "${local.tgw-name}-${each.key}" }, try(each.value.tags, {}), local.module_tag)
}

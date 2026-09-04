# VPC attachments - the resources that actually connect a VPC to this
# transit gateway (this is the "connect a VPC to another VPC" feature:
# attach two or more VPCs to the same hub, then route between them via
# route_table.tf). Map keyed by caller-chosen name so more than one VPC
# can attach to this hub.
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  for_each = try(var.transit_gateway.vpc_attachments, {})

  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = each.value.vpc_id
  subnet_ids         = each.value.subnet_ids

  appliance_mode_support                          = try(each.value.appliance_mode_support, null)
  dns_support                                     = try(each.value.dns_support, null)
  ipv6_support                                    = try(each.value.ipv6_support, null)
  security_group_referencing_support              = try(each.value.security_group_referencing_support, null)
  transit_gateway_default_route_table_association = try(each.value.transit_gateway_default_route_table_association, null)
  transit_gateway_default_route_table_propagation = try(each.value.transit_gateway_default_route_table_propagation, null)

  tags = merge(var.tags, { Name = "${local.tgw-name}-${each.key}" }, try(each.value.tags, {}), local.module_tag)
}

# Accepter-side management of a cross-account VPC attachment that was
# automatically created in the peer account when the requester attached a
# VPC this account doesn't own. Only relevant when this module instance
# is managing the *accepting* account's side of a shared transit gateway.
resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "this" {
  for_each = try(var.transit_gateway.vpc_attachment_accepters, {})

  transit_gateway_attachment_id = each.value.transit_gateway_attachment_id

  transit_gateway_default_route_table_association = try(each.value.transit_gateway_default_route_table_association, null)
  transit_gateway_default_route_table_propagation = try(each.value.transit_gateway_default_route_table_propagation, null)

  tags = merge(var.tags, { Name = "${local.tgw-name}-${each.key}" }, try(each.value.tags, {}), local.module_tag)
}

# Transit Gateway Connect - a GRE-based attachment on top of an existing
# VPC/Direct Connect attachment, typically used to bring third-party
# SD-WAN appliances into the transit gateway. Map keyed by caller-chosen
# name; transport_attachment_id normally points at one of this module's
# own aws_ec2_transit_gateway_vpc_attachment entries (pass its id via
# each.value.transport_attachment_id, e.g.
# aws_ec2_transit_gateway_vpc_attachment.this["appliance"].id from the
# caller side is not possible across modules, so the caller supplies the
# raw attachment ID - typically this module's own
# transit_gateway_vpc_attachment_ids output).
resource "aws_ec2_transit_gateway_connect" "this" {
  for_each = try(var.transit_gateway.connect_attachments, {})

  transit_gateway_id      = aws_ec2_transit_gateway.this.id
  transport_attachment_id = each.value.transport_attachment_id
  protocol                = try(each.value.protocol, null)

  transit_gateway_default_route_table_association = try(each.value.transit_gateway_default_route_table_association, null)
  transit_gateway_default_route_table_propagation = try(each.value.transit_gateway_default_route_table_propagation, null)

  tags = merge(var.tags, { Name = "${local.tgw-name}-${each.key}" }, try(each.value.tags, {}), local.module_tag)
}

# GRE peers for a Connect attachment above - keyed by caller-chosen name so
# a single Connect attachment can have more than one peer.
resource "aws_ec2_transit_gateway_connect_peer" "this" {
  for_each = try(var.transit_gateway.connect_peers, {})

  transit_gateway_attachment_id = try(
    aws_ec2_transit_gateway_connect.this[each.value.connect_attachment_key].id,
    each.value.transit_gateway_attachment_id,
  )
  peer_address            = each.value.peer_address
  inside_cidr_blocks      = each.value.inside_cidr_blocks
  bgp_asn                 = try(each.value.bgp_asn, null)
  transit_gateway_address = try(each.value.transit_gateway_address, null)

  tags = merge(var.tags, { Name = "${local.tgw-name}-${each.key}" }, try(each.value.tags, {}), local.module_tag)
}

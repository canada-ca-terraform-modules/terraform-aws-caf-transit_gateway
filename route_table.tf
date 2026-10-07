# Custom transit gateway route tables (beyond the hub's own built-in
# default route table) - lets the caller build hub-and-spoke or segmented
# routing between attachments instead of everything sharing one flat
# table. Map keyed by caller-chosen name.
resource "aws_ec2_transit_gateway_route_table" "this" {
  for_each = lookup(var.transit_gateway, "route_tables", {})

  transit_gateway_id = aws_ec2_transit_gateway.this.id

  tags = merge(var.tags, { Name = "${local.tgw-name}-${each.key}" }, try(each.value.tags, {}), local.module_tag)
}

# Every resource below resolves a caller-supplied attachment/route-table
# reference to an actual ID. Callers can point at an attachment or route
# table created by this same module (via its map key, `attachment_key`/
# `route_table_key`) or an external one (via a raw
# transit_gateway_attachment_id/transit_gateway_route_table_id) - the same
# "internal key falls back to raw ID" shape used throughout this module.

# Associates an attachment with a route table - which route table an
# attachment's traffic is routed FROM. Map keyed by caller-chosen name.
resource "aws_ec2_transit_gateway_route_table_association" "this" {
  for_each = lookup(var.transit_gateway, "route_table_associations", {})

  transit_gateway_attachment_id = try(
    aws_ec2_transit_gateway_vpc_attachment.this[each.value.attachment_key].id,
    aws_ec2_transit_gateway_peering_attachment.this[each.value.attachment_key].id,
    aws_ec2_transit_gateway_connect.this[each.value.attachment_key].id,
    each.value.transit_gateway_attachment_id,
  )
  transit_gateway_route_table_id = try(aws_ec2_transit_gateway_route_table.this[each.value.route_table_key].id, each.value.transit_gateway_route_table_id)
  replace_existing_association   = try(each.value.replace_existing_association, null)
}

# Propagates an attachment's routes INTO a route table. Map keyed by
# caller-chosen name.
resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  for_each = lookup(var.transit_gateway, "route_table_propagations", {})

  transit_gateway_attachment_id = try(
    aws_ec2_transit_gateway_vpc_attachment.this[each.value.attachment_key].id,
    aws_ec2_transit_gateway_peering_attachment.this[each.value.attachment_key].id,
    aws_ec2_transit_gateway_connect.this[each.value.attachment_key].id,
    each.value.transit_gateway_attachment_id,
  )
  transit_gateway_route_table_id = try(aws_ec2_transit_gateway_route_table.this[each.value.route_table_key].id, each.value.transit_gateway_route_table_id)
}

# Static routes within a transit gateway route table - either forwarding
# to an attachment or a blackhole (drop). Map keyed by caller-chosen name.
resource "aws_ec2_transit_gateway_route" "this" {
  for_each = lookup(var.transit_gateway, "routes", {})

  transit_gateway_route_table_id = try(aws_ec2_transit_gateway_route_table.this[each.value.route_table_key].id, each.value.transit_gateway_route_table_id)
  destination_cidr_block         = each.value.destination_cidr_block
  blackhole                      = try(each.value.blackhole, null)
  transit_gateway_attachment_id = try(each.value.blackhole, false) ? null : try(
    aws_ec2_transit_gateway_vpc_attachment.this[each.value.attachment_key].id,
    aws_ec2_transit_gateway_peering_attachment.this[each.value.attachment_key].id,
    aws_ec2_transit_gateway_connect.this[each.value.attachment_key].id,
    try(each.value.transit_gateway_attachment_id, null),
  )
}

# References a managed prefix list within a transit gateway route table -
# a set of CIDRs routed as one unit instead of one aws_ec2_transit_gateway_route
# per CIDR. Map keyed by caller-chosen name.
resource "aws_ec2_transit_gateway_prefix_list_reference" "this" {
  for_each = lookup(var.transit_gateway, "prefix_list_references", {})

  transit_gateway_route_table_id = try(aws_ec2_transit_gateway_route_table.this[each.value.route_table_key].id, each.value.transit_gateway_route_table_id)
  prefix_list_id                 = each.value.prefix_list_id
  blackhole                      = try(each.value.blackhole, null)
  transit_gateway_attachment_id = try(each.value.blackhole, false) ? null : try(
    aws_ec2_transit_gateway_vpc_attachment.this[each.value.attachment_key].id,
    aws_ec2_transit_gateway_peering_attachment.this[each.value.attachment_key].id,
    aws_ec2_transit_gateway_connect.this[each.value.attachment_key].id,
    try(each.value.transit_gateway_attachment_id, null),
  )
}

# Points the hub's *default* association route table at one of the custom
# route tables above, instead of the hub's own built-in default one. Map
# keyed by caller-chosen name, but in practice a hub has exactly one
# default association route table so this map should hold at most one
# entry.
resource "aws_ec2_transit_gateway_default_route_table_association" "this" {
  for_each = lookup(var.transit_gateway, "default_route_table_associations", {})

  transit_gateway_id             = aws_ec2_transit_gateway.this.id
  transit_gateway_route_table_id = try(aws_ec2_transit_gateway_route_table.this[each.value.route_table_key].id, each.value.transit_gateway_route_table_id)
}

# Points the hub's *default* propagation route table at one of the custom
# route tables above. Map keyed by caller-chosen name, same one-entry
# expectation as the association resource.
resource "aws_ec2_transit_gateway_default_route_table_propagation" "this" {
  for_each = lookup(var.transit_gateway, "default_route_table_propagations", {})

  transit_gateway_id             = aws_ec2_transit_gateway.this.id
  transit_gateway_route_table_id = try(aws_ec2_transit_gateway_route_table.this[each.value.route_table_key].id, each.value.transit_gateway_route_table_id)
}

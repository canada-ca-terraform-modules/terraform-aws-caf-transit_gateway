# Peering attachments - connects this transit gateway to a transit
# gateway in another region (or another account), so VPCs attached to
# either hub can reach each other. Map keyed by caller-chosen name.
resource "aws_ec2_transit_gateway_peering_attachment" "this" {
  for_each = lookup(var.transit_gateway, "peering_attachments", {})

  transit_gateway_id      = aws_ec2_transit_gateway.this.id
  peer_transit_gateway_id = each.value.peer_transit_gateway_id
  peer_region             = each.value.peer_region
  peer_account_id         = try(each.value.peer_account_id, null)

  dynamic "options" {
    for_each = try(each.value.options, null) != null ? [each.value.options] : []
    content {
      dynamic_routing = try(options.value.dynamic_routing, null)
    }
  }

  tags = merge(var.tags, { Name = "${local.tgw-name}-${each.key}" }, try(each.value.tags, {}), local.module_tag)
}

# Accepter-side management of a peering attachment initiated from the
# peer account/region. Only relevant when this module instance is
# managing the accepting side.
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this" {
  for_each = lookup(var.transit_gateway, "peering_attachment_accepters", {})

  transit_gateway_attachment_id = each.value.transit_gateway_attachment_id

  tags = merge(var.tags, { Name = "${local.tgw-name}-${each.key}" }, try(each.value.tags, {}), local.module_tag)
}

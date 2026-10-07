# Transit Gateway Policy Tables - an alternative to route tables that
# routes attachments based on packet attributes (source/destination,
# protocol, port) rather than destination CIDR alone. Map keyed by
# caller-chosen name.
resource "aws_ec2_transit_gateway_policy_table" "this" {
  for_each = lookup(var.transit_gateway, "policy_tables", {})

  transit_gateway_id = aws_ec2_transit_gateway.this.id

  tags = merge(var.tags, { Name = "${local.tgw-name}-${each.key}" }, try(each.value.tags, {}), local.module_tag)
}

# Associates an attachment with a policy table above. Map keyed by
# caller-chosen name.
resource "aws_ec2_transit_gateway_policy_table_association" "this" {
  for_each = lookup(var.transit_gateway, "policy_table_associations", {})

  transit_gateway_attachment_id = try(
    aws_ec2_transit_gateway_vpc_attachment.this[each.value.attachment_key].id,
    aws_ec2_transit_gateway_peering_attachment.this[each.value.attachment_key].id,
    aws_ec2_transit_gateway_connect.this[each.value.attachment_key].id,
    each.value.transit_gateway_attachment_id,
  )
  transit_gateway_policy_table_id = try(aws_ec2_transit_gateway_policy_table.this[each.value.policy_table_key].id, each.value.transit_gateway_policy_table_id)
}

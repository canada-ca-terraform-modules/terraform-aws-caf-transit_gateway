# Transit Gateway Metering Policies - opt-in cost-allocation policies that
# meter data transfer for a set of "middlebox" attachments (e.g. a
# firewall appliance attachment), plus the rule entries within each
# policy. Map keyed by caller-chosen name.
resource "aws_ec2_transit_gateway_metering_policy" "this" {
  for_each = try(var.transit_gateway.metering_policies, {})

  transit_gateway_id       = aws_ec2_transit_gateway.this.id
  middlebox_attachment_ids = try(each.value.middlebox_attachment_ids, null)

  tags = merge(var.tags, { Name = "${local.tgw-name}-${each.key}" }, try(each.value.tags, {}), local.module_tag)
}

# Rule entries within a metering policy above. Map keyed by caller-chosen
# name.
resource "aws_ec2_transit_gateway_metering_policy_entry" "this" {
  for_each = try(var.transit_gateway.metering_policy_entries, {})

  transit_gateway_metering_policy_id = try(aws_ec2_transit_gateway_metering_policy.this[each.value.metering_policy_key].transit_gateway_metering_policy_id, each.value.transit_gateway_metering_policy_id)
  policy_rule_number                 = each.value.policy_rule_number
  metered_account                    = each.value.metered_account

  protocol                                    = try(each.value.protocol, null)
  source_cidr_block                           = try(each.value.source_cidr_block, null)
  source_port_range                           = try(each.value.source_port_range, null)
  source_transit_gateway_attachment_id        = try(each.value.source_transit_gateway_attachment_id, null)
  source_transit_gateway_attachment_type      = try(each.value.source_transit_gateway_attachment_type, null)
  destination_cidr_block                      = try(each.value.destination_cidr_block, null)
  destination_port_range                      = try(each.value.destination_port_range, null)
  destination_transit_gateway_attachment_id   = try(each.value.destination_transit_gateway_attachment_id, null)
  destination_transit_gateway_attachment_type = try(each.value.destination_transit_gateway_attachment_type, null)
}

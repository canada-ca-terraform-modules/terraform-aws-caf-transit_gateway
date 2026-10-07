# Transit Gateway Multicast - an opt-in domain for multicast traffic
# between attachments, plus the subnet associations and group
# memberships/sources within it. Only relevant when
# var.transit_gateway.multicast_support = "enable" on the hub. Map keyed
# by caller-chosen name.
resource "aws_ec2_transit_gateway_multicast_domain" "this" {
  for_each = lookup(var.transit_gateway, "multicast_domains", {})

  transit_gateway_id = aws_ec2_transit_gateway.this.id

  igmpv2_support                  = try(each.value.igmpv2_support, null)
  static_sources_support          = try(each.value.static_sources_support, null)
  auto_accept_shared_associations = try(each.value.auto_accept_shared_associations, null)

  tags = merge(var.tags, { Name = "${local.tgw-name}-${each.key}" }, try(each.value.tags, {}), local.module_tag)
}

# Associates a subnet (via its attachment) with a multicast domain above.
# Map keyed by caller-chosen name.
resource "aws_ec2_transit_gateway_multicast_domain_association" "this" {
  for_each = lookup(var.transit_gateway, "multicast_domain_associations", {})

  transit_gateway_multicast_domain_id = try(aws_ec2_transit_gateway_multicast_domain.this[each.value.multicast_domain_key].id, each.value.transit_gateway_multicast_domain_id)
  transit_gateway_attachment_id = try(
    aws_ec2_transit_gateway_vpc_attachment.this[each.value.attachment_key].id,
    each.value.transit_gateway_attachment_id,
  )
  subnet_id = each.value.subnet_id
}

# Registers a network interface as a multicast group member (receiver) on
# a domain above. Map keyed by caller-chosen name.
resource "aws_ec2_transit_gateway_multicast_group_member" "this" {
  for_each = lookup(var.transit_gateway, "multicast_group_members", {})

  transit_gateway_multicast_domain_id = try(aws_ec2_transit_gateway_multicast_domain.this[each.value.multicast_domain_key].id, each.value.transit_gateway_multicast_domain_id)
  network_interface_id                = each.value.network_interface_id
  group_ip_address                    = each.value.group_ip_address
}

# Registers a network interface as a multicast group source (sender) on a
# domain above. Map keyed by caller-chosen name.
resource "aws_ec2_transit_gateway_multicast_group_source" "this" {
  for_each = lookup(var.transit_gateway, "multicast_group_sources", {})

  transit_gateway_multicast_domain_id = try(aws_ec2_transit_gateway_multicast_domain.this[each.value.multicast_domain_key].id, each.value.transit_gateway_multicast_domain_id)
  network_interface_id                = each.value.network_interface_id
  group_ip_address                    = each.value.group_ip_address
}

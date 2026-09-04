# The transit gateway hub - one per module instance, always created.
# Everything else in this module (attachments, route tables, associations,
# propagations, multicast, metering) hangs off this single hub via its ID.
#
# default_route_table_association/default_route_table_propagation here are
# the hub's own "enable/disable" toggles for its built-in default route
# table - distinct from aws_ec2_transit_gateway_default_route_table_association/
# _propagation in route_table.tf, which instead point the hub's default
# association/propagation route table at a *different*, non-default route
# table created by this module.

resource "aws_ec2_transit_gateway" "this" {
  description = try(var.transit_gateway.description, null)

  amazon_side_asn                    = try(var.transit_gateway.amazon_side_asn, null)
  auto_accept_shared_attachments     = try(var.transit_gateway.auto_accept_shared_attachments, null)
  default_route_table_association    = try(var.transit_gateway.default_route_table_association, null)
  default_route_table_propagation    = try(var.transit_gateway.default_route_table_propagation, null)
  dns_support                        = try(var.transit_gateway.dns_support, null)
  encryption_support                 = try(var.transit_gateway.encryption_support, null)
  multicast_support                  = try(var.transit_gateway.multicast_support, null)
  security_group_referencing_support = try(var.transit_gateway.security_group_referencing_support, null)
  transit_gateway_cidr_blocks        = try(var.transit_gateway.transit_gateway_cidr_blocks, null)
  vpn_ecmp_support                   = try(var.transit_gateway.vpn_ecmp_support, null)

  dynamic "timeouts" {
    for_each = try(var.transit_gateway.timeouts, null) != null ? [var.transit_gateway.timeouts] : []
    content {
      create = try(timeouts.value.create, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }

  # Tags - Merging tags provided by ESLZ with tags provided by the user
  tags = merge(var.tags, { Name = local.tgw-name }, try(var.transit_gateway.tags, {}), local.module_tag)
}

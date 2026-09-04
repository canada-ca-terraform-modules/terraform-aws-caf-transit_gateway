output "object" {
  # ponytail: hand-picked non-deprecated attributes, same rationale as the
  # terraform-aws-caf-vpc module's `object` output.
  description = "Returns the full transit gateway hub object"
  value = {
    id                                 = aws_ec2_transit_gateway.this.id
    arn                                = aws_ec2_transit_gateway.this.arn
    owner_id                           = aws_ec2_transit_gateway.this.owner_id
    association_default_route_table_id = aws_ec2_transit_gateway.this.association_default_route_table_id
    propagation_default_route_table_id = aws_ec2_transit_gateway.this.propagation_default_route_table_id
    tags_all                           = aws_ec2_transit_gateway.this.tags_all
  }
  sensitive = true
}

output "id" {
  description = "Returns the ID of the transit gateway hub"
  value       = aws_ec2_transit_gateway.this.id
}

output "arn" {
  description = "Returns the ARN of the transit gateway hub"
  value       = aws_ec2_transit_gateway.this.arn
}

output "name" {
  description = "Returns the generated Name tag value of the transit gateway"
  value       = local.tgw-name
}

output "association_default_route_table_id" {
  description = "Returns the ID of the transit gateway's default association route table"
  value       = aws_ec2_transit_gateway.this.association_default_route_table_id
}

output "propagation_default_route_table_id" {
  description = "Returns the ID of the transit gateway's default propagation route table"
  value       = aws_ec2_transit_gateway.this.propagation_default_route_table_id
}

output "vpc_attachment_ids" {
  description = "Returns the IDs of VPC attachments, keyed by the caller's chosen name"
  value       = { for k, v in aws_ec2_transit_gateway_vpc_attachment.this : k => v.id }
}

output "peering_attachment_ids" {
  description = "Returns the IDs of peering attachments, keyed by the caller's chosen name"
  value       = { for k, v in aws_ec2_transit_gateway_peering_attachment.this : k => v.id }
}

output "connect_attachment_ids" {
  description = "Returns the IDs of Connect (GRE) attachments, keyed by the caller's chosen name"
  value       = { for k, v in aws_ec2_transit_gateway_connect.this : k => v.id }
}

output "route_table_ids" {
  description = "Returns the IDs of custom transit gateway route tables, keyed by the caller's chosen name"
  value       = { for k, v in aws_ec2_transit_gateway_route_table.this : k => v.id }
}

output "policy_table_ids" {
  description = "Returns the IDs of transit gateway policy tables, keyed by the caller's chosen name"
  value       = { for k, v in aws_ec2_transit_gateway_policy_table.this : k => v.id }
}

output "multicast_domain_ids" {
  description = "Returns the IDs of transit gateway multicast domains, keyed by the caller's chosen name"
  value       = { for k, v in aws_ec2_transit_gateway_multicast_domain.this : k => v.id }
}

output "metering_policy_ids" {
  description = "Returns the IDs of transit gateway metering policies, keyed by the caller's chosen name"
  value       = { for k, v in aws_ec2_transit_gateway_metering_policy.this : k => v.transit_gateway_metering_policy_id }
}

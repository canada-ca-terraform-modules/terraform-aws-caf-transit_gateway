# terraform-aws-caf-transit_gateway

CAF-compliant Terraform module for AWS Transit Gateway. Supports the full `aws_ec2_transit_gateway*` resource family available in aws provider `~> 6.0` (tested against `6.63.0`): the hub itself, VPC attachments (+ accepter) - the primary way to connect a VPC to one or more other VPCs through a shared hub - peering attachments (+ accepter) for hub-to-hub connectivity across regions/accounts, Connect (GRE) attachments + peers for SD-WAN appliances, custom route tables + associations + propagations + static routes + prefix list references + default-route-table overrides, policy tables + associations, multicast domains + associations + group members/sources, and metering policies + entries.

## Usage

A transit gateway hub is not scoped to a single VPC (see [Scope](#scope) in [`terraform-aws-caf-vpc`](https://github.com/canada-ca-terraform-modules/terraform-aws-caf-vpc)'s README) - it lives in its own module here, and `vpc_attachments` entries take a `vpc_id`/`subnet_ids` pointing at VPCs/subnets created by the `terraform-aws-caf-vpc`/`terraform-aws-caf-subnet` modules.

### ESLZ module block (`ESLZ/transit_gateway.tf`)

```hcl
module "transit_gateway" {
  source   = "github.com/canada-ca-terraform-modules/terraform-aws-caf-transit_gateway.git?ref=v1.1.0"
  for_each = var.transit_gateways

  userDefinedString = each.key
  env               = var.env
  vpc_ids           = var.vpc_ids
  subnet_ids        = var.subnet_ids
  transit_gateway   = each.value
  tags              = var.tags
}
```

`vpc_attachments` entries take either a literal `vpc_id`/`subnet_ids`, or a `vpc_key`/`subnet_keys` resolved inside the module against the `vpc_ids` (VPC key to ID) and `subnet_ids` (VPC key to subnet key to ID) inputs, e.g. `vpc_ids = { for k, v in module.vpc : k => v.id }` and `subnet_ids = { for k, v in module.vpc : k => v.subnet_ids }`. Subnet keys are scoped to their VPC, so two VPCs can both have a `tgw-1a`. An unknown `vpc_key` or `subnet_keys` entry fails the plan with a clear message. See [`ESLZ/transit_gateway.tfvars`](ESLZ/transit_gateway.tfvars) for the full set of `transit_gateway` object parameters.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ec2_transit_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway) | resource |
| [aws_ec2_transit_gateway_connect.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_connect) | resource |
| [aws_ec2_transit_gateway_connect_peer.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_connect_peer) | resource |
| [aws_ec2_transit_gateway_default_route_table_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_default_route_table_association) | resource |
| [aws_ec2_transit_gateway_default_route_table_propagation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_default_route_table_propagation) | resource |
| [aws_ec2_transit_gateway_metering_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_metering_policy) | resource |
| [aws_ec2_transit_gateway_metering_policy_entry.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_metering_policy_entry) | resource |
| [aws_ec2_transit_gateway_multicast_domain.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_multicast_domain) | resource |
| [aws_ec2_transit_gateway_multicast_domain_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_multicast_domain_association) | resource |
| [aws_ec2_transit_gateway_multicast_group_member.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_multicast_group_member) | resource |
| [aws_ec2_transit_gateway_multicast_group_source.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_multicast_group_source) | resource |
| [aws_ec2_transit_gateway_peering_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment) | resource |
| [aws_ec2_transit_gateway_peering_attachment_accepter.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment_accepter) | resource |
| [aws_ec2_transit_gateway_policy_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_policy_table) | resource |
| [aws_ec2_transit_gateway_policy_table_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_policy_table_association) | resource |
| [aws_ec2_transit_gateway_prefix_list_reference.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_prefix_list_reference) | resource |
| [aws_ec2_transit_gateway_route.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table) | resource |
| [aws_ec2_transit_gateway_route_table_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_propagation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_propagation) | resource |
| [aws_ec2_transit_gateway_vpc_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment) | resource |
| [aws_ec2_transit_gateway_vpc_attachment_accepter.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment_accepter) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | (Required) env value used in name generation | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Optional map of VPC key to a map of subnet key to its ID. Resolves a vpc\_attachments entry's subnet\_keys within that entry's vpc\_key, e.g. { for k, v in module.vpc : k => v.subnet\_ids }. | `map(map(string))` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all resources (merged with transit\_gateway.tags) | `map(string)` | `{}` | no |
| <a name="input_transit_gateway"></a> [transit\_gateway](#input\_transit\_gateway) | (Required) Object describing the transit gateway and every attachment/route/association hung off it (see TFVars Parameters below). Optional `name` key overrides the auto-derived "env-userDefinedString" Name tag value. | `any` | `{}` | no |
| <a name="input_userDefinedString"></a> [userDefinedString](#input\_userDefinedString) | (Required) UserDefinedString part of the name of the transit gateway | `string` | n/a | yes |
| <a name="input_vpc_ids"></a> [vpc\_ids](#input\_vpc\_ids) | Optional map of VPC key to its ID. Resolves a vpc\_attachments entry's vpc\_key, e.g. { for k, v in module.vpc : k => v.id }. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | Returns the ARN of the transit gateway hub |
| <a name="output_association_default_route_table_id"></a> [association\_default\_route\_table\_id](#output\_association\_default\_route\_table\_id) | Returns the ID of the transit gateway's default association route table |
| <a name="output_connect_attachment_ids"></a> [connect\_attachment\_ids](#output\_connect\_attachment\_ids) | Returns the IDs of Connect (GRE) attachments, keyed by the caller's chosen name |
| <a name="output_id"></a> [id](#output\_id) | Returns the ID of the transit gateway hub |
| <a name="output_metering_policy_ids"></a> [metering\_policy\_ids](#output\_metering\_policy\_ids) | Returns the IDs of transit gateway metering policies, keyed by the caller's chosen name |
| <a name="output_multicast_domain_ids"></a> [multicast\_domain\_ids](#output\_multicast\_domain\_ids) | Returns the IDs of transit gateway multicast domains, keyed by the caller's chosen name |
| <a name="output_name"></a> [name](#output\_name) | Returns the generated Name tag value of the transit gateway |
| <a name="output_object"></a> [object](#output\_object) | Returns the full transit gateway hub object |
| <a name="output_peering_attachment_ids"></a> [peering\_attachment\_ids](#output\_peering\_attachment\_ids) | Returns the IDs of peering attachments, keyed by the caller's chosen name |
| <a name="output_policy_table_ids"></a> [policy\_table\_ids](#output\_policy\_table\_ids) | Returns the IDs of transit gateway policy tables, keyed by the caller's chosen name |
| <a name="output_propagation_default_route_table_id"></a> [propagation\_default\_route\_table\_id](#output\_propagation\_default\_route\_table\_id) | Returns the ID of the transit gateway's default propagation route table |
| <a name="output_route_table_ids"></a> [route\_table\_ids](#output\_route\_table\_ids) | Returns the IDs of custom transit gateway route tables, keyed by the caller's chosen name |
| <a name="output_vpc_attachment_ids"></a> [vpc\_attachment\_ids](#output\_vpc\_attachment\_ids) | Returns the IDs of VPC attachments, keyed by the caller's chosen name |
<!-- END_TF_DOCS -->

## Scope

This module implements the full `aws_ec2_transit_gateway*` resource family: 22 resources in aws provider `6.63.0`, all covered - `scripts/coverage_check.sh hashicorp/aws 6.63.0 aws_ec2_transit_gateway .` reports full parity with nothing excluded.

Every resource that references another resource this module also manages (an attachment, a route table, a multicast domain, a policy table, a metering policy) accepts **either** a literal `transit_gateway_*_id` **or** a `*_key` naming another entry's map key in this same module invocation, resolved internally via `try()` - so a caller can wire two features together (e.g. a route table association pointing at a VPC attachment created in the same `transit_gateway` object) without needing a second `terraform apply` to learn an ID first.

## TFVars Parameters

The `transit_gateway` object variable (top-level keys are the hub's own arguments; every other key below is a map of sub-resources keyed by caller-chosen name):

| Key | Type | Default | Description |
| --- | ---- | ------- | ----------- |
| `name` | string | auto-derived | Overrides the auto-derived `"env-userDefinedString"` Name tag value. |
| `description` | string | `null` | Hub description. |
| `amazon_side_asn` | number | AWS default (64512) | BGP ASN on the Amazon side of the hub. |
| `auto_accept_shared_attachments` | string | `"disable"` | `enable`/`disable` - auto-accept attachments shared via RAM. |
| `default_route_table_association` | string | `"enable"` | `enable`/`disable` - whether new attachments auto-join the hub's built-in default association route table. |
| `default_route_table_propagation` | string | `"enable"` | `enable`/`disable` - whether attachments auto-propagate into the hub's built-in default propagation route table. |
| `dns_support` | string | `"enable"` | `enable`/`disable`. |
| `encryption_support` | string | AWS default | `enable`/`disable` - only settable at creation. |
| `multicast_support` | string | `"disable"` | `enable`/`disable` - must be `"enable"` before adding `multicast_domains`. |
| `security_group_referencing_support` | string | AWS default | `enable`/`disable`. |
| `transit_gateway_cidr_blocks` | list(string) | `null` | CIDR block(s) owned by the hub itself (used by Connect/appliance attachments). |
| `vpn_ecmp_support` | string | `"enable"` | `enable`/`disable`. |
| `timeouts` | object | `null` | `{ create, update, delete }` duration strings. |
| `tags` | map(string) | `{}` | Tags for the hub resource. |
| `vpc_attachments` | map(object) | `{}` | `{ vpc_id (required, or vpc_key), subnet_ids (required, or subnet_keys under that vpc_key), appliance_mode_support, dns_support, ipv6_support, security_group_referencing_support, transit_gateway_default_route_table_association, transit_gateway_default_route_table_propagation, tags }`. |
| `vpc_attachment_accepters` | map(object) | `{}` | `{ transit_gateway_attachment_id (required), transit_gateway_default_route_table_association, transit_gateway_default_route_table_propagation, tags }`. |
| `peering_attachments` | map(object) | `{}` | `{ peer_transit_gateway_id (required), peer_region (required), peer_account_id, options { dynamic_routing }, tags }`. |
| `peering_attachment_accepters` | map(object) | `{}` | `{ transit_gateway_attachment_id (required), tags }`. |
| `connect_attachments` | map(object) | `{}` | `{ transport_attachment_id (required, usually a vpc_attachments id), protocol, transit_gateway_default_route_table_association, transit_gateway_default_route_table_propagation, tags }`. |
| `connect_peers` | map(object) | `{}` | `{ connect_attachment_key (or transit_gateway_attachment_id), peer_address (required), inside_cidr_blocks (required), bgp_asn, transit_gateway_address, tags }`. |
| `route_tables` | map(object) | `{}` | `{ tags }`. |
| `route_table_associations` | map(object) | `{}` | `{ attachment_key (or transit_gateway_attachment_id), route_table_key (or transit_gateway_route_table_id), replace_existing_association }`. |
| `route_table_propagations` | map(object) | `{}` | `{ attachment_key (or transit_gateway_attachment_id), route_table_key (or transit_gateway_route_table_id) }`. |
| `routes` | map(object) | `{}` | `{ route_table_key (or transit_gateway_route_table_id), destination_cidr_block (required), attachment_key (or transit_gateway_attachment_id, omitted when blackhole = true), blackhole }`. |
| `prefix_list_references` | map(object) | `{}` | `{ route_table_key (or transit_gateway_route_table_id), prefix_list_id (required), attachment_key (or transit_gateway_attachment_id, omitted when blackhole = true), blackhole }`. |
| `default_route_table_associations` | map(object) | `{}` | `{ route_table_key (or transit_gateway_route_table_id) }` - points the hub's default association route table at a custom one (at most one entry expected). |
| `default_route_table_propagations` | map(object) | `{}` | `{ route_table_key (or transit_gateway_route_table_id) }` - points the hub's default propagation route table at a custom one (at most one entry expected). |
| `policy_tables` | map(object) | `{}` | `{ tags }`. |
| `policy_table_associations` | map(object) | `{}` | `{ attachment_key (or transit_gateway_attachment_id), policy_table_key (or transit_gateway_policy_table_id) }`. |
| `multicast_domains` | map(object) | `{}` | `{ igmpv2_support, static_sources_support, auto_accept_shared_associations, tags }`. |
| `multicast_domain_associations` | map(object) | `{}` | `{ multicast_domain_key (or transit_gateway_multicast_domain_id), attachment_key (or transit_gateway_attachment_id), subnet_id (required) }`. |
| `multicast_group_members` | map(object) | `{}` | `{ multicast_domain_key (or transit_gateway_multicast_domain_id), network_interface_id (required), group_ip_address (required) }`. |
| `multicast_group_sources` | map(object) | `{}` | `{ multicast_domain_key (or transit_gateway_multicast_domain_id), network_interface_id (required), group_ip_address (required) }`. |
| `metering_policies` | map(object) | `{}` | `{ middlebox_attachment_ids, tags }`. |
| `metering_policy_entries` | map(object) | `{}` | `{ metering_policy_key (or transit_gateway_metering_policy_id), policy_rule_number (required), metered_account (required: source-attachment-owner/destination-attachment-owner/transit-gateway-owner), protocol, source_cidr_block, source_port_range, source_transit_gateway_attachment_id, source_transit_gateway_attachment_type, destination_cidr_block, destination_port_range, destination_transit_gateway_attachment_id, destination_transit_gateway_attachment_type }`. |

See [`ESLZ/transit_gateway.tfvars`](ESLZ/transit_gateway.tfvars) for a fully worked, commented example of every key above.

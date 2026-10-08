# Changelog

All notable changes to this module are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This file must be updated as part of every change to this module.

## [Unreleased]

## [1.1.0]

### Added

- `vpc_ids` and `subnet_ids` inputs. A `vpc_attachments` entry can now set
  `vpc_key` and `subnet_keys` instead of a literal `vpc_id`/`subnet_ids`; the
  module resolves them through `vpc_ids` (VPC key to ID) and `subnet_ids`
  (VPC key to subnet key to ID), so callers pass `each.value` straight
  through. Subnet keys are scoped to their VPC. An unknown key fails the
  plan with a precondition message. The literal form is unchanged.

### Changed

- `ESLZ/transit_gateway.tf` no longer resolves keys itself and its
  `subnet_ids` variable is now `map(map(string))` (VPC key to subnet key to
  ID) instead of a flat map.

## [1.0.1]

### Fixed

- `for_each` on every optional resource used `try(var.transit_gateway.X, {})`,
  which returns a wholly unknown value when any nested value is unknown at
  plan time (e.g. `vpc_id` of a VPC created in the same configuration), so
  the plan failed with "Invalid for_each argument". Replaced with
  `lookup(var.transit_gateway, "X", {})`, which keeps the map keys known.
  Added a regression test (`tests/unknown`).

### Added

- Initial module: full parity with the `aws_ec2_transit_gateway*` resource
  family in aws provider `6.63.0` (22 resources) - the hub
  (`aws_ec2_transit_gateway`), VPC attachments + accepter, peering
  attachments + accepter, Connect (GRE) attachments + peers, custom route
  tables + associations + propagations + routes + prefix list references
  + default-route-table overrides, policy tables + associations,
  multicast domains + associations + group members/sources, and metering
  policies + entries. Companion module to `terraform-aws-caf-vpc` /
  `terraform-aws-caf-subnet` (see README's Scope section for why the hub
  isn't part of the VPC module itself). 15 test runs in
  `tests/transit_gateway.tftest.hcl` covering naming, defaults, tag
  merging, absence-by-default for every optional resource, and one
  presence run per feature.

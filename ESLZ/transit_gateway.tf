## ESLZ wrapper for terraform-aws-caf-transit_gateway.
##
## vpc_attachments entries need a vpc_id + subnet_ids that live in other
## CAF modules (terraform-aws-caf-vpc / terraform-aws-caf-subnet). Per
## caf-conventions.md's "Cross-module foreign-key references", the reusable
## module itself only ever accepts literal IDs - this wrapper is what lets
## an entry reference those other modules' ESLZ config-names (vpc_key /
## subnet_keys) instead, resolving them to literal IDs via the vpc_ids /
## subnet_ids maps below before handing the object to the module.

terraform {
  required_version = ">= 1.9"
}

variable "transit_gateways" {
  description = "Transit gateway instances to deploy"
  type        = any
  default     = {}
}

variable "vpc_ids" {
  description = "Optional map of VPC config-name (the key used in terraform-aws-caf-vpc's ESLZ variable) to its actual ID - wire as vpc_ids = { for k, v in module.vpc : k => v.id } when composing both wrappers in the same root module. Used to resolve a vpc_attachments entry's vpc_key."
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  description = "Optional map of subnet config-name (the key used in terraform-aws-caf-subnet's ESLZ variable) to its actual ID - wire as subnet_ids = { for k, v in module.subnet : k => v.id }. Used to resolve a vpc_attachments entry's subnet_keys."
  type        = map(string)
  default     = {}
}

locals {
  # Each vpc_attachments entry picks ONE of a literal vpc_id/subnet_ids or
  # a vpc_key/subnet_keys referencing the vpc/subnet modules' ESLZ
  # config-names - entries that already set the literal form pass through
  # unchanged.
  transit_gateways = {
    for name, tgw in var.transit_gateways : name => merge(tgw, {
      vpc_attachments = {
        for attach_name, attachment in try(tgw.vpc_attachments, {}) : attach_name => merge(attachment, {
          vpc_id     = try(attachment.vpc_id, var.vpc_ids[attachment.vpc_key])
          subnet_ids = try(attachment.subnet_ids, [for k in attachment.subnet_keys : var.subnet_ids[k]])
        })
      }
    })
  }
}

module "transit_gateway" {
  source   = "github.com/canada-ca-terraform-modules/terraform-aws-caf-transit_gateway.git?ref=v1.0.0"
  for_each = local.transit_gateways

  userDefinedString = each.key
  env               = var.env
  transit_gateway   = each.value
  tags              = var.tags
}

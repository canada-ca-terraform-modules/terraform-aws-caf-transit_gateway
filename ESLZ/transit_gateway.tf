## ESLZ wrapper for terraform-aws-caf-transit_gateway.
##
## vpc_attachments entries take either a literal vpc_id/subnet_ids, or a
## vpc_key/subnet_keys that the module resolves through the vpc_ids/subnet_ids
## maps below - so each.value goes straight to the module.

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
  description = "Optional map of VPC config-name to a map of subnet config-name to its actual ID - wire as subnet_ids = { for k, v in module.vpc : k => v.subnet_ids }. Used to resolve a vpc_attachments entry's subnet_keys within its vpc_key."
  type        = map(map(string))
  default     = {}
}

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

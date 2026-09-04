## Naming logic — derives the value used for the transit gateway's "Name" tag.
## Like aws_vpc, none of the aws_ec2_transit_gateway* resources have a
## `name` argument of their own - they're identified only by ID, with
## "Name" a convention enforced purely via tags. So the restriction that
## applies is the generic AWS tag-value restriction (see
## naming-rules.md's procedure): max 256 Unicode characters, charset
## limited to letters, digits, spaces, and `. : + = @ _ / -`. No
## global-uniqueness requirement and no begin/end constraint, so - same as
## the terraform-aws-caf-vpc module's name.tf - no sha1 uniqueness suffix
## and no trim-after-truncate step are needed; a plain substr truncation
## is sufficient.
## `var.transit_gateway.name`, when set, overrides the auto-derived
## "env-userDefinedString" name below - still sanitized against the same
## tag-value charset and truncated to the same 256-char limit, so an
## explicit custom name can never violate the restriction the auto-derived
## name is built to respect.
locals {
  tgw-name-tag-regex = "/[^0-9A-Za-z .:+=@_\\/-]/" # AWS tag-value charset
  env-compliant      = replace(var.env, local.tgw-name-tag-regex, "")
  name-compliant     = replace(var.userDefinedString, local.tgw-name-tag-regex, "")
  # 256 = AWS's max tag *value* length, applied after assembling env + userDefinedString.
  tgw-name-auto   = substr("${local.env-compliant}-${local.name-compliant}", 0, 256)
  tgw-name-custom = try(var.transit_gateway.name, null)
  tgw-name        = local.tgw-name-custom != null ? substr(replace(local.tgw-name-custom, local.tgw-name-tag-regex, ""), 0, 256) : local.tgw-name-auto
}

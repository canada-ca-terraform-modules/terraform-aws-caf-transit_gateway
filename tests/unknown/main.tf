# Test-only wrapper: VPC ids are unknown at plan time, like a not-yet-created VPC.
resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "this" {
  vpc_id     = aws_vpc.this.id
  cidr_block = "10.0.1.0/24"
}

module "tgw" {
  source = "../.."

  env               = "Dev"
  userDefinedString = "myapp"

  transit_gateway = {
    vpc_attachments = {
      spoke_a = {
        vpc_id     = aws_vpc.this.id
        subnet_ids = [aws_subnet.this.id]
      }
    }
  }
}

output "attachment_keys" {
  value = keys(module.tgw.vpc_attachment_ids)
}

# Same, but the IDs reach the module through vpc_ids/subnet_ids and are resolved by vpc_key/subnet_keys.
module "tgw_keyed" {
  source = "../.."

  env               = "Dev"
  userDefinedString = "keyed"

  vpc_ids    = { core = aws_vpc.this.id }
  subnet_ids = { core = { tgw-1a = aws_subnet.this.id } }

  transit_gateway = {
    vpc_attachments = {
      spoke_a = { vpc_key = "core", subnet_keys = ["tgw-1a"] }
    }
  }
}

output "keyed_attachment_keys" {
  value = keys(module.tgw_keyed.vpc_attachment_ids)
}

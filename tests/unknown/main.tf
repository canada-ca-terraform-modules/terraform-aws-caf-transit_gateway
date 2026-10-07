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

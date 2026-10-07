mock_provider "aws" {}

# ---------------------------------------------------------------------------
# Shared variables reused across all runs
# ---------------------------------------------------------------------------
variables {
  env               = "Dev"
  userDefinedString = "myapp"
  tags              = { environment = "test" }
  transit_gateway   = {}
}

# ---------------------------------------------------------------------------
# naming_convention
# ---------------------------------------------------------------------------
run "naming_convention" {
  command = plan

  assert {
    condition     = aws_ec2_transit_gateway.this.tags["Name"] == "Dev-myapp"
    error_message = "Name tag must be derived from env-userDefinedString"
  }
  assert {
    condition     = length(aws_ec2_transit_gateway.this.tags["Name"]) <= 256
    error_message = "Name tag must not exceed the AWS tag-value limit of 256 characters"
  }
  assert {
    condition     = can(regex("^[0-9A-Za-z .:+=@_/-]+$", aws_ec2_transit_gateway.this.tags["Name"]))
    error_message = "Name tag must only contain characters AWS allows in a tag value"
  }
}

# ---------------------------------------------------------------------------
# naming_convention_truncation_edge_case
# ---------------------------------------------------------------------------
run "naming_convention_truncation_edge_case" {
  command = plan

  variables {
    env               = "-prod"
    userDefinedString = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  }

  assert {
    condition     = length(aws_ec2_transit_gateway.this.tags["Name"]) <= 256
    error_message = "Name tag must not exceed 256 characters even after truncation"
  }
}

# ---------------------------------------------------------------------------
# naming_strips_disallowed_characters
# ---------------------------------------------------------------------------
run "naming_strips_disallowed_characters" {
  command = plan

  variables {
    env               = "Dev!"
    userDefinedString = "my#app"
  }

  assert {
    condition     = aws_ec2_transit_gateway.this.tags["Name"] == "Dev-myapp"
    error_message = "Characters outside the AWS tag-value charset must be stripped"
  }
}

# ---------------------------------------------------------------------------
# naming_custom_name_override
# ---------------------------------------------------------------------------
run "naming_custom_name_override" {
  command = plan

  variables {
    transit_gateway = {
      name = "My#Custom Name!"
    }
  }

  assert {
    condition     = aws_ec2_transit_gateway.this.tags["Name"] == "MyCustom Name"
    error_message = "transit_gateway.name must override the auto-derived name, sanitized against the AWS tag-value charset"
  }
}

# ---------------------------------------------------------------------------
# default_values
# ---------------------------------------------------------------------------
run "default_values" {
  command = plan

  assert {
    condition     = aws_ec2_transit_gateway.this.description == null
    error_message = "description must default to null"
  }
  assert {
    condition     = aws_ec2_transit_gateway.this.amazon_side_asn == null
    error_message = "amazon_side_asn must default to null (AWS default applies)"
  }
}

# ---------------------------------------------------------------------------
# tags_are_merged_with_module_tag
# ---------------------------------------------------------------------------
run "tags_are_merged_with_module_tag" {
  command = plan

  variables {
    transit_gateway = {
      tags = { owner = "team-x" }
    }
  }

  assert {
    condition     = aws_ec2_transit_gateway.this.tags["environment"] == "test"
    error_message = "Caller-supplied tags must be preserved"
  }
  assert {
    condition     = aws_ec2_transit_gateway.this.tags["owner"] == "team-x"
    error_message = "transit_gateway.tags must be merged in"
  }
  assert {
    condition     = contains(keys(aws_ec2_transit_gateway.this.tags), "module")
    error_message = "module tag must be merged into tags"
  }
}

# ---------------------------------------------------------------------------
# core_transit_gateway_arguments
# ---------------------------------------------------------------------------
run "core_transit_gateway_arguments" {
  command = plan

  variables {
    transit_gateway = {
      description                     = "hub-and-spoke core network"
      amazon_side_asn                 = 64512
      auto_accept_shared_attachments  = "enable"
      default_route_table_association = "disable"
      default_route_table_propagation = "disable"
      dns_support                     = "enable"
      vpn_ecmp_support                = "enable"
      transit_gateway_cidr_blocks     = ["10.99.0.0/24"]
    }
  }

  assert {
    condition     = aws_ec2_transit_gateway.this.amazon_side_asn == 64512
    error_message = "amazon_side_asn must be passed through"
  }
  assert {
    condition     = aws_ec2_transit_gateway.this.default_route_table_association == "disable"
    error_message = "default_route_table_association must be passed through"
  }
}

# ---------------------------------------------------------------------------
# optional_features_absent_by_default
# One assert per optional resource family - every for_each-gated resource
# must have length() == 0 with an empty object variable.
# ---------------------------------------------------------------------------
run "optional_features_absent_by_default" {
  command = plan

  assert {
    condition     = length(aws_ec2_transit_gateway_vpc_attachment.this) == 0
    error_message = "vpc_attachments must not be created by default"
  }
  assert {
    condition     = length(aws_ec2_transit_gateway_vpc_attachment_accepter.this) == 0
    error_message = "vpc_attachment_accepters must not be created by default"
  }
  assert {
    condition     = length(aws_ec2_transit_gateway_peering_attachment.this) == 0
    error_message = "peering_attachments must not be created by default"
  }
  assert {
    condition     = length(aws_ec2_transit_gateway_peering_attachment_accepter.this) == 0
    error_message = "peering_attachment_accepters must not be created by default"
  }
  assert {
    condition     = length(aws_ec2_transit_gateway_connect.this) == 0
    error_message = "connect_attachments must not be created by default"
  }
  assert {
    condition     = length(aws_ec2_transit_gateway_connect_peer.this) == 0
    error_message = "connect_peers must not be created by default"
  }
  assert {
    condition     = length(aws_ec2_transit_gateway_route_table.this) == 0
    error_message = "route_tables must not be created by default"
  }
  assert {
    condition     = length(aws_ec2_transit_gateway_route_table_association.this) == 0
    error_message = "route_table_associations must not be created by default"
  }
  assert {
    condition     = length(aws_ec2_transit_gateway_route_table_propagation.this) == 0
    error_message = "route_table_propagations must not be created by default"
  }
  assert {
    condition     = length(aws_ec2_transit_gateway_route.this) == 0
    error_message = "routes must not be created by default"
  }
  assert {
    condition     = length(aws_ec2_transit_gateway_prefix_list_reference.this) == 0
    error_message = "prefix_list_references must not be created by default"
  }
  assert {
    condition     = length(aws_ec2_transit_gateway_default_route_table_association.this) == 0
    error_message = "default_route_table_associations must not be created by default"
  }
  assert {
    condition     = length(aws_ec2_transit_gateway_default_route_table_propagation.this) == 0
    error_message = "default_route_table_propagations must not be created by default"
  }
  assert {
    condition     = length(aws_ec2_transit_gateway_policy_table.this) == 0
    error_message = "policy_tables must not be created by default"
  }
  assert {
    condition     = length(aws_ec2_transit_gateway_policy_table_association.this) == 0
    error_message = "policy_table_associations must not be created by default"
  }
  assert {
    condition     = length(aws_ec2_transit_gateway_multicast_domain.this) == 0
    error_message = "multicast_domains must not be created by default"
  }
  assert {
    condition     = length(aws_ec2_transit_gateway_multicast_domain_association.this) == 0
    error_message = "multicast_domain_associations must not be created by default"
  }
  assert {
    condition     = length(aws_ec2_transit_gateway_multicast_group_member.this) == 0
    error_message = "multicast_group_members must not be created by default"
  }
  assert {
    condition     = length(aws_ec2_transit_gateway_multicast_group_source.this) == 0
    error_message = "multicast_group_sources must not be created by default"
  }
  assert {
    condition     = length(aws_ec2_transit_gateway_metering_policy.this) == 0
    error_message = "metering_policies must not be created by default"
  }
  assert {
    condition     = length(aws_ec2_transit_gateway_metering_policy_entry.this) == 0
    error_message = "metering_policy_entries must not be created by default"
  }
}

# ---------------------------------------------------------------------------
# vpc_attachments
# The core "connect a VPC to another VPC" feature: two VPCs attached to the
# same hub, with the second attached in a peer account.
# ---------------------------------------------------------------------------
run "vpc_attachments" {
  command = plan

  variables {
    transit_gateway = {
      vpc_attachments = {
        spoke_a = {
          vpc_id     = "vpc-0123456789abcdef0"
          subnet_ids = ["subnet-0123456789abcdef0"]
        }
      }
      vpc_attachment_accepters = {
        spoke_b = {
          transit_gateway_attachment_id = "tgw-attach-0fedcba9876543210"
        }
      }
    }
  }

  assert {
    condition     = length(aws_ec2_transit_gateway_vpc_attachment.this) == 1
    error_message = "one aws_ec2_transit_gateway_vpc_attachment must be created per entry"
  }
  assert {
    condition     = aws_ec2_transit_gateway_vpc_attachment.this["spoke_a"].vpc_id == "vpc-0123456789abcdef0"
    error_message = "vpc_id must be passed through"
  }
  assert {
    condition     = length(aws_ec2_transit_gateway_vpc_attachment_accepter.this) == 1
    error_message = "one aws_ec2_transit_gateway_vpc_attachment_accepter must be created per entry"
  }
}

# ---------------------------------------------------------------------------
# peering_attachments
# ---------------------------------------------------------------------------
run "peering_attachments" {
  command = plan

  variables {
    transit_gateway = {
      peering_attachments = {
        to-other-region = {
          peer_transit_gateway_id = "tgw-0fedcba9876543210"
          peer_region             = "ca-central-1"
        }
      }
      peering_attachment_accepters = {
        from-other-account = {
          transit_gateway_attachment_id = "tgw-attach-0aaaaaaaaaaaaaaaa"
        }
      }
    }
  }

  assert {
    condition     = length(aws_ec2_transit_gateway_peering_attachment.this) == 1
    error_message = "one aws_ec2_transit_gateway_peering_attachment must be created per entry"
  }
  assert {
    condition     = length(aws_ec2_transit_gateway_peering_attachment_accepter.this) == 1
    error_message = "one aws_ec2_transit_gateway_peering_attachment_accepter must be created per entry"
  }
}

# ---------------------------------------------------------------------------
# connect_attachments_and_peers
# ---------------------------------------------------------------------------
run "connect_attachments_and_peers" {
  command = apply

  variables {
    transit_gateway = {
      connect_attachments = {
        sdwan = {
          transport_attachment_id = "tgw-attach-0123456789abcdef0"
        }
      }
      connect_peers = {
        sdwan-peer = {
          connect_attachment_key = "sdwan"
          peer_address           = "10.0.0.1"
          inside_cidr_blocks     = ["169.254.100.0/29"]
        }
      }
    }
  }

  assert {
    condition     = length(aws_ec2_transit_gateway_connect.this) == 1
    error_message = "one aws_ec2_transit_gateway_connect must be created per entry"
  }
  assert {
    condition     = length(aws_ec2_transit_gateway_connect_peer.this) == 1
    error_message = "one aws_ec2_transit_gateway_connect_peer must be created per entry"
  }
  assert {
    condition     = aws_ec2_transit_gateway_connect_peer.this["sdwan-peer"].transit_gateway_attachment_id == aws_ec2_transit_gateway_connect.this["sdwan"].id
    error_message = "connect_attachment_key must resolve to the matching aws_ec2_transit_gateway_connect id"
  }
}

# ---------------------------------------------------------------------------
# route_tables_associations_propagations_and_routes
# Covers segmented routing: a custom route table, an attachment associated
# to it (routed FROM), an attachment propagated into it (routed learned
# routes INTO it), a static route, a blackhole route, and a prefix list
# reference.
# ---------------------------------------------------------------------------
run "route_tables_associations_propagations_and_routes" {
  command = apply

  variables {
    transit_gateway = {
      vpc_attachments = {
        spoke_a = {
          vpc_id     = "vpc-0123456789abcdef0"
          subnet_ids = ["subnet-0123456789abcdef0"]
        }
        spoke_b = {
          vpc_id     = "vpc-0fedcba9876543210"
          subnet_ids = ["subnet-0fedcba9876543210"]
        }
      }
      route_tables = {
        segment_a = {}
      }
      route_table_associations = {
        spoke_a_assoc = {
          attachment_key  = "spoke_a"
          route_table_key = "segment_a"
        }
      }
      route_table_propagations = {
        spoke_b_prop = {
          attachment_key  = "spoke_b"
          route_table_key = "segment_a"
        }
      }
      routes = {
        to_spoke_b = {
          route_table_key        = "segment_a"
          destination_cidr_block = "10.1.0.0/16"
          attachment_key         = "spoke_b"
        }
        drop_martians = {
          route_table_key        = "segment_a"
          destination_cidr_block = "0.0.0.0/0"
          blackhole              = true
        }
      }
      prefix_list_references = {
        shared_services = {
          route_table_key = "segment_a"
          prefix_list_id  = "pl-0123456789abcdef0"
          attachment_key  = "spoke_a"
        }
      }
      default_route_table_associations = {
        main = {
          route_table_key = "segment_a"
        }
      }
      default_route_table_propagations = {
        main = {
          route_table_key = "segment_a"
        }
      }
    }
  }

  assert {
    condition     = length(aws_ec2_transit_gateway_route_table.this) == 1
    error_message = "one aws_ec2_transit_gateway_route_table must be created per entry"
  }
  assert {
    condition     = aws_ec2_transit_gateway_route_table_association.this["spoke_a_assoc"].transit_gateway_attachment_id == aws_ec2_transit_gateway_vpc_attachment.this["spoke_a"].id
    error_message = "attachment_key must resolve to the matching vpc attachment id"
  }
  assert {
    condition     = aws_ec2_transit_gateway_route_table_propagation.this["spoke_b_prop"].transit_gateway_attachment_id == aws_ec2_transit_gateway_vpc_attachment.this["spoke_b"].id
    error_message = "attachment_key must resolve to the matching vpc attachment id"
  }
  assert {
    condition     = aws_ec2_transit_gateway_route.this["to_spoke_b"].destination_cidr_block == "10.1.0.0/16"
    error_message = "destination_cidr_block must be passed through"
  }
  assert {
    condition     = aws_ec2_transit_gateway_route.this["drop_martians"].blackhole == true
    error_message = "blackhole routes must not require an attachment"
  }
  assert {
    condition     = length(aws_ec2_transit_gateway_prefix_list_reference.this) == 1
    error_message = "one aws_ec2_transit_gateway_prefix_list_reference must be created per entry"
  }
  assert {
    condition     = length(aws_ec2_transit_gateway_default_route_table_association.this) == 1
    error_message = "one aws_ec2_transit_gateway_default_route_table_association must be created per entry"
  }
  assert {
    condition     = length(aws_ec2_transit_gateway_default_route_table_propagation.this) == 1
    error_message = "one aws_ec2_transit_gateway_default_route_table_propagation must be created per entry"
  }
}

# ---------------------------------------------------------------------------
# policy_tables
# ---------------------------------------------------------------------------
run "policy_tables" {
  command = apply

  variables {
    transit_gateway = {
      vpc_attachments = {
        spoke_a = {
          vpc_id     = "vpc-0123456789abcdef0"
          subnet_ids = ["subnet-0123456789abcdef0"]
        }
      }
      policy_tables = {
        main = {}
      }
      policy_table_associations = {
        spoke_a_policy = {
          attachment_key   = "spoke_a"
          policy_table_key = "main"
        }
      }
    }
  }

  assert {
    condition     = length(aws_ec2_transit_gateway_policy_table.this) == 1
    error_message = "one aws_ec2_transit_gateway_policy_table must be created per entry"
  }
  assert {
    condition     = aws_ec2_transit_gateway_policy_table_association.this["spoke_a_policy"].transit_gateway_attachment_id == aws_ec2_transit_gateway_vpc_attachment.this["spoke_a"].id
    error_message = "attachment_key must resolve to the matching vpc attachment id"
  }
}

# ---------------------------------------------------------------------------
# multicast
# ---------------------------------------------------------------------------
run "multicast" {
  command = apply

  variables {
    transit_gateway = {
      multicast_support = "enable"
      vpc_attachments = {
        spoke_a = {
          vpc_id     = "vpc-0123456789abcdef0"
          subnet_ids = ["subnet-0123456789abcdef0"]
        }
      }
      multicast_domains = {
        main = {}
      }
      multicast_domain_associations = {
        spoke_a_mcast = {
          multicast_domain_key = "main"
          attachment_key       = "spoke_a"
          subnet_id            = "subnet-0123456789abcdef0"
        }
      }
      multicast_group_members = {
        receiver1 = {
          multicast_domain_key = "main"
          network_interface_id = "eni-0123456789abcdef0"
          group_ip_address     = "224.0.0.1"
        }
      }
      multicast_group_sources = {
        sender1 = {
          multicast_domain_key = "main"
          network_interface_id = "eni-0fedcba9876543210"
          group_ip_address     = "224.0.0.1"
        }
      }
    }
  }

  assert {
    condition     = length(aws_ec2_transit_gateway_multicast_domain.this) == 1
    error_message = "one aws_ec2_transit_gateway_multicast_domain must be created per entry"
  }
  assert {
    condition     = aws_ec2_transit_gateway_multicast_domain_association.this["spoke_a_mcast"].transit_gateway_multicast_domain_id == aws_ec2_transit_gateway_multicast_domain.this["main"].id
    error_message = "multicast_domain_key must resolve to the matching multicast domain id"
  }
  assert {
    condition     = length(aws_ec2_transit_gateway_multicast_group_member.this) == 1
    error_message = "one aws_ec2_transit_gateway_multicast_group_member must be created per entry"
  }
  assert {
    condition     = length(aws_ec2_transit_gateway_multicast_group_source.this) == 1
    error_message = "one aws_ec2_transit_gateway_multicast_group_source must be created per entry"
  }
}

# ---------------------------------------------------------------------------
# metering_policies
# ---------------------------------------------------------------------------
run "metering_policies" {
  command = apply

  variables {
    transit_gateway = {
      metering_policies = {
        main = {
          middlebox_attachment_ids = ["tgw-attach-0123456789abcdef0"]
        }
      }
      metering_policy_entries = {
        rule1 = {
          metering_policy_key = "main"
          policy_rule_number  = 1
          metered_account     = "source-attachment-owner"
        }
      }
    }
  }

  assert {
    condition     = length(aws_ec2_transit_gateway_metering_policy.this) == 1
    error_message = "one aws_ec2_transit_gateway_metering_policy must be created per entry"
  }
  assert {
    condition     = aws_ec2_transit_gateway_metering_policy_entry.this["rule1"].transit_gateway_metering_policy_id == aws_ec2_transit_gateway_metering_policy.this["main"].transit_gateway_metering_policy_id
    error_message = "metering_policy_key must resolve to the matching metering policy id"
  }
}

# ---------------------------------------------------------------------------
# unknown_values_at_plan
# Regression: attachments whose vpc_id/subnet_ids are not known until apply
# (VPC created in the same configuration) must still plan - for_each keys are
# static, only the values are unknown.
# ---------------------------------------------------------------------------
run "unknown_values_at_plan" {
  command = plan

  module {
    source = "./tests/unknown"
  }

  assert {
    condition     = length(output.attachment_keys) == 1
    error_message = "vpc_attachments with apply-time values must still produce one instance per static key"
  }
}

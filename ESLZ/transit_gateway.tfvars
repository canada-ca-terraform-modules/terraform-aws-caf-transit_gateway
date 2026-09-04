transit_gateways = {
  hub01 = { # Key defines the userDefinedString
    description     = "Core hub connecting spoke VPCs"
    amazon_side_asn = 64512
    # auto_accept_shared_attachments  = "enable"  # Optional: auto-accept attachments shared via RAM
    # default_route_table_association = "disable" # Optional: stop new attachments auto-joining the built-in default route table
    # default_route_table_propagation = "disable" # Optional: stop attachments auto-propagating into the built-in default route table
    # dns_support                     = "enable"
    # vpn_ecmp_support                = "enable"
    # transit_gateway_cidr_blocks     = ["10.99.0.0/24"] # Optional: for Connect/appliance attachments needing a transit-gateway-owned CIDR
    # multicast_support               = "enable" # Optional: required before adding multicast_domains below

    # --- vpc_attachments: connects a VPC to this hub (the "connect a VPC to another VPC" feature) ---
    vpc_attachments = {
      spoke_a = {
        vpc_key = "spoke-a" # Optional: config-name from terraform-aws-caf-vpc's ESLZ variable, resolved via ESLZ/transit_gateway.tf's vpc_ids
        # vpc_id    = "vpc-0123456789abcdef0" # Optional: literal VPC ID instead of vpc_key
        subnet_keys = ["spoke-a-subnet1"] # Optional: config-name(s) from terraform-aws-caf-subnet's ESLZ variable, resolved via subnet_ids
        # subnet_ids = ["subnet-0123456789abcdef0"] # Optional: literal subnet ID(s) instead of subnet_keys
        # appliance_mode_support                          = "enable"
        # dns_support                                     = "enable"
        # ipv6_support                                    = "enable"
        # transit_gateway_default_route_table_association = true
        # transit_gateway_default_route_table_propagation  = true
      }
      # spoke_b = { vpc_key = "spoke-b", subnet_keys = ["spoke-b-subnet1"] }
    }

    # --- vpc_attachment_accepters: accept a cross-account VPC attachment shared to this account ---
    # vpc_attachment_accepters = {
    #   shared_from_other_account = { transit_gateway_attachment_id = "tgw-attach-0fedcba9876543210" }
    # }

    # --- peering_attachments/peering_attachment_accepters: connects this hub to another region/account's hub ---
    # peering_attachments = {
    #   to-other-region = { peer_transit_gateway_id = "tgw-0fedcba9876543210", peer_region = "ca-central-1" }
    # }
    # peering_attachment_accepters = {
    #   from-other-account = { transit_gateway_attachment_id = "tgw-attach-0aaaaaaaaaaaaaaaa" }
    # }

    # --- connect_attachments/connect_peers: GRE-based SD-WAN appliance attachments ---
    # connect_attachments = {
    #   sdwan = { transport_attachment_id = "tgw-attach-0123456789abcdef0" }
    # }
    # connect_peers = {
    #   sdwan-peer = { connect_attachment_key = "sdwan", peer_address = "10.0.0.1", inside_cidr_blocks = ["169.254.100.0/29"] }
    # }

    # --- route_tables/route_table_associations/route_table_propagations/routes/prefix_list_references: segmented routing ---
    # route_tables = {
    #   segment_a = {}
    # }
    # route_table_associations = {
    #   spoke_a_assoc = { attachment_key = "spoke_a", route_table_key = "segment_a" } # which table an attachment routes FROM
    # }
    # route_table_propagations = {
    #   spoke_b_prop = { attachment_key = "spoke_b", route_table_key = "segment_a" } # propagates an attachment's routes INTO a table
    # }
    # routes = {
    #   to_spoke_b    = { route_table_key = "segment_a", destination_cidr_block = "10.1.0.0/16", attachment_key = "spoke_b" }
    #   drop_martians = { route_table_key = "segment_a", destination_cidr_block = "0.0.0.0/0", blackhole = true }
    # }
    # prefix_list_references = {
    #   shared_services = { route_table_key = "segment_a", prefix_list_id = "pl-0123456789abcdef0", attachment_key = "spoke_a" }
    # }
    # default_route_table_associations = {
    #   main = { route_table_key = "segment_a" } # points the hub's built-in default association table at segment_a instead
    # }
    # default_route_table_propagations = {
    #   main = { route_table_key = "segment_a" }
    # }

    # --- policy_tables/policy_table_associations: attribute-based routing (alternative to route tables) ---
    # policy_tables = {
    #   main = {}
    # }
    # policy_table_associations = {
    #   spoke_a_policy = { attachment_key = "spoke_a", policy_table_key = "main" }
    # }

    # --- multicast_domains/multicast_domain_associations/multicast_group_members/multicast_group_sources ---
    # multicast_domains = {
    #   main = {}
    # }
    # multicast_domain_associations = {
    #   spoke_a_mcast = { multicast_domain_key = "main", attachment_key = "spoke_a", subnet_id = "subnet-0123456789abcdef0" }
    # }
    # multicast_group_members = {
    #   receiver1 = { multicast_domain_key = "main", network_interface_id = "eni-0123456789abcdef0", group_ip_address = "224.0.0.1" }
    # }
    # multicast_group_sources = {
    #   sender1 = { multicast_domain_key = "main", network_interface_id = "eni-0fedcba9876543210", group_ip_address = "224.0.0.1" }
    # }

    # --- metering_policies/metering_policy_entries: cost-allocation for middlebox (e.g. firewall appliance) attachments ---
    # metering_policies = {
    #   main = { middlebox_attachment_ids = ["tgw-attach-0123456789abcdef0"] }
    # }
    # metering_policy_entries = {
    #   rule1 = { metering_policy_key = "main", policy_rule_number = 1, metered_account = "source-attachment-owner" }
    # }
  }
}

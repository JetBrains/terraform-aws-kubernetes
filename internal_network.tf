locals {
  network_prefix_name = var.prefix
  az_number           = try(coalesce(var.cluster_network_internal_vpc_availability_zones_number, 2), 2)
  public_subnets = {
    tags = {
      "Purpose"                = "Kubernetes Internet facing traffic address pool"
      "kubernetes.io/role/elb" = 1
    }
  }
  private_subnets = {
    tags = {
      "Purpose"                = "Kubernetes internal traffic address pool"
      "karpenter.sh/discovery" = try(var.cluster_autoscaler_subnet_selector, var.prefix)
    }
  }
  intranet_subnets = {
    tags = {
      "Purpose"                         = "Kubernetes intranet traffic address pool"
      "kubernetes.io/role/internal-elb" = 1
    }
  }
  data_subnets = {
    tags = {
      "Purpose" = "Kubernetes intranet traffic address pool for stateful services"
    }
  }
  nat_gateway_type = {
    single_nat_gateway = {
      enable_nat_gateway     = true
      single_nat_gateway     = true
      one_nat_gateway_per_az = false
    },
    one_nat_gateway_per_subnet = {
      enable_nat_gateway     = true
      single_nat_gateway     = false
      one_nat_gateway_per_az = false
    },
    one_nat_gateway_per_az = {
      enable_nat_gateway     = true
      single_nat_gateway     = false
      one_nat_gateway_per_az = true
    }
  }
}

module "internal_network" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.18.1"

  create_vpc            = var.cluster_network_type == "internal"
  name                  = local.network_prefix_name
  cidr                  = try(coalesce(var.cluster_network_internal_vpc_cidr, "10.0.0.0/16"), "10.0.0.0/16")
  secondary_cidr_blocks = try(coalesce(var.cluster_network_internal_vpc_secondary_cidr_blocks, []), [])
  instance_tenancy      = try(coalesce(var.cluster_network_internal_vpc_instance_tenancy, "default"), "default")

  azs = slice(data.aws_availability_zones.available.names, 0, local.az_number)

  enable_dns_hostnames                 = try(coalesce(var.cluster_network_internal_vpc_enable_dns_hostnames, true), true)
  enable_dns_support                   = try(coalesce(var.cluster_network_internal_vpc_enable_dns_support, true), true)
  enable_network_address_usage_metrics = try(coalesce(var.cluster_network_internal_vpc_enable_network_address_usage_metrics, false), false)
  use_ipam_pool                        = try(coalesce(var.cluster_network_internal_vpc_ipam_pool_options.enabled, false), false)
  ipv4_ipam_pool_id                    = try(coalesce(var.cluster_network_internal_vpc_ipam_pool_options.ipv4_pool_id, null), null)
  ipv4_netmask_length                  = try(coalesce(var.cluster_network_internal_vpc_ipam_pool_options.ipv4_netmask_length, null), null)
  enable_ipv6                          = try(coalesce(var.cluster_network_internal_vpc_ipam_pool_options.enable_ipv6, false), false)
  ipv6_cidr                            = try(coalesce(var.cluster_network_internal_vpc_ipam_pool_options.ipv6_cidr, null), null)
  ipv6_ipam_pool_id                    = try(coalesce(var.cluster_network_internal_vpc_ipam_pool_options.ipv6_pool_id, null), null)
  ipv6_netmask_length                  = try(coalesce(var.cluster_network_internal_vpc_ipam_pool_options.ipv6_netmask_length, null), null)
  ipv6_cidr_block_network_border_group = try(coalesce(var.cluster_network_internal_vpc_ipam_pool_options.ipv6_cidr_block_network_border_group, null), null)
  enable_dhcp_options                  = try(coalesce(var.cluster_network_internal_vpc_dhcp_options.enabled, false), false)
  dhcp_options_domain_name             = try(coalesce(var.cluster_network_internal_vpc_dhcp_options.domain_name, ""), "")
  dhcp_options_domain_name_servers     = try(coalesce(var.cluster_network_internal_vpc_dhcp_options.domain_name_servers, ["AmazonProvidedDNS"]), ["AmazonProvidedDNS"])
  dhcp_options_ntp_servers             = try(coalesce(var.cluster_network_internal_vpc_dhcp_options.ntp_servers, []), [])
  dhcp_options_netbios_name_servers    = try(coalesce(var.cluster_network_internal_vpc_dhcp_options.netbios_name_servers, []), [])
  dhcp_options_netbios_node_type       = try(coalesce(var.cluster_network_internal_vpc_dhcp_options.netbios_node_type, ""), "")
  dhcp_options_tags                    = try(coalesce(var.cluster_network_internal_vpc_dhcp_options.tags, {}), {})
  vpc_tags                             = try(coalesce(var.cluster_network_internal_vpc_tags, {}), {})

  public_subnets                                               = try(slice(coalesce(var.cluster_network_internal_public_ingress_subnets_subnets_addresses, []), 0, local.az_number), [])
  public_subnet_assign_ipv6_address_on_creation                = try(coalesce(var.cluster_network_internal_public_ingress_subnets_subnets_assign_ipv6_address_on_creation, false), false)
  public_subnet_enable_dns64                                   = try(coalesce(var.cluster_network_internal_public_ingress_subnets_subnets_enable_dns64, true), true)
  public_subnet_enable_resource_name_dns_aaaa_record_on_launch = try(coalesce(var.cluster_network_internal_public_ingress_subnets_subnets_enable_resource_name_dns_aaaa_record_on_launch, true), true)
  public_subnet_enable_resource_name_dns_a_record_on_launch    = try(coalesce(var.cluster_network_internal_public_ingress_subnets_subnets_enable_resource_name_dns_a_record_on_launch, false), false)
  public_subnet_ipv6_prefixes                                  = try(coalesce(var.cluster_network_internal_public_ingress_subnets_subnets_ipv6_prefixes, []), [])
  public_subnet_ipv6_native                                    = try(coalesce(var.cluster_network_internal_public_ingress_subnets_subnets_ipv6_native, false), false)
  map_public_ip_on_launch                                      = try(coalesce(var.cluster_network_internal_public_ingress_subnets_subnets_map_public_ip_on_launch, false), false)
  public_subnet_private_dns_hostname_type_on_launch            = try(coalesce(var.cluster_network_internal_public_ingress_subnets_subnets_private_dns_hostname_type_on_launch, null), null)
  public_subnet_tags                                           = try(merge(local.public_subnets.tags, var.cluster_network_internal_public_ingress_subnets_subnets_tags.tags), local.public_subnets.tags)
  public_route_table_tags                                      = try(coalesce(var.cluster_network_internal_public_ingress_subnets_subnets_tags.route_table_tags, {}), {})
  public_subnet_tags_per_az                                    = try(coalesce(var.cluster_network_internal_public_ingress_subnets_subnets_tags.subnet_tags_per_az, {}), {})
  public_dedicated_network_acl                                 = try(coalesce(var.cluster_network_internal_public_ingress_subnets_subnets_acls.enabled, false), false)
  public_inbound_acl_rules = try(coalesce(var.cluster_network_internal_public_ingress_subnets_subnets_acls.inbound_rules, [{
    rule_number = 100
    rule_action = "allow"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_block  = "0.0.0.0/0"
  }]), [])
  public_outbound_acl_rules = try(coalesce(var.cluster_network_internal_public_ingress_subnets_subnets_acls.outbound_rules, [{
    rule_number = 100
    rule_action = "allow"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_block  = "0.0.0.0/0"
  }]), [])
  public_acl_tags = try(coalesce(var.cluster_network_internal_public_ingress_subnets_subnets_tags.acl_tags, {}), {})

  private_subnets                                               = try(slice(coalesce(var.cluster_network_internal_vpc_node_subnets_addresses, []), 0, local.az_number), [])
  private_subnet_assign_ipv6_address_on_creation                = try(coalesce(var.cluster_network_internal_vpc_node_subnets_assign_ipv6_address_on_creation, false), false)
  private_subnet_enable_dns64                                   = try(coalesce(var.cluster_network_internal_vpc_node_subnets_enable_dns64, true), true)
  private_subnet_enable_resource_name_dns_aaaa_record_on_launch = try(coalesce(var.cluster_network_internal_vpc_node_subnets_enable_resource_name_dns_aaaa_record_on_launch, true), true)
  private_subnet_enable_resource_name_dns_a_record_on_launch    = try(coalesce(var.cluster_network_internal_vpc_node_subnets_enable_resource_name_dns_a_record_on_launch, false), false)
  private_subnet_ipv6_prefixes                                  = try(coalesce(var.cluster_network_internal_vpc_node_subnets_ipv6_prefixes, []), [])
  private_subnet_ipv6_native                                    = try(coalesce(var.cluster_network_internal_vpc_node_subnets_ipv6_native, false), false)
  private_subnet_private_dns_hostname_type_on_launch            = try(coalesce(var.cluster_network_internal_vpc_node_subnets_private_dns_hostname_type_on_launch, null), null)
  private_subnet_tags                                           = try(merge(local.private_subnets.tags, var.cluster_network_internal_vpc_node_subnets_tags.tags), local.private_subnets.tags)
  private_subnet_tags_per_az                                    = try(coalesce(var.cluster_network_internal_vpc_node_subnets_tags.subnet_tags_per_az, {}), {})
  private_route_table_tags                                      = try(coalesce(var.cluster_network_internal_vpc_node_subnets_tags.route_table_tags, {}), {})
  private_dedicated_network_acl                                 = try(coalesce(var.cluster_network_internal_vpc_node_subnets_acls.enabled, false), false)
  private_inbound_acl_rules = try(coalesce(var.cluster_network_internal_vpc_node_subnets_acls.inbound_rules, [{
    rule_number = 100
    rule_action = "allow"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_block  = "0.0.0.0/0"
  }]), [])
  private_outbound_acl_rules = try(coalesce(var.cluster_network_internal_vpc_node_subnets_acls.outbound_rules, [{
    rule_number = 100
    rule_action = "allow"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_block  = "0.0.0.0/0"
  }]), [])

  private_acl_tags = try(coalesce(var.cluster_network_internal_vpc_node_subnets_tags.acl_tags, {}), {})

  database_subnets                                               = try(slice(coalesce(var.cluster_network_internal_vpc_data_subnets_addresses, []), 0, local.az_number), [])
  database_subnet_assign_ipv6_address_on_creation                = try(coalesce(var.cluster_network_internal_vpc_data_subnets_assign_ipv6_address_on_creation, false), false)
  database_subnet_enable_dns64                                   = try(coalesce(var.cluster_network_internal_vpc_data_subnets_enable_dns64, true), true)
  database_subnet_enable_resource_name_dns_aaaa_record_on_launch = try(coalesce(var.cluster_network_internal_vpc_data_subnets_enable_resource_name_dns_aaaa_record_on_launch, false), true)
  database_subnet_enable_resource_name_dns_a_record_on_launch    = try(coalesce(var.cluster_network_internal_vpc_data_subnets_enable_resource_name_dns_a_record_on_launch, false), false)
  database_subnet_ipv6_prefixes                                  = try(coalesce(var.cluster_network_internal_vpc_data_subnets_ipv6_prefixes, []), [])
  database_subnet_ipv6_native                                    = try(coalesce(var.cluster_network_internal_vpc_data_subnets_ipv6_native, false), false)
  database_subnet_private_dns_hostname_type_on_launch            = try(coalesce(var.cluster_network_internal_vpc_data_subnets_dns_hostname_type_on_launch, null), null)
  database_subnet_tags                                           = try(merge(local.data_subnets.tags, var.cluster_network_internal_vpc_data_subnets_tags.tags), local.data_subnets.tags)
  database_dedicated_network_acl                                 = try(coalesce(var.cluster_network_internal_vpc_data_subnets_acls.enabled, false), false)
  database_inbound_acl_rules = try(coalesce(var.cluster_network_internal_vpc_data_subnets_acls.inbound_rules,
    [{
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
  }]), [])
  database_outbound_acl_rules = try(coalesce(var.cluster_network_internal_vpc_data_subnets_acls.outbound_rules,
    [{
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
  }]), [])
  database_acl_tags = try(coalesce(var.cluster_network_internal_vpc_data_subnets_tags.acls_tags, {}), {})

  intra_subnets                                               = try(slice(coalesce(var.cluster_network_internal_vpc_private_ingress_subnets_addresses, []), 0, local.az_number), [])
  intra_subnet_assign_ipv6_address_on_creation                = try(coalesce(var.cluster_network_internal_vpc_private_ingress_subnets_assign_ipv6_address_on_creation, false), false)
  intra_subnet_enable_dns64                                   = try(coalesce(var.cluster_network_internal_vpc_private_ingress_subnets_enable_dns64, true), true)
  intra_subnet_enable_resource_name_dns_aaaa_record_on_launch = try(coalesce(var.cluster_network_internal_vpc_private_ingress_subnets_enable_resource_name_dns_aaaa_record_on_launch, true), true)
  intra_subnet_enable_resource_name_dns_a_record_on_launch    = try(coalesce(var.cluster_network_internal_vpc_private_ingress_subnets_enable_resource_name_dns_a_record_on_launch, false), false)
  intra_subnet_ipv6_prefixes                                  = try(coalesce(var.cluster_network_internal_vpc_private_ingress_subnets_ipv6_prefixes, []), [])
  intra_subnet_ipv6_native                                    = try(coalesce(var.cluster_network_internal_vpc_private_ingress_subnets_ipv6_native, false), false)
  intra_subnet_private_dns_hostname_type_on_launch            = try(coalesce(var.cluster_network_internal_vpc_private_ingress_subnets_dns_hostname_type_on_launch, null), null)
  intra_subnet_tags                                           = try(merge(local.intranet_subnets.tags, var.cluster_network_internal_vpc_private_ingress_subnets_tags.tags), local.intranet_subnets.tags)
  intra_route_table_tags                                      = try(coalesce(var.cluster_network_internal_vpc_private_ingress_subnets_tags.route_table_tags, {}), {})
  intra_dedicated_network_acl                                 = try(coalesce(var.cluster_network_internal_vpc_private_ingress_subnets_acls.enabled, false), false)
  intra_inbound_acl_rules = try(coalesce(var.cluster_network_internal_vpc_private_ingress_subnets_acls.inbound_rules, [{
    rule_number = 100
    rule_action = "allow"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_block  = "0.0.0.0/0"
  }]), [])

  intra_outbound_acl_rules = try(coalesce(var.cluster_network_internal_vpc_private_ingress_subnets_acls.outbound_rules, [{
    rule_number = 100
    rule_action = "allow"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_block  = "0.0.0.0/0"
  }]), [])

  intra_acl_tags = try(coalesce(var.cluster_network_internal_vpc_private_ingress_subnets_tags.acl_tags, {}), {})

  enable_nat_gateway     = local.nat_gateway_type[try(coalesce(var.cluster_network_internal_vpc_nat_gateway_type, "one_nat_gateway_per_az"), "one_nat_gateway_per_az")].enable_nat_gateway
  single_nat_gateway     = local.nat_gateway_type[try(coalesce(var.cluster_network_internal_vpc_nat_gateway_type, "one_nat_gateway_per_az"), "one_nat_gateway_per_az")].single_nat_gateway
  one_nat_gateway_per_az = local.nat_gateway_type[try(coalesce(var.cluster_network_internal_vpc_nat_gateway_type, "one_nat_gateway_per_az"), "one_nat_gateway_per_az")].one_nat_gateway_per_az

  tags = local.tags
}

module "internal_network_vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "5.18.1"

  create             = try(var.cluster_network_type == "internal" && var.cluster_network_internal_vpc_endpoints.enabled, false)
  endpoints          = try(var.cluster_network_internal_vpc_endpoints.services, {})
  security_group_ids = try(coalesce(var.cluster_network_internal_vpc_endpoints.security_group_ids, []), [])
  vpc_id             = try(module.internal_network.vpc_id, null)
  subnet_ids         = try(module.internal_network.private_subnets, [])
  timeouts           = try(var.cluster_network_internal_vpc_endpoints.timeout_options, {})
  tags               = try(merge(var.cluster_network_internal_vpc_endpoints.tags, var.cluster_network_internal_vpc_tags), var.cluster_network_internal_vpc_tags, {})
}

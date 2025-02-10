variable "prefix" {
  type = string
  validation {
    condition     = length(var.prefix) > 0 && length(var.prefix) < 10
    error_message = "The prefix value must be between 1 and 10 characters long"
  }
  description = "The prefix to be used for all resources in this module"
  default     = "kube"
}

variable "cluster_network_type" {
  type = string
  validation {
    condition     = can(regex("^(internal|external)$", var.cluster_network_type))
    error_message = "The network_type value must be either internal or external"
  }
  description = "The type of network to create. If set to internal, a new VPC will be created. If set to external, an existing VPC will be used"
  default     = "internal"
}

variable "cluster_network_external_vpc_id" {
  type        = string
  description = "The ID of the VPC to use for the external network"
  default     = null
}

variable "cluster_network_external_control_plane_subnet_ids" {
  type        = list(string)
  description = "The IDs of the subnets to use for the control plane in the external network"
  default     = null
}

variable "cluster_network_external_node_subnet_ids" {
  type        = list(string)
  description = "The IDs of the subnets to use for the nodes in the external network"
  default     = null
}

variable "cluster_network_internal_vpc_cidr" {
  type        = string
  description = "The CIDR block to use for the internal VPC"
  validation {
    condition     = can(regex("^(([0-9]|[1-2][0-9]|3[0-2])\\.){3}([0-9]|[1-2][0-9]|3[0-2])(\\/([0-9]|[1-2][0-9]|3[0-2]))?$", var.cluster_network_internal_vpc_cidr))
    error_message = "The vpc_cidr value must be a valid CIDR block"
  }
  default = "10.0.0.0/16"
}

variable "cluster_network_internal_vpc_secondary_cidr_blocks" {
  type        = list(string)
  description = "The secondary CIDR blocks to use for the internal VPC"
  default     = []
}

variable "cluster_network_internal_vpc_nat_gateway_type" {
  type = string
  validation {
    condition     = can(regex("^(single_nat_gateway|one_nat_gateway_per_subnet|one_nat_gateway_per_az)$", var.cluster_network_internal_vpc_nat_gateway_type))
    error_message = "The vpc_nat_gateway_type value must be either single_nat_gateway, one_nat_gateway_per_subnet or one_nat_gateway_per_az"
  }
  description = "The type of NAT gateway to use for the internal VPC"
  default     = "one_nat_gateway_per_az"
}

variable "cluster_network_internal_vpc_availability_zones_number" {
  type = number
  validation {
    condition     = can(regex("^[1-3]$", var.cluster_network_internal_vpc_availability_zones_number))
    error_message = "The vpc_availability_zones_number value must be a number between 1 and 5"
  }
  description = "The number of availability zones to use for the internal VPC"
  default     = 2
}

variable "cluster_network_internal_vpc_instance_tenancy" {
  type = string
  validation {
    condition     = can(regex("^(default|dedicated)$", var.cluster_network_internal_vpc_instance_tenancy))
    error_message = "The vpc_instance_tenancy value must be either default or dedicated"
  }
  description = "The instance tenancy to use for the internal VPC"
  default     = "default"
}

variable "cluster_network_internal_vpc_enable_dns_hostnames" {
  type        = bool
  description = "Whether to enable DNS hostnames for the internal VPC"
  default     = true
}

variable "cluster_network_internal_vpc_enable_dns_support" {
  type        = bool
  description = "Whether to enable DNS support for the internal VPC"
  default     = true
}

variable "cluster_network_internal_vpc_enable_network_address_usage_metrics" {
  type        = bool
  description = "Whether to enable network address usage metrics for the internal VPC"
  default     = false
}

variable "cluster_network_internal_vpc_ipam_pool_options" {
  type = object({
    enabled                              = bool
    ipv4_pool_id                         = string
    ipv4_netmask_length                  = number
    enable_ipv6                          = optional(bool)
    ipv6_cidr                            = optional(string)
    ipv6_pool_id                         = optional(string)
    ipv6_netmask_length                  = optional(number)
    ipv6_cidr_block_network_border_group = optional(string)
  })
  description = "The IPAM pool configuration for the internal VPC"
  default = {
    enabled                              = false
    ipv4_pool_id                         = null
    ipv4_netmask_length                  = null
    enable_ipv6                          = false
    ipv6_cidr                            = null
    ipv6_pool_id                         = null
    ipv6_netmask_length                  = null
    ipv6_cidr_block_network_border_group = null
  }
}

variable "cluster_network_internal_vpc_dhcp_options" {
  type = object({
    enabled              = bool
    domain_name          = string
    domain_name_servers  = optional(list(string))
    ntp_servers          = optional(list(string))
    netbios_name_servers = optional(list(string))
    netbios_node_type    = optional(string)
    tags                 = optional(map(string))
  })
  description = "The DHCP options configuration for the internal VPC"
  default = {
    enabled              = false
    domain_name          = ""
    domain_name_servers  = ["AmazonProvidedDNS"]
    ntp_servers          = []
    netbios_name_servers = []
    netbios_node_type    = ""
    tags                 = {}
  }
}

variable "cluster_network_internal_vpc_tags" {
  type        = map(string)
  description = "The tags to apply to the internal VPC"
  default     = {}
}

variable "cluster_network_internal_public_ingress_subnets_subnets_addresses" {
  type        = list(string)
  description = "The CIDR blocks to use for the public subnets in the internal VPC"
  validation {
    condition     = length(var.cluster_network_internal_public_ingress_subnets_subnets_addresses) > 0
    error_message = "There must be at least one public subnet and the number of public subnets must be at least the number of availability zones"
  }
  default = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

variable "cluster_network_internal_public_ingress_subnets_subnets_assign_ipv6_address_on_creation" {
  type        = bool
  description = "Whether to assign an IPv6 address to the public subnets in the internal VPC"
  default     = false
}

variable "cluster_network_internal_public_ingress_subnets_subnets_enable_dns64" {
  type        = bool
  description = "Whether to enable DNS64 for the public subnets in the internal VPC"
  default     = true
}

variable "cluster_network_internal_public_ingress_subnets_subnets_enable_resource_name_dns_aaaa_record_on_launch" {
  type        = bool
  description = "Whether to enable resource name DNS AAAA record on launch for the public subnets in the internal VPC"
  default     = true
}

variable "cluster_network_internal_public_ingress_subnets_subnets_enable_resource_name_dns_a_record_on_launch" {
  type        = bool
  description = "Whether to enable resource name DNS A record on launch for the public subnets in the internal VPC"
  default     = false
}

variable "cluster_network_internal_public_ingress_subnets_subnets_ipv6_prefixes" {
  type        = list(string)
  description = "The IPv6 prefixes to use for the public subnets in the internal VPC"
  default     = []
}

variable "cluster_network_internal_public_ingress_subnets_subnets_ipv6_native" {
  type        = bool
  description = "Whether to enable IPv6 native for the public subnets in the internal VPC"
  default     = false
}

variable "cluster_network_internal_public_ingress_subnets_subnets_map_public_ip_on_launch" {
  type        = bool
  description = "Whether to map public IP on launch for the public subnets in the internal VPC"
  default     = false
}

variable "cluster_network_internal_public_ingress_subnets_subnets_private_dns_hostname_type_on_launch" {
  type        = string
  description = "The private DNS hostname type on launch for the public subnets in the internal VPC"
  default     = null
}

variable "cluster_network_internal_public_ingress_subnets_subnets_acls" {
  type = object({
    enabled = bool
    inbound_rules = optional(list(object({
      rule_number = number
      rule_action = string
      from_port   = number
      to_port     = number
      protocol    = optional(string)
      cidr_block  = string
    })))
    outbound_rules = optional(list(object({
      rule_number = number
      rule_action = string
      from_port   = number
      to_port     = number
      protocol    = optional(string)
      cidr_block  = string
    })))
  })
  description = "The ACLs configuration for the public subnets in the internal VPC"
  default = {
    enabled = false
    inbound_rules = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    outbound_rules = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      },
    ]
  }
}

variable "cluster_network_internal_public_ingress_subnets_subnets_tags" {
  type = object({
    tags               = optional(map(string))
    route_table_tags   = optional(map(string))
    subnet_tags_per_az = optional(map(map(string)))
    acl_tags           = optional(map(string))
  })
  description = "The tags configuration for the public subnets in the internal VPC"
  default = {
    tags               = {}
    route_table_tags   = {}
    subnet_tags_per_az = {}
    acl_tags           = {}
  }
}

variable "cluster_network_internal_vpc_private_ingress_subnets_addresses" {
  type        = list(string)
  description = "The CIDR blocks to use for the intranet subnets in the internal VPC"
  validation {
    condition     = length(var.cluster_network_internal_vpc_private_ingress_subnets_addresses) > 0
    error_message = "There must be at least one intranet subnet and the number of intranet subnets must be at least the number of availability zones"
  }
  default = ["10.0.64.0/24", "10.0.65.0/24", "10.0.66.0/24"]
}

variable "cluster_network_internal_vpc_private_ingress_subnets_assign_ipv6_address_on_creation" {
  type        = bool
  description = "Whether to assign an IPv6 address to the intranet subnets in the internal VPC"
  default     = false
}

variable "cluster_network_internal_vpc_private_ingress_subnets_enable_dns64" {
  type        = bool
  description = "Whether to enable DNS64 for the intranet subnets in the internal VPC"
  default     = true
}

variable "cluster_network_internal_vpc_private_ingress_subnets_enable_resource_name_dns_aaaa_record_on_launch" {
  type        = bool
  description = "Whether to enable resource name DNS AAAA record on launch for the intranet subnets in the internal VPC"
  default     = true
}

variable "cluster_network_internal_vpc_private_ingress_subnets_enable_resource_name_dns_a_record_on_launch" {
  type        = bool
  description = "Whether to enable resource name DNS A record on launch for the intranet subnets in the internal VPC"
  default     = false
}

variable "cluster_network_internal_vpc_private_ingress_subnets_ipv6_prefixes" {
  type        = list(string)
  description = "The IPv6 prefixes to use for the intranet subnets in the internal VPC"
  default     = []
}

variable "cluster_network_internal_vpc_private_ingress_subnets_ipv6_native" {
  type        = bool
  description = "Whether to enable IPv6 native for the intranet subnets in the internal VPC"
  default     = false
}

variable "cluster_network_internal_vpc_private_ingress_subnets_dns_hostname_type_on_launch" {
  type        = string
  description = "The DNS hostname type on launch for the intranet subnets in the internal VPC"
  default     = null
}

variable "cluster_network_internal_vpc_private_ingress_subnets_acls" {
  type = object({
    enabled = bool
    inbound_rules = optional(list(object({
      rule_number = number
      rule_action = string
      from_port   = number
      to_port     = number
      protocol    = optional(string)
      cidr_block  = string
    })))
    outbound_rules = optional(list(object({
      rule_number = number
      rule_action = string
      from_port   = number
      to_port     = number
      protocol    = optional(string)
      cidr_block  = string
    })))
  })
  description = "The ACLs configuration for the intranet subnets in the internal VPC"
  default = {
    enabled = false
    inbound_rules = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    outbound_rules = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      },
    ]
  }
}

variable "cluster_network_internal_vpc_private_ingress_subnets_tags" {
  type = object({
    tags             = optional(map(string))
    route_table_tags = optional(map(string))
    acl_tags         = optional(map(string))
  })
  description = "The tags configuration for the intranet subnets in the internal VPC"
  default = {
    tags             = {}
    route_table_tags = {}
    acl_tags         = {}
  }
}

variable "cluster_network_internal_vpc_node_subnets_addresses" {
  type        = list(string)
  description = "The CIDR blocks to use for the node subnets in the internal VPC"
  validation {
    condition     = length(var.cluster_network_internal_vpc_node_subnets_addresses) > 0
    error_message = "There must be at least one node subnet and the number of node subnets must be at least the number of availability zones"
  }
  default = ["10.0.96.0/19", "10.0.128.0/19", "10.0.160.0/19"]
}

variable "cluster_network_internal_vpc_node_subnets_assign_ipv6_address_on_creation" {
  type        = bool
  description = "Whether to assign an IPv6 address to the node subnets in the internal VPC"
  default     = false
}

variable "cluster_network_internal_vpc_node_subnets_enable_dns64" {
  type        = bool
  description = "Whether to enable DNS64 for the node subnets in the internal VPC"
  default     = true
}

variable "cluster_network_internal_vpc_node_subnets_enable_resource_name_dns_aaaa_record_on_launch" {
  type        = bool
  description = "Whether to enable resource name DNS AAAA record on launch for the node subnets in the internal VPC"
  default     = true
}

variable "cluster_network_internal_vpc_node_subnets_enable_resource_name_dns_a_record_on_launch" {
  type        = bool
  description = "Whether to enable resource name DNS A record on launch for the node subnets in the internal VPC"
  default     = false
}

variable "cluster_network_internal_vpc_node_subnets_ipv6_prefixes" {
  type        = list(string)
  description = "The IPv6 prefixes to use for the node subnets in the internal VPC"
  default     = []
}

variable "cluster_network_internal_vpc_node_subnets_ipv6_native" {
  type        = bool
  description = "Whether to enable IPv6 native for the node subnets in the internal VPC"
  default     = false
}

variable "cluster_network_internal_vpc_node_subnets_private_dns_hostname_type_on_launch" {
  type        = string
  description = "The private DNS hostname type on launch for the node subnets in the internal VPC"
  default     = null
}

variable "cluster_network_internal_vpc_node_subnets_acls" {
  type = object({
    enabled = bool
    inbound_rules = optional(list(object({
      rule_number = number
      rule_action = string
      from_port   = number
      to_port     = number
      protocol    = optional(string)
      cidr_block  = string
    })))
    outbound_rules = optional(list(object({
      rule_number = number
      rule_action = string
      from_port   = number
      to_port     = number
      protocol    = optional(string)
      cidr_block  = string
    })))
  })
  description = "The ACLs configuration for the node subnets in the internal VPC"
  default = {
    enabled = false
    inbound_rules = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    outbound_rules = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      },
    ]
  }
}

variable "cluster_network_internal_vpc_node_subnets_tags" {
  type = object({
    tags               = optional(map(string))
    route_table_tags   = optional(map(string))
    subnet_tags_per_az = optional(map(map(string)))
    acl_tags           = optional(map(string))
  })
  description = "The tags configuration for the node subnets in the internal VPC"
  default = {
    tags               = {}
    route_table_tags   = {}
    subnet_tags_per_az = {}
    acl_tags           = {}
  }
}

variable "cluster_network_internal_vpc_data_subnets_addresses" {
  type        = list(string)
  description = "The CIDR blocks to use for the data subnets in the internal VPC"
  validation {
    condition     = length(var.cluster_network_internal_vpc_data_subnets_addresses) > 0
    error_message = "There must be at least one data subnet and the number of data subnets must be at least the number of availability zones"
  }
  default = ["10.0.224.0/24", "10.0.225.0/24", "10.0.226.0/24"]
}

variable "cluster_network_internal_vpc_data_subnets_assign_ipv6_address_on_creation" {
  type        = bool
  description = "Whether to assign an IPv6 address to the data subnets in the internal VPC"
  default     = false
}

variable "cluster_network_internal_vpc_data_subnets_enable_dns64" {
  type        = bool
  description = "Whether to enable DNS64 for the data subnets in the internal VPC"
  default     = true
}

variable "cluster_network_internal_vpc_data_subnets_enable_resource_name_dns_aaaa_record_on_launch" {
  type        = bool
  description = "Whether to enable resource name DNS AAAA record on launch for the data subnets in the internal VPC"
  default     = true
}

variable "cluster_network_internal_vpc_data_subnets_enable_resource_name_dns_a_record_on_launch" {
  type        = bool
  description = "Whether to enable resource name DNS A record on launch for the data subnets in the internal VPC"
  default     = false
}

variable "cluster_network_internal_vpc_data_subnets_ipv6_prefixes" {
  type        = list(string)
  description = "The IPv6 prefixes to use for the data subnets in the internal VPC"
  default     = []
}

variable "cluster_network_internal_vpc_data_subnets_ipv6_native" {
  type        = bool
  description = "Whether to enable IPv6 native for the data subnets in the internal VPC"
  default     = false
}

variable "cluster_network_internal_vpc_data_subnets_dns_hostname_type_on_launch" {
  type        = string
  description = "The DNS hostname type on launch for the data subnets in the internal VPC"
  default     = null
}

variable "cluster_network_internal_vpc_data_subnets_acls" {
  type = object({
    enabled = bool
    inbound_rules = optional(list(object({
      rule_number = number
      rule_action = string
      from_port   = number
      to_port     = number
      protocol    = optional(string)
      cidr_block  = string
    })))
    outbound_rules = optional(list(object({
      rule_number = number
      rule_action = string
      from_port   = number
      to_port     = number
      protocol    = optional(string)
      cidr_block  = string
    })))
  })
  description = "The ACLs configuration for the data subnets in the internal VPC"
  default = {
    enabled = false
    inbound_rules = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      }
    ]
    outbound_rules = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      }
    ]
  }
}

variable "cluster_network_internal_vpc_data_subnets_tags" {
  type = object({
    tags     = optional(map(string))
    acl_tags = optional(map(string))
  })
  description = "The tags configuration for the data subnets in the internal VPC"
  default = {
    tags     = {}
    acl_tags = {}
  }
}

variable "cluster_network_internal_vpc_endpoints" {
  type = object({
    enabled = bool
    services = optional(map(object({
      service             = string
      service_name        = optional(string)
      service_type        = optional(string)
      policy              = optional(string)
      auto_accept         = optional(bool)
      private_dns_enabled = optional(bool)
    })))
    security_group_ids = optional(list(string))
    dns_options = optional(object({
      dns_record_ip_type                             = optional(string)
      private_dns_only_for_inbound_resolver_endpoint = optional(bool)
    }))
    timeout_options = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
    tags = optional(map(string))
  })
  description = "The VPC endpoints configuration for the internal VPC"
  default = {
    enabled            = false
    services           = {}
    security_group_ids = []
    dns_options        = {}
    timeout_options    = {}
    tags               = {}
  }
}

variable "cluster_enabled" {
  type        = bool
  description = "Whether to create the Kubernetes cluster"
  default     = true
}

variable "cluster_version" {
  type        = string
  description = "The version of the Kubernetes cluster"
  default     = "1.29"
}

variable "cluster_authentication_mode" {
  type = string
  validation {
    condition     = can(regex("^(API_AND_CONFIG_MAP|API|CONFIG_MAP)$", var.cluster_authentication_mode))
    error_message = "The authentication_mode value must be either API_AND_CONFIG_MAP, API or CONFIG_MAP"
  }
  description = "The authentication mode for the Kubernetes cluster"
  default     = "API_AND_CONFIG_MAP"
}

variable "cluster_cloudwatch_logging" {
  type = object({
    enabled                     = optional(bool)
    log_types                   = optional(list(string))
    log_group_retention_in_days = optional(number)
    log_group_kms_key_id        = optional(string)
    log_group_class             = optional(string)
    log_group_tags              = optional(map(string))
  })
  description = "The logging configuration for the Kubernetes cluster"
  default = {
    enabled                     = true
    log_types                   = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
    log_group_retention_in_days = 7
    log_group_kms_key_id        = null
    log_group_class             = null
    log_group_tags              = {}
  }
}

variable "cluster_vpc_config" {
  type = object({
    additional_security_group_ids           = optional(list(string))
    endpoint_public_access                  = optional(bool)
    endpoint_private_access                 = optional(bool)
    endpoint_public_access_allow_from_cidrs = optional(list(string))
  })
  description = "The VPC configuration for the Kubernetes cluster"
  default = {
    additional_security_group_ids           = []
    endpoint_public_access                  = true
    endpoint_private_access                 = true
    endpoint_public_access_allow_from_cidrs = ["0.0.0.0/0"]
  }
}

variable "cluster_service_network_config" {
  type = object({
    ip_family         = optional(string)
    service_ipv4_cidr = optional(string)
    service_ipv6_cidr = optional(string)
  })
  description = "The internal service network configuration for the Kubernetes cluster"
  default = {
    ip_family         = "ipv4"
    service_ipv4_cidr = null
    service_ipv6_cidr = null
  }
}

variable "cluster_database_encryption_config" {
  type = object({
    provider_key_arn = optional(string)
    resources        = optional(list(string))
  })
  description = "The encryption configuration for the Kubernetes cluster"
  default = {
    provider_key_arn = null
    resources        = ["secrets"]
  }
}

variable "cluster_encryption_policy" {
  type = object({
    attach_default  = optional(bool)
    use_name_prefix = optional(bool)
    name            = optional(string)
    description     = optional(string)
    path            = optional(string)
    tags            = optional(map(string))
  })
  description = "The encryption policy for the Kubernetes cluster"
  default = {
    attach_default  = true
    use_name_prefix = true
    name            = null
    description     = "Cluster encryption policy to allow cluster role to utilize CMK provided"
    path            = null
    tags            = {}
  }
}

variable "cluster_tags" {
  type        = map(string)
  description = "The tags to apply to the Kubernetes cluster"
  default     = {}
}

variable "cluster_timeouts" {
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  description = "The waiting timeouts configuration for the Kubernetes cluster"
  default = {
    create = "45m"
    update = "60m"
    delete = "30m"
  }
}

variable "cluster_security_group" {
  type = object({
    create_default                     = optional(bool)
    create_primary_security_group_tags = optional(bool)
    id                                 = optional(string)
    name                               = optional(string)
    use_name_prefix                    = optional(bool)
    description                        = optional(string)
    additional_rules                   = optional(any)
    tags                               = optional(map(string))
  })
  description = "The security group configuration for the Kubernetes cluster"
  default = {
    create_default                     = true
    create_primary_security_group_tags = true
    id                                 = null
    name                               = null
    use_name_prefix                    = true
    description                        = "EKS cluster security group"
    additional_rules                   = {}
    tags                               = {}
  }
}

variable "cluster_node_security_group" {
  type = object({
    create_default             = optional(bool)
    id                         = optional(string)
    name                       = optional(string)
    use_name_prefix            = optional(bool)
    description                = optional(string)
    enable_efa_support         = optional(bool)
    enable_recommended_rules   = optional(bool)
    create_cni_ipv6_iam_policy = optional(bool)
    additional_rules           = optional(any)
    tags                       = optional(map(string))
  })
  description = "The security group configuration for the Kubernetes cluster nodes"
  default = {
    create_default             = true
    id                         = ""
    name                       = null
    use_name_prefix            = true
    description                = "EKS node security group"
    enable_efa_support         = false
    enable_recommended_rules   = true
    create_cni_ipv6_iam_policy = false
    additional_rules           = {}
    tags                       = {}
  }
}

variable "cluster_access_management" {
  type = object({
    enable_cluster_creator_admin_permissions = optional(bool)
    list                                     = optional(map(any))
  })
  description = "The access management configuration for the Kubernetes cluster"
  default = {
    enable_cluster_creator_admin_permissions = false
    list                                     = null
  }
}

variable "cluster_kms" {
  type = object({
    enabled                       = optional(bool)
    key_description               = optional(string)
    key_deletion_window_in_days   = optional(string)
    enable_key_rotation           = optional(bool)
    key_enable_default_policy     = optional(bool)
    key_owners                    = optional(list(string))
    key_administrators            = optional(list(string))
    key_users                     = optional(list(string))
    key_service_users             = optional(list(string))
    key_source_policy_documents   = optional(list(string))
    key_override_policy_documents = optional(list(string))
    key_aliases                   = optional(list(string))
  })
  description = "The KMS configuration for the Kubernetes cluster"
  default = {
    enabled                       = true
    key_description               = null
    key_deletion_window_in_days   = 30
    enable_key_rotation           = true
    key_enable_default_policy     = true
    key_owners                    = []
    key_administrators            = []
    key_users                     = []
    key_service_users             = []
    key_source_policy_documents   = []
    key_override_policy_documents = []
    key_aliases                   = []
  }
}


variable "cluster_iam_role_for_service_account" {
  type = object({
    enabled                         = optional(bool)
    include_oidc_root_ca_thumbprint = optional(bool)
    openid_connect_audiences        = optional(list(string))
    custom_oidc_thumbprints         = optional(list(string))
  })
  description = "The IAM role configuration for the Kubernetes cluster service account"
  default = {
    enabled                         = true
    include_oidc_root_ca_thumbprint = true
    openid_connect_audiences        = []
    custom_oidc_thumbprints         = []
  }
}

variable "cluster_iam" {
  type = object({
    create_default_role       = optional(bool)
    role_arn                  = optional(string)
    role_name                 = optional(string)
    role_use_name_prefix      = optional(bool)
    role_path                 = optional(string)
    role_description          = optional(string)
    role_permissions_boundary = optional(string)
    role_additional_policies  = optional(map(string))
    role_tags                 = optional(map(string))
  })
  description = "The IAM role configuration for the Kubernetes cluster"
  default = {
    create_default_role       = true
    role_arn                  = null
    role_name                 = null
    role_use_name_prefix      = true
    role_path                 = null
    role_description          = null
    role_permissions_boundary = null
    role_additional_policies  = {}
    role_tags                 = {}
  }
}



variable "cluster_addons_default" {
  type        = any
  description = "The addons configuration for the Kubernetes cluster"
  default = {
    coredns = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    vpc-cni = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      before_compute              = true
    }
    kube-proxy = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    snapshot-controller = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    eks-pod-identity-agent = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
  }
}

variable "cluster_addons_additional" {
  type        = any
  description = "The additional addons configuration for the Kubernetes cluster"
  default     = {}
}

variable "cluster_addons_timeouts" {
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  description = "The waiting timeouts configuration for the Kubernetes cluster addons"
  default     = {}
}

variable "cluster_additional_identity_providers" {
  type        = any
  description = "The additional identity providers configuration for the Kubernetes cluster"
  default     = {}
}

variable "cluster_compute_pool_aws_managed" {
  type = object({
    defaults = optional(any)
    groups   = any
  })
  description = "The AWS managed compute pool configuration for the Kubernetes cluster"
  default = {
    defaults = {}
    groups = {
      spot = {
        min_size                   = 3
        max_size                   = 3
        desired_size               = 3
        disk_size                  = 100
        use_custom_launch_template = false
        instance_types             = ["t3a.2xlarge", "m5a.2xlarge", "c5a.2xlarge", "r5a.2xlarge", "t3a.large"]
        capacity_type              = "SPOT"
        labels = {
          node-type = "spot"
        }
        update_config = {
          max_unavailable_percentage = 30
        }
      }
      main = {
        min_size                   = 2
        max_size                   = 2
        desired_size               = 2
        disk_size                  = 100
        use_custom_launch_template = false
        instance_types             = ["t3a.2xlarge"]
        capacity_type              = "ON_DEMAND"
        labels = {
          node-type = "main"
        }
        update_config = {
          max_unavailable_percentage = 30
        }
      }
    }
  }
}

variable "cluster_compute_pool_self_managed" {
  type = object({
    defaults = optional(any)
    groups   = any
  })
  description = "The self managed compute pool configuration for the Kubernetes cluster"
  default = {
    defaults = {}
    groups   = {}
  }
}

variable "cluster_compute_pool_fargate" {
  type = object({
    defaults = optional(any)
    groups   = any
  })
  description = "The Fargate compute pool configuration for the Kubernetes cluster"
  default = {
    defaults = {}
    groups   = {}
  }
}

variable "cluster_storage_classes_create" {
  type        = bool
  description = "Whether to create the custom storage classes for the Kubernetes cluster"
  default     = true
}

variable "cluster_default_storage_storage_classes" {
  type = map(object({
    name                   = optional(string)
    annotations            = optional(any)
    reclaim_policy         = optional(string)
    volume_binding_mode    = optional(string)
    allow_volume_expansion = optional(bool)
    parameters             = optional(any)
  }))
  description = "The default standard storage class type for the current Kubernetes cluster"
  default = {
    standard = {
      name = "standard"
      annotations = {
        "storageclass.kubernetes.io/is-default-class" : "true"
      }
      reclaim_policy         = "Retain"
      volume_binding_mode    = "WaitForFirstConsumer"
      allow_volume_expansion = true
      parameters = {
        encrypted : true
        type : "gp3"
        "csi.storage.k8s.io/fstype" : "ext3"
        allowAutoIOPSPerGBIncrease : true
      }
    }
    golden = {
      name = "golden"
      annotations = {
        "storageclass.kubernetes.io/is-default-class" : "false"
      }
      reclaim_policy         = "Retain"
      volume_binding_mode    = "WaitForFirstConsumer"
      allow_volume_expansion = true
      parameters = {
        encrypted : true
        type : "io1"
        "csi.storage.k8s.io/fstype" : "ext3"
        allowAutoIOPSPerGBIncrease : true
      }
    }
    platinum = {
      name = "platinum"
      annotations = {
        "storageclass.kubernetes.io/is-default-class" : "false"
      }
      reclaim_policy         = "Retain"
      volume_binding_mode    = "WaitForFirstConsumer"
      allow_volume_expansion = true
      parameters = {
        encrypted : true
        type : "io2"
        "csi.storage.k8s.io/fstype" : "xfs"
        allowAutoIOPSPerGBIncrease : true
      }
    }
  }
}

variable "cluster_custom_storage_classes" {
  type = map(object({
    name                   = optional(string)
    annotations            = optional(any)
    reclaim_policy         = optional(string)
    volume_binding_mode    = optional(string)
    allow_volume_expansion = optional(bool)
    storage_provisioner    = optional(string)
    parameters             = optional(any)
  }))
  description = "Custom storage class objects for the current Kubernetes cluster that can be created in addition of as a substitution for the ones defined in the cluster_default_storage_storage_classes variable"
  default     = {}
}

variable "cluster_monitoring_create" {
  type        = bool
  description = "Whether to create the monitoring for the Kubernetes cluster"
  default     = true
}

variable "cluster_monitoring" {
  type = object({
    helm_chart_repository          = optional(string)
    helm_chart_repository_config   = optional(string)
    helm_chart_version             = optional(string)
    helm_chart_name                = optional(string)
    helm_chart_namespace           = optional(string)
    create_namespace_if_not_exists = optional(bool)
    helm_chart_params = optional(list(object({
      name  = string
      value = any
    })))
    helm_chart_secrets = optional(list(object({
      name  = string
      value = any
    })))
    helm_chart_values = optional(string)
  })
  description = "The monitoring configuration for the Kubernetes cluster"
  default = {
    helm_chart_repository          = "oci://public.registry.jetbrains.space/p/helm/library"
    helm_chart_repository_config   = null
    helm_chart_version             = "56.21.1"
    helm_chart_name                = "kube-prometheus-operator"
    helm_chart_namespace           = "kube-monitoring"
    create_namespace_if_not_exists = true
    helm_chart_params              = []
    helm_chart_secrets             = []
    helm_chart_values              = null
  }
}

variable "cluster_node_patcher_create" {
  type        = bool
  description = "Whether to create the node patcher for the Kubernetes cluster"
  default     = true
}

variable "cluster_node_patcher" {
  type = object({
    helm_chart_repository          = optional(string)
    helm_chart_repository_config   = optional(string)
    helm_chart_version             = optional(string)
    helm_chart_name                = optional(string)
    helm_chart_namespace           = optional(string)
    create_namespace_if_not_exists = optional(bool)
    helm_chart_params = optional(list(object({
      name  = string
      value = any
    })))
    helm_chart_secrets = optional(list(object({
      name  = string
      value = any
    })))
    helm_chart_values = optional(string)
  })
  description = "The node patcher configuration for the Kubernetes cluster"
  default = {
    helm_chart_repository          = "oci://public.registry.jetbrains.space/p/helm/library"
    helm_chart_repository_config   = null
    helm_chart_version             = "5.4.3"
    helm_chart_name                = "kube-node-reboot"
    helm_chart_namespace           = "kube-node-rebooter"
    create_namespace_if_not_exists = true
    helm_chart_params              = []
    helm_chart_secrets             = []
    helm_chart_values              = null
  }
}

variable "cluster_metrics_server_create" {
  type        = bool
  description = "Whether to create the cluster metrics server for the Kubernetes cluster"
  default     = true
}

variable "cluster_metrics_server" {
  type = object({
    helm_chart_repository          = optional(string)
    helm_chart_repository_config   = optional(string)
    helm_chart_version             = optional(string)
    helm_chart_name                = optional(string)
    helm_chart_namespace           = optional(string)
    create_namespace_if_not_exists = optional(bool)
    helm_chart_params = optional(list(object({
      name  = string
      value = any
    })))
    helm_chart_secrets = optional(list(object({
      name  = string
      value = any
    })))
    helm_chart_values = optional(string)
  })
  description = "The metrics server configuration for the Kubernetes cluster"
  default = {
    helm_chart_repository          = "oci://public.registry.jetbrains.space/p/helm/library"
    helm_chart_repository_config   = null
    helm_chart_version             = "3.12.0"
    helm_chart_name                = "kube-metrics-server"
    helm_chart_namespace           = "kube-monitoring"
    create_namespace_if_not_exists = true
    helm_chart_params              = []
    helm_chart_secrets             = []
    helm_chart_values              = null
  }
}

variable "cluster_logging_create" {
  type        = bool
  description = "Whether to create the cluster logging service for the Kubernetes cluster"
  default     = true
}

variable "cluster_logging" {
  type = object({
    helm_chart_repository          = optional(string)
    helm_chart_repository_config   = optional(string)
    helm_chart_version             = optional(string)
    helm_chart_name                = optional(string)
    helm_chart_namespace           = optional(string)
    create_namespace_if_not_exists = optional(bool)
    helm_chart_params = optional(list(object({
      name  = string
      value = any
    })))
    helm_chart_secrets = optional(list(object({
      name  = string
      value = any
    })))
    helm_chart_values = optional(string)
  })
  description = "The cluster logging configuration for the Kubernetes cluster"
  default = {
    helm_chart_repository          = "oci://public.registry.jetbrains.space/p/helm/library"
    helm_chart_repository_config   = null
    helm_chart_version             = "5.43.3"
    helm_chart_name                = "kube-grafana-loki"
    helm_chart_namespace           = "kube-monitoring"
    create_namespace_if_not_exists = true
    helm_chart_params              = []
    helm_chart_secrets             = []
    helm_chart_values              = null
  }
}

variable "cluster_logging_collector" {
  type = object({
    helm_chart_repository          = optional(string)
    helm_chart_repository_config   = optional(string)
    helm_chart_version             = optional(string)
    helm_chart_name                = optional(string)
    helm_chart_namespace           = optional(string)
    create_namespace_if_not_exists = optional(bool)
    helm_chart_params = optional(list(object({
      name  = string
      value = any
    })))
    helm_chart_secrets = optional(list(object({
      name  = string
      value = any
    })))
    helm_chart_values = optional(string)
  })
  description = "The cluster logging collector configuration for the Kubernetes cluster"
  default = {
    helm_chart_repository          = "oci://public.registry.jetbrains.space/p/helm/library"
    helm_chart_repository_config   = null
    helm_chart_version             = "6.15.5"
    helm_chart_name                = "kube-grafana-promtail"
    helm_chart_namespace           = "kube-monitoring"
    create_namespace_if_not_exists = true
    helm_chart_params              = []
    helm_chart_secrets             = []
    helm_chart_values              = null
  }
}

variable "cluster_public_ingress_create" {
  type        = bool
  description = "Whether to create the public ingress for the Kubernetes cluster"
  default     = false
}

variable "cluster_public_ingress" {
  type = object({
    helm_chart_repository          = optional(string)
    helm_chart_repository_config   = optional(string)
    helm_chart_version             = optional(string)
    helm_chart_name                = optional(string)
    helm_chart_namespace           = optional(string)
    create_namespace_if_not_exists = optional(bool)
    helm_chart_params = optional(list(object({
      name  = string
      value = any
    })))
    helm_chart_secrets = optional(list(object({
      name  = string
      value = any
    })))
    helm_chart_values = optional(string)
  })
  description = "The cluster public ingress configuration for the Kubernetes cluster"
  default = {
    helm_chart_repository          = "oci://public.registry.jetbrains.space/p/helm/library"
    helm_chart_repository_config   = null
    helm_chart_version             = "4.10.0"
    helm_chart_name                = "kube-ingress-nginx"
    helm_chart_namespace           = "kube-public-ingress"
    create_namespace_if_not_exists = true
    helm_chart_params              = []
    helm_chart_secrets             = []
    helm_chart_values              = null
  }
}

variable "cluster_private_ingress_create" {
  type        = bool
  description = "Whether to create the private ingress for the Kubernetes cluster"
  default     = true
}

variable "cluster_private_ingress" {
  type = object({
    helm_chart_repository          = optional(string)
    helm_chart_repository_config   = optional(string)
    helm_chart_version             = optional(string)
    helm_chart_name                = optional(string)
    helm_chart_namespace           = optional(string)
    create_namespace_if_not_exists = optional(bool)
    helm_chart_params = optional(list(object({
      name  = string
      value = any
    })))
    helm_chart_secrets = optional(list(object({
      name  = string
      value = any
    })))
    helm_chart_values = optional(string)
  })
  description = "The cluster private ingress configuration for the Kubernetes cluster"
  default = {
    helm_chart_repository          = "oci://public.registry.jetbrains.space/p/helm/library"
    helm_chart_repository_config   = null
    helm_chart_version             = "4.10.0"
    helm_chart_name                = "kube-ingress-nginx"
    helm_chart_namespace           = "kube-private-ingress"
    create_namespace_if_not_exists = true
    helm_chart_params              = []
    helm_chart_secrets             = []
    helm_chart_values              = null
  }
}

variable "cluster_descheduler_create" {
  type        = bool
  description = "Whether to create the descheduler for the Kubernetes cluster"
  default     = true
}

variable "cluster_descheduler" {
  type = object({
    helm_chart_repository        = optional(string)
    helm_chart_repository_config = optional(string)
    helm_chart_version           = optional(string)
    helm_chart_name              = optional(string)
    helm_chart_params = optional(list(object({
      name  = string
      value = any
    })))
    helm_chart_secrets = optional(list(object({
      name  = string
      value = any
    })))
    helm_chart_values = optional(string)
  })
  description = "The descheduler configuration for the Kubernetes cluster"
  default = {
    helm_chart_repository        = "oci://public.registry.jetbrains.space/p/helm/library"
    helm_chart_repository_config = null
    helm_chart_version           = "0.29.0"
    helm_chart_name              = "kube-descheduler"
    helm_chart_params            = []
    helm_chart_secrets           = []
    helm_chart_values            = null
  }
}

variable "cluster_additional_apps_create" {
  type        = bool
  description = "Whether to create additional apps in the Kubernetes cluster"
  default     = false
}

variable "cluster_additional_apps" {
  type = list(object({
    namespace  = string
    repository = string
    repository_config = optional(object({
      repository_key_file  = optional(string)
      repository_cert_file = optional(string)
      repository_ca_file   = optional(string)
      repository_username  = optional(string)
      repository_password  = optional(string)
    }))
    app = object({
      name                       = string
      chart                      = string
      version                    = string
      force_update               = optional(bool)
      wait                       = optional(bool)
      recreate_pods              = optional(bool)
      max_history                = optional(number)
      lint                       = optional(bool)
      cleanup_on_fail            = optional(bool)
      create_namespace           = optional(bool)
      disable_webhooks           = optional(bool)
      verify                     = optional(bool)
      reuse_values               = optional(bool)
      reset_values               = optional(bool)
      atomic                     = optional(bool)
      skip_crds                  = optional(bool)
      render_subchart_notes      = optional(bool)
      disable_openapi_validation = optional(bool)
      wait_for_jobs              = optional(bool)
      dependency_update          = optional(bool)
      replace                    = optional(bool)
    })
    values = optional(any)
    params = optional(list(object({
      name  = string
      value = any
    })))
    secrets = optional(list(object({
      name  = string
      value = any
    })))
  }))
  description = <<-EOF
    List of additional apps packaged as Helm Charts to deploy in the Kubernetes cluster.
  EOF
  default     = []
}

variable "cluster_autoscaler_create" {
  type        = bool
  description = "Whether to create the cluster autoscaler for the Kubernetes cluster"
  default     = true
}

variable "cluster_autoscaler" {
  type = object({
    helm_chart_repository        = string
    helm_chart_repository_config = optional(string)
    helm_chart_version           = string
    helm_chart_name              = optional(string)
    helm_chart_params = optional(list(object({
      name  = string
      value = any
    })))
    helm_chart_secrets = optional(list(object({
      name  = string
      value = any
    })))
    helm_chart_values = optional(string)
  })
  description = "The cluster autoscaler configuration for the Kubernetes cluster"
  default = {
    helm_chart_repository        = "oci://public.registry.jetbrains.space/p/helm/library"
    helm_chart_repository_config = null
    helm_chart_version           = "0.35.1"
    helm_chart_name              = "kube-karpenter"
    helm_chart_params            = []
    helm_chart_secrets           = []
    helm_chart_values            = null
  }
}

variable "cluster_autoscaler_subnet_selector" {
  type        = string
  description = "The subnet selector for the cluster autoscaler"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Specify a list of tags as key/value pairs. These tags will be applied to all resources created by this module"
  default = {
    ResourceCreatedBy = "TerraformModule:terraform-aws-kubernetes"
  }
}




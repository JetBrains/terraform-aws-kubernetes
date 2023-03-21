/**
* This is a locals.tf file and it defines the default configuration for the network.
*/
locals {

  // AWS location details
  region = var.region
  azs    = ["${local.region}a", "${local.region}b", "${local.region}c"]

  // Environment details
  name        = var.name
  environment = var.environment

  // Networking high level details
  cidr         = var.vpc_cidr
  subnet_names = ["public_ingress", "private_ingress", "private_nodes", "isolated_resources"]
  global_private_module_values = {
    subnets = zipmap(local.subnet_names, [for cidr in cidrsubnets(local.cidr, 2, 2, 2, 2) : cidrsubnets(cidr, 2, 2, 2)])
  }

  eks_networking_requirements = {
    // Determines whether the VPC supports assigning public DNS hostnames to instances with public IP addresses.
    enable_dns_hostnames = true
    // Determines whether the VPC supports DNS resolution through the Amazon provided DNS server.
    enable_dns_support = true
    /**
    *  If both attributes are set to true, the following will occur:
    *  - Instances with public IP addresses receive corresponding public DNS hostnames;
    *  - AWS Route 53 Resolver will not be able to resolve AWS private DNS hostnames.
    */
    public_ingress_tags = {
      "kubernetes.io/role/elb" = 1
    }

    private_ingress_tags = {
      "kubernetes.io/role/internal-elb" = 1
    }
  }

  network_params = {
    name = local.name

    private_subnets = local.global_private_module_values.subnets["private_nodes"]

    public_subnets = local.global_private_module_values.subnets["public_ingress"]

    intra_subnets = local.global_private_module_values.subnets["isolated_resources"]

    default_nat_gateway_type = var.vpc_nat_gateway_type,

    nat_gateway_type = {
      single_nat_gateway = {
        enable_nat_gateway     = true,
        single_nat_gateway     = true,
        one_nat_gateway_per_az = false
      },
      one_nat_gateway_per_subnet = {
        enable_nat_gateway     = true,
        single_nat_gateway     = false,
        one_nat_gateway_per_az = false
      },
      one_nat_gateway_per_az = {
        enable_nat_gateway     = true,
        single_nat_gateway     = false,
        one_nat_gateway_per_az = true
      }
    }
  }

  tags = merge(var.tags, {
    environment    = local.environment
    product        = "JetbrainsSpace"
    cloud_platform = "AmazonWebServices"
  })
}



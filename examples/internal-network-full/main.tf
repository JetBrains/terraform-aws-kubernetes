module "example_full_internal_network" {
  source = "../.."

  prefix                                                 = "full-nw"
  cluster_network_type                                   = "internal"
  cluster_network_internal_vpc_cidr                      = "10.0.0.0/16"
  cluster_network_internal_vpc_nat_gateway_type          = "one_nat_gateway_per_az"
  cluster_network_internal_vpc_availability_zones_number = 3
  cluster_network_internal_vpc_tags = {
    Purpose = "TestCase"
  }
  cluster_network_internal_public_ingress_subnets_subnets_addresses = ["10.0.32.0/24", "10.0.33.0/24", "10.0.34.0/24"]
  cluster_network_internal_vpc_private_ingress_subnets_addresses    = ["10.0.48.0/24", "10.0.49.0/24", "10.0.50.0/24"]
  cluster_network_internal_vpc_node_subnets_addresses               = ["10.0.192.0/24", "10.0.193.0/24", "10.0.194.0/24"]
  cluster_network_internal_vpc_data_subnets_addresses               = ["10.0.208.0/24", "10.0.209.0/24", "10.0.210.0/24"]
  cluster_network_internal_vpc_endpoints = {
    enabled = true
    services = {
      s3 = {
        service      = "s3"
        service_type = "Interface"
        tags         = { Name = "s3-vpc-endpoint" }
      },
      ecs = {
        service      = "ecs"
        service_type = "Interface"
        tags         = { Name = "dynamodb-vpc-endpoint" }
      },
      rds = {
        service      = "rds"
        service_type = "Interface"
        tags         = { Name = "rds-vpc-endpoint" }
      },
    }
  }

}

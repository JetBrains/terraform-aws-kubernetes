/*
  The purpose of this example is to show that the external network does not create any internal networking object.
  The example does not show the input values and types.

  Notice that this example does nothing useful; it just makes sure that the internal and external networks are
  mutually exclusive.
*/
module "example_with_external_network_configuration" {
  source = "../.."

  cluster_network_type                              = "external"
  cluster_network_external_vpc_id                   = "vpc-0a1b2c3d4e5f67890"
  cluster_network_external_node_subnet_ids          = ["subnet-0a1b2c3d4e5f67891", "subnet-0a1b2c3d4e5f67892"]
  cluster_network_external_control_plane_subnet_ids = ["subnet-0a1b2c3d4e5f67890", "subnet-0a1b2c3d4e5f67891"]
  cluster_autoscaler_subnet_selector                = "1"
}

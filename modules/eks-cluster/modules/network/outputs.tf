#######################################################
#   AWS LOCATION DETAILS
#######################################################
output "region" {
  description = "Region name of the deployment"
  value       = local.region
}

#######################################################
#   VIRTUAL PRIVATE CLOUD (VPC) DETAILS
#######################################################
output "vpc_id" {
  description = <<EOF
      Id of the VPC. 
    EOF

  value = module.network.vpc_id
}

output "vpc_arn" {
  description = <<EOF
      ARN of the VPC. 
    EOF

  value = module.network.vpc_arn
}

output "subnet_cidr_blocks_per_type" {
  description = <<EOF
    Allocated network prefixes grouped per purpose.
  EOF

  value = local.global_private_module_values.subnets
}

output "subnet_ids_per_type" {
  description = <<EOF
    List of subnet ids per type.
  EOF
  value = {
    "public_ingress"     = module.network.public_subnets
    "private_ingress"    = aws_subnet.ingress_subnet.*.id
    "private_nodes"      = module.network.private_subnets
    "isolated_resources" = module.network.intra_subnets
  }
}

#######################################################
#   METADATA
#######################################################
output "tags" {
  description = <<EOF
    List of tags that are applied to internal resources.
  EOF
  value       = local.tags
}

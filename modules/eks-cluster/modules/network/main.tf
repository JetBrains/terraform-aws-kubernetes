/**
* Find in this file details about the EKS network spoke.
*/
module "network" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.18.1"

  name = local.network_params.name

  cidr = local.cidr

  enable_dns_hostnames = local.eks_networking_requirements.enable_dns_hostnames
  enable_dns_support   = local.eks_networking_requirements.enable_dns_support

  private_subnets = local.network_params.private_subnets
  private_subnet_tags = {
    "Purpose"                = "Kube Workers"
    "karpenter.sh/discovery" = local.name
  }
  public_subnets = local.network_params.public_subnets

  public_subnet_tags = merge({
    "Purpose" = "Kube Internet-facing Ingress"
  }, local.eks_networking_requirements.public_ingress_tags)

  intra_subnets = local.network_params.intra_subnets

  enable_nat_gateway     = local.network_params.nat_gateway_type[local.network_params.default_nat_gateway_type].enable_nat_gateway
  single_nat_gateway     = local.network_params.nat_gateway_type[local.network_params.default_nat_gateway_type].single_nat_gateway
  one_nat_gateway_per_az = local.network_params.nat_gateway_type[local.network_params.default_nat_gateway_type].one_nat_gateway_per_az

  azs  = local.azs
  tags = local.tags
}

resource "aws_subnet" "ingress_subnet" {
  count             = length(local.azs) > 0 ? length(local.azs) : 0
  vpc_id            = module.network.vpc_id
  cidr_block        = element(local.global_private_module_values.subnets["private_ingress"], count.index)
  availability_zone = element(local.azs, count.index)

  tags = merge({
    Purpose = "Kube Intranet-facing Ingress"
    Name    = "${local.network_params.name}-private-ingress-${element(local.azs, count.index)}"
  }, local.eks_networking_requirements.private_ingress_tags)

}

resource "aws_route_table_association" "ingress_subnet_rt_association" {
  count = length(aws_subnet.ingress_subnet) > 0 ? length(aws_subnet.ingress_subnet) : 0

  subnet_id = element(aws_subnet.ingress_subnet[*].id, count.index)
  route_table_id = element(
    module.network.private_route_table_ids,
    local.network_params.nat_gateway_type == "single_nat_gateway" ? 0 : count.index
  )
  # Exception:
  # This resource does not support tags.
}

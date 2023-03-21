data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" { state = "available" }

data "aws_eks_cluster_auth" "this_cluster" {
  name = module.eks.cluster_name
}
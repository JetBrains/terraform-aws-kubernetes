locals {
  title = "kube-minimal-example"
  tags = {
    DeploymentType = "Example"
  }
}

module "eks_minimal" {
  source = "../.."

  name = local.title
  tags = local.tags
}
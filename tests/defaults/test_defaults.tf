terraform {
  required_providers {
    # Because we're currently using a built-in provider as
    # a substitute for dedicated Terraform language syntax
    # for now, test suite modules must always declare a
    # dependency on this provider. This provider is only
    # available when running tests, so you shouldn't use it
    # in non-test modules.
    test = {
      # User Guide Manual
      # Ref: https://github.com/paloth/terraform-test
      source = "terraform.io/builtin/test"
    }

    # This example also uses the "http" data source to
    # verify the behavior of the hypothetical running
    # service, so we should declare that too.
    http = {
      source = "hashicorp/http"
    }
  }
}

module "main" {
  # source is always ../.. for test suite configurations,
  # because they are placed two subdirectories deep under
  # the main module directory.
  source = "../.."

  # This test suite is aiming to test the "defaults" for
  # this module, so it doesn't set any input variables
  # and just lets their default values be selected instead.
}

locals {
  outputs = {
    tags                        = module.main.tags
    vpc_id                      = module.main.vpc_ip
    vpc_arn                     = module.main.vpc_arn
    subnet_cidr_blocks_per_type = module.main.subnet_cidr_blocks_per_type
    subnet_ids_per_type         = module.main.subnet_ids_per_type
    kubernetes_api              = module.main.kubernetes_api
    kubernetes_ca_cert          = module.main.kubernetes_api_certificate_authority_data
    eks_details                 = module.main.eks_cluster
  }
}

data "aws_vpc" "eks_spoke" {
  id = module.main.vpc_ip
}

data "aws_subnets" "eks_spoke" {
  filter {
    name   = "vpc-id"
    values = [module.main.vpc_ip]
  }
}

/*
* Do not interpret Terraform tests as usual integration tests.
* A few characteristics of a Terraform test:
* - If the test relies on external resources, it is very expensive to run.
* - If a test fails, there is a high chance that Terraform won't be able to clean up the testing context.
* - Use the try() function in the got statement and make it fail if there are some networking issues.
* - Real tests take very long time to run.
* - terraform test is a blocking operation; it is not possible to hit test and change the context. Things can go wrong.
*   terraform test only supports create and destroy workflow.
*/
resource "test_assertions" "network_default_values_are" {
  component = "use_the_module_with_default_values"

  equal "vpc" {
    description = "has expected cidr block"
    got         = try(data.aws_vpc.eks_spoke.cidr_block, "10.0.0.0/8")
    want        = "10.0.0.0/16"
  }

  equal "subnets" {
    description = "are expected in number"
    got         = try(length(data.aws_subnets.eks_spoke.ids), 0)
    want        = 12
  }

  #  equal "a_subnet" {
  #    description = "picked casually, has expected cidr prefix"
  #    got = try(regex("/(\\d\\d)",data.aws_subnets.eks_spoke.ids[9]),["1",])
  #    want = ["20",]
  #  }
}
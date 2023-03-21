<!-- BEGIN_TF_DOCS -->
# terraform-aws-kubernetes minimal example

This example demonstrates how to use this Module with minimum input parameters.

## Compatibility

Use this module with Terraform 1.3.0+ version.

## Requirements

This Module requires that AWS CLI is available along the Terraform binary. It is necessary because
the Module manages the `aws_auth` Kubernetes ConfigMap. Notice that without this it won't be possible
to AWS users to access and use the Kubernetes API.

## Features

This example creates a fully operational Kubernetes cluster in AWS with minimal necessary input configurations.

## Instructions

### Assumptions

All the commands to deploy this example are meant to be executed from within the folder `minimal` and from the
command line interface.

### Steps

1. Login to your AWS account where you will be able to create the Module's resources;

2. `make terraform-up`;

3. To destroy all the resources created with the step 2 execute the command `make terraform-down`.


## Requirements

No requirements.
## Providers

No providers.
## Resources

No resources.
## Inputs

No inputs.
## Outputs

No outputs.
<!-- END_TF_DOCS -->
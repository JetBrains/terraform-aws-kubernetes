<!-- BEGIN_TF_DOCS -->
# deploy-a-few-apps-on-the-kubernetes-cluster

Show how to create a minimal Kubernetes cluster in the AWS Cloud and use this module to deploy/install some
Helm packages.

## Usage

### Requirements

This module assumes that the user will handle the configuration of the AWS provider such that the provider can
manage the life-cycle of resources created by this module.

```
make terraform-up
```

## Compatibility

Use this module with Terraform 1.3.0+ version.

### Steps

1. Authenticate the deployment host with AWS;

2. Execute the command: `make terraform-up`;

3. Finally, destroy all the resources created with the step 2 execute the command `make terraform-down`.


## Requirements

No requirements.
## Providers

No providers.
## Resources

No resources.
## Inputs

No inputs.
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_values"></a> [values](#output\_values) | n/a |
<!-- END_TF_DOCS -->
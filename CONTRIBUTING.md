# Contributor's HandNotes

## Summary

This document details how to contribute to this Module.

## Terminology

This section details a list of terms that are commonly used in this guideline.

| Id  | Term                        | Definition                                                       |
|-----|-----------------------------|------------------------------------------------------------------|
| T0  | Local Environment (locally) | This term defines the Contributor's workstation.                 |
| T1  | Remote Environment (remote) | This term defines the Continuous Integration execution contenxt. |

## Prerequisites

### Tools

The instruments used to develop and maintain this Module are the following:

| Id  | Tool                 |
|-----|----------------------|
| I0  | Docker               |                
| I1  | Make                 |
| I2  | Terraform            |
| I3  | AWS CLI version 2    |
| I4  | terraform-compliance |
| I5  | Golang               |

Make sure to install them locally and to familiarize yourself with each of them.

## Contribution flow

This section details the main steps that are involved in the contribution flow of the Module.

### Clone this repository

```bash
git clone "${THIS_REPO_URL}"
```

### Create a branch locally and add your contributions

```bash
git checkout -b "${CONTRIBUTION_BRANCH_NAME}"
```

Add your contributions and run the following Make rules:

1. `make terraform-fmt`;
2. `make terraform-validate`;
3. `make terraform-sec`;
4. `make terratest-up`;
5. `make terraform-compliance-up`;
6. `make terraform-docs`.

### Update the documentation

Make sure to keep the README.md file up to date with your changes.

*Caveat*

Do not directly update the README.md file. Update the content of the `.terraform-docs.yaml` file.

### Create a pull request

In the *pull request* provide meaningful details about your changes.

Accompany the changes with meaningful tests in `terratest` and/or in `terraform-compliance`.

Consider augmenting the `examples` folder with a nice sample that showcases your contribution.
<a name="unreleased"></a>
## [Unreleased]

### Features
- add kubernetes node autoscaler and metrics server ([#29](/issues/29))
  
  
<a name="v0.16.0"></a>
## [v0.16.0] - 2023-02-20
### Bug Fixes
- eks node pool size and regenerate the docs
  - Kubernetes API Logs and Node Pool defaults between public interface and private interface
  - permissions of the karpenter node user to add a node to the EKS cluster
  
  ### Code Refactoring
- format terraform code
  - update the internal links in the GUIDES.md and add the sample default values for the Loki and Promtail
  - CI and the module ([#28](/issues/28))
  
  ### Features
- add the karpenter (node autoscaler) and metrics-server (central metrics aggregator)
  
  
<a name="v0.15.2"></a>
## [v0.15.2] - 2023-02-14
### Bug Fixes
- terraform formatting
  - single quotes in variables that enclose strings
  - enable the EKS control plane logging for all types
  
  ### Code Refactoring
- examples and improve the main README
  - improve the formatting of the Terraform Code
  - ci activities, missing tags and improve the unit tests
  - **tests:** [compliance] improve the tests for the verification of tags
  
  ### Features
- add Loki as a logging system to the Kubernetes cluster
  
  
<a name="v0.15.1"></a>
## [v0.15.1] - 2023-01-30
### Code Refactoring
- **actions:** [changelog] add latest-tag and option to generate unreleased commits #patch
  - **actions:** [changelog] add latest-tag and option to generate unreleased commits #patch
  - **actions:** [changelog] allow the creation of unreleased tags #patch ([#26](/issues/26))
  - **actions:** [changelog] rename the commit_author ([#25](/issues/25))
  
  
<a name="v0.15.0"></a>
## [v0.15.0] - 2023-01-30
### Code Refactoring
- **actions:** [changelog] add latest-tag and option to generate unreleased commits
  
  
<a name="v0.14.0"></a>
## [v0.14.0] - 2023-01-30
### Code Refactoring
- **actions:** [changelog] rename the commit_author
  - **actions:** rename a few of them ([#24](/issues/24))
  
  
<a name="v0.13.0"></a>
## [v0.13.0] - 2023-01-30
### Code Refactoring
- **actions:** [terraform-pull-request] rename steps and rename the job name of tfsec
  - **actions:** [dependabot] rename the step and refactor how the branch name is passed
  - **actions:** [changelog] rename the steps
  - **actions:** rename a few of them
  - **actions:** avoid conflict between changelog action triggers ([#22](/issues/22))
  
  
<a name="v0.12.1"></a>
## [v0.12.1] - 2023-01-30
### Code Refactoring
- **actions:** remove the trigger that activitates the changelog action to run on push on main branch
  
  ### Features
- **module:** add automatic generation of the changelog #patch ([#21](/issues/21))
  
  
<a name="v0.12.0"></a>
## [v0.12.0] - 2023-01-30
### Bug Fixes
- **changelog:** add the missing configuration folder
  
  ### Code Refactoring
- **actions:** [changelog] experiment with a new action/7
  - **actions:** [changelog] experiment with a new action/6
  - **actions:** [changelog] experiment with a new action/5
  - **actions:** [changelog] experiment with a new action/4
  - **actions:** [changelog] experiment with a new action/3
  - **actions:** [changelog] experiment with a new action/2
  - **actions:** [changelog] experiment with a new action
  - **changelog:** experiment with another github action
  
  ### Features
- **changelog:** add the yaml file for it
  - **dependabot:** add the yaml file for it
  
  ### Pull Requests
- Merge pull request [#20](/issues/20) from jetbrains-infra/eks/new-version/test/19.1.0
  
  
<a name="v0.11.0"></a>
## [v0.11.0] - 2023-01-27
### Bug Fixes
- remove the deprecated setting <node_security_group_ntp_ipv4_cidr_block> and adjust the data type for the cluster secrets encryption. Experiment to avoid starvation during the install of the cluster services
  
  ### Code Refactoring
- **gh-action:** [terratest] add the missing environment variables
  - **gh-action:** [terratest] add verbosity to the executor
  - **tests:** the golang script now orchestrates the execution of the samples in the examples folder
  
  ### Features
- update the documentation of the module/2 .terraform-docs.yaml
  - update the documentation of the module
  - refactor the root module that orchestrates the internal modules
  - remove the prometheus operator from the eks-extensions module
  - refactor the eks-cluster module
  - refactor the network for EKS such that it is isolated as a nested module
  
  
<a name="v0.10.0"></a>
## [v0.10.0] - 2023-01-14
### Pull Requests
- Merge pull request [#11](/issues/11) from jetbrains-infra/fix/docs/missing-designs
  
  
<a name="v0.9.0"></a>
## [v0.9.0] - 2022-12-07
### Bug Fixes
- **README:** missing designs
  
  ### Pull Requests
- Merge pull request [#10](/issues/10) from jetbrains-infra/feat/add-k8s-paackage-releaser-module
  
  
<a name="v0.8.0"></a>
## [v0.8.0] - 2022-12-07
### Code Refactoring
- **module:** the eks extensions as a module
  - **module:** fix the example to showcase how to expose TCP proxies and also improve the quality of the root module
  
  ### Features
- **cluster-services:** complete the repeatable installation of prom-operator, public and private ingress controllers
  - **cluster_services:** add the main cluster services
  - **k8s-helm-packages:** complete the TF wrapper for helm_releaser
  - **module:** [cluster-services] implement the central place for Helm deployments
  
  ### Pull Requests
- Merge pull request [#7](/issues/7) from jetbrains-infra/dependabot/terraform/main/terraform-aws-modules/eks/aws-18.31.2
  
  
<a name="v0.7.0"></a>
## [v0.7.0] - 2022-12-07
### Pull Requests
- Merge pull request [#6](/issues/6) from jetbrains-infra/dependabot/terraform/main/terraform-aws-modules/eks/aws-18.31.1
  
  
<a name="v0.6.0"></a>
## [v0.6.0] - 2022-12-05
### Pull Requests
- Merge pull request [#5](/issues/5) from jetbrains-infra/dependabot/terraform/main/terraform-aws-modules/eks/aws-18.31.0
  
  
<a name="v0.5.0"></a>
## [v0.5.0] - 2022-11-22
### Pull Requests
- Merge pull request [#4](/issues/4) from jetbrains-infra/dependabot/terraform/main/terraform-aws-modules/eks/aws-18.30.3
  
  
<a name="v0.4.0"></a>
## [v0.4.0] - 2022-11-08
### Pull Requests
- Merge pull request [#3](/issues/3) from jetbrains-infra/docs/add-tests
  
  
<a name="v0.3.0"></a>
## [v0.3.0] - 2022-11-04
### Pull Requests
- Merge pull request [#2](/issues/2) from jetbrains-infra/release/version/v0.0.0
  - Merge pull request [#1](/issues/1) from jetbrains-infra/dependabot/terraform/main/terraform-aws-modules/vpc/aws-3.18.1
  
  
<a name="v0.2.0"></a>
## [v0.2.0] - 2022-11-01
### Bug Fixes
- **terraform:** formatting
  
  ### Features
- **terraform-test:** add a sample integration test
  - **terratest:** add another approach for testing the infra code
  
  
<a name="v0.1.0"></a>
## v0.1.0 - 2022-11-01

[Unreleased]: /compare/v0.16.0...HEAD
[v0.16.0]: /compare/v0.15.2...v0.16.0
[v0.15.2]: /compare/v0.15.1...v0.15.2
[v0.15.1]: /compare/v0.15.0...v0.15.1
[v0.15.0]: /compare/v0.14.0...v0.15.0
[v0.14.0]: /compare/v0.13.0...v0.14.0
[v0.13.0]: /compare/v0.12.1...v0.13.0
[v0.12.1]: /compare/v0.12.0...v0.12.1
[v0.12.0]: /compare/v0.11.0...v0.12.0
[v0.11.0]: /compare/v0.10.0...v0.11.0
[v0.10.0]: /compare/v0.9.0...v0.10.0
[v0.9.0]: /compare/v0.8.0...v0.9.0
[v0.8.0]: /compare/v0.7.0...v0.8.0
[v0.7.0]: /compare/v0.6.0...v0.7.0
[v0.6.0]: /compare/v0.5.0...v0.6.0
[v0.5.0]: /compare/v0.4.0...v0.5.0
[v0.4.0]: /compare/v0.3.0...v0.4.0
[v0.3.0]: /compare/v0.2.0...v0.3.0
[v0.2.0]: /compare/v0.1.0...v0.2.0

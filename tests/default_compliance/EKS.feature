Feature: EKS related general feature

	Scenario Outline: Ensure Amazon EKS control plane logging enabled the mandatory logs
		Given I have aws_eks_cluster defined
		Then it must have enabled_cluster_log_types
		Then it must contain <value>

		Examples:
			| value 				|
			| api 					|
			| audit					|

	Scenario : Ensure Amazon EKS Log Group has retention set to 14 days
		Given I have aws_eks_cluster defined
		Given I have aws_cloudwatch_log_group defined
		Then it must have retention_in_days
		And its value must contain 14

 	# The Tool (terraform-compliance) by default skips the test cases if it cannot find a resource with the test.
	@no-skip
	Scenario Outline: Ensure Amazon EKS has specific plugins enabled
		Given I have aws_eks_cluster defined
		Given I have aws_eks_addon defined
		When its index is <value>

		Examples:
			| value 				|
			| coredns 				|
			| kube-proxy            |
			| vpc-cni               |

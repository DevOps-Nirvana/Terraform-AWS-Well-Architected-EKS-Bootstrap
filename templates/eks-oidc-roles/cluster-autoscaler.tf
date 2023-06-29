data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    sid    = "AllowNecessaryDescribes"
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeScalingActivities",
      "autoscaling:DescribeTags",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplateVersions",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AllowNecessaryWrites"
    effect = "Allow"
    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
    ]
    resources = [
      "arn:aws:autoscaling:${var.aws_region}:${data.aws_caller_identity.current.account_id}:autoScalingGroup:*:autoScalingGroupName/eksctl-${var.eks_cluster_name}-nodegroup-*",
    ]
  }
}

module "cluster_autoscaler" {
  source = "../../../modules/eks-oidc-iam-role"

  # The (prefix) name of the role to be created
  name = "cluster-autoscaler"

  # Specify the EKS Cluster's OIDC ARN and URL
  # TODO: Make this a lookup so we don't need to get all three manually...?
  eks_cluster_name = var.eks_cluster_name
  eks_oidc_arn = var.eks_oidc_arn
  eks_oidc_url = var.eks_oidc_url

  # To restrict access to a specific namespace and service account you must specify them here
  role_policy_namespace = "infrastructure"
  role_policy_service_account = "cluster-autoscaler-aws-cluster-autoscaler"

  # This is the policy we want to grant to our role
  aws_iam_policy_json = data.aws_iam_policy_document.cluster_autoscaler.json
}

output "cluster_autoscaler_arn" {
  value = module.cluster_autoscaler.arn
}

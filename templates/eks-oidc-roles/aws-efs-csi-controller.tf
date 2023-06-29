data "aws_iam_policy_document" "aws_efs_csi_controller" {
  statement {
    sid    = "AllowEFSCSIController"
    effect = "Allow"
    actions = [
      "ec2:DescribeAvailabilityZones",
      "elasticfilesystem:CreateAccessPoint",
      "elasticfilesystem:DeleteAccessPoint",
      "elasticfilesystem:DescribeAccessPoints",
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:DescribeMountTargets",
      "elasticfilesystem:TagResource",
    ]
    resources = ["*"]
  }
}

module "aws_efs_csi_controller" {
  source = "../../../modules/eks-oidc-iam-role"

  # The (prefix) name of the role to be created
  name = "aws-efs-csi-controller"

  # Specify the EKS Cluster's OIDC ARN and URL
  # TODO: Make this a lookup so we don't need to get all three manually...?
  eks_cluster_name = var.eks_cluster_name
  eks_oidc_arn     = var.eks_oidc_arn
  eks_oidc_url     = var.eks_oidc_url

  # For dev we don't care it can be in any namespaces for branch-based deploys
  role_policy_template = "all"

  # This is the policy we want to grant to our role
  aws_iam_policy_json = data.aws_iam_policy_document.aws_efs_csi_controller.json
}

output "aws_efs_csi_controller_arn" {
  value = module.aws_efs_csi_controller.arn
}

# TODO MOVE EFS CREATION INTO TERRAFORM!!!
# Created efs-dev = fs-02fce7eb979719ef6


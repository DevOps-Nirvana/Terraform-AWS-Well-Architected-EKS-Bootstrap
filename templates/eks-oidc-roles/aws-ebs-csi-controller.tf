data "aws_iam_policy_document" "aws_ebs_csi_controller" {
  statement {
    sid    = "AllowEBSCSIController"
    effect = "Allow"
    actions = [
      "ec2:CreateSnapshot",
      "ec2:AttachVolume",
      "ec2:DetachVolume",
      "ec2:ModifyVolume",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInstances",
      "ec2:DescribeSnapshots",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DescribeVolumesModifications",
      "ec2:CreateVolume",
      "ec2:DeleteVolume",
      "ec2:DeleteSnapshot",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "sts:AssumeRoleWithWebIdentity"
    ]
    resources = ["*"]
  }
}

module "aws_ebs_csi_controller" {
  source = "../../../modules/eks-oidc-iam-role"

  # The (prefix) name of the role to be created
  name = "aws-ebs-csi-controller"

  # Specify the EKS Cluster's OIDC ARN and URL
  # TODO: Make this a lookup so we don't need to get all three manually...?
  eks_cluster_name = var.eks_cluster_name
  eks_oidc_arn = var.eks_oidc_arn
  eks_oidc_url = var.eks_oidc_url

  # For dev we don't care it can be in any namespaces for branch-based deploys
  role_policy_template = "all"

  # This is the policy we want to grant to our role
  aws_iam_policy_json = data.aws_iam_policy_document.aws_ebs_csi_controller.json
}

output "aws_ebs_csi_controller_arn" {
  value = module.aws_ebs_csi_controller.arn
}

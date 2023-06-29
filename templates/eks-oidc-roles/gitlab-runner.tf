data "aws_iam_policy_document" "gitlab_runner" {
  statement {
    sid    = "AllowEKSDescribeAndECRFull"
    effect = "Allow"
    actions = [
      "eks:DescribeCluster",
      "eks:ListClusters",
      # Note: Modify ECR:* to be least-privilege please!
      "ecr:*",
      # Needed for Gitlab Runner to be able to push cache...
      "sts:AssumeRoleWithWebIdentity",
      "sts:AssumeRole"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowS3GlobalDescribes"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowS3FullAccessToGitlabBucket"
    effect = "Allow"
    actions = [
      # To the entire bucket allow list/get/head
      "s3:List*",
      "s3:Get*",
      "s3:HeadObject",
      # Allow KMS for entire bucket to ensure encryption-at-rest
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = [
      "arn:aws:s3:::REPLACE_ME_WITH_GITLAB_BUCKET",
      "arn:aws:s3:::REPLACE_ME_WITH_GITLAB_BUCKET/*"
    ]
  }

  statement {
    sid    = "AllowS3AccessToGitlabRunnerSubfolder"
    effect = "Allow"
    actions = [
      # Only for our gitlab-runner subfolder do we allow deletes and writes
      "s3:DeleteObject",
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]
    resources = [
      "arn:aws:s3:::REPLACE_ME_WITH_GITLAB_BUCKET/gitlab_runner/*",
    ]
  }

}


module "gitlab_runner" {
  source = "../../../modules/eks-oidc-iam-role"

  # The (prefix) name of the role to be created
  name = "gitlab-runner"

  # Specify the EKS Cluster's OIDC ARN and URL
  # TODO: Make this a lookup so we don't need to get all three manually...?
  eks_cluster_name = var.eks_cluster_name
  eks_oidc_arn = var.eks_oidc_arn
  eks_oidc_url = var.eks_oidc_url

  role_policy_template = "all"
  # To restrict access to a specific namespace and service account you must specify them here
  # role_policy_namespace = "infrastructure"
  # role_policy_service_account = "cluster-autoscaler-aws-cluster-autoscaler"

  # This is the policy we want to grant to our role
  aws_iam_policy_json = data.aws_iam_policy_document.gitlab_runner.json
}

output "gitlab_runner_arn" {
  value = module.gitlab_runner.arn
}

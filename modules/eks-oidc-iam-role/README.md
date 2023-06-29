# Terraform AWS OIDC IAM Role Module

_Originally Authored by: Farley_

This module allows someone to easily create an OIDC (openid connect) compatible role on AWS for use in Kubernetes.  This allows for you to map a service account in Kubernetes into an AWS IAM Role.  This is a built-in feature from AWS on EKS clusters.

 * See: https://fika.works/blog/eks-service-accounts/
 * See: https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts-technical-overview.html

```hcl
#################
# This is the policy document you must create to pass into the module
#################
data "aws_iam_policy_document" "my_document" {
  statement {
    sid    = "AllowSomeAccess"
    effect = "Allow"
    actions = [
      "s3:PutObject*"
    ]
    resources = ["arn:aws:s3:::bucketname-*/*"]
  }
  statement {
    sid    = "AllowAllListObjectsAndGetBucketList"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucke*",
    ]
    resources = ["*"]
  }
}

#################
# This module and the variables you'll need to know and/or set
#################
module "my_iam_role" {
  source = "../terraform-aws-eks-oidc-iam-role"

  # The (prefix) name of the role to be created
  name = "my-iam-role"

  # The name of the EKS cluster (used to get the oidc ARN)
  # NOTE: If creation of this module fails with the error "EntityAlreadyExists", then go into the IAM Providers screen and
  #       find the one for your cluster and specify it in the two variables just underneath this one.  See the URL...
  #  See: https://console.aws.amazon.com/iam/home?region=us-east-1#/providers  (change the region as necessary)
  eks_cluster_name = "eks-ci"

  # Alternatively, specify the OIDC ARN and URL... if not specified it will create the OIDC provider (can only do once per EKS cluster)
  # eks_oidc_arn = "arn:aws:iam::981633883189:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/B173F585023E9427B4AF0AB30F1749FD"
  # eks_oidc_url = "https://oidc.eks.us-east-1.amazonaws.com/id/B173F585023E9427B4AF0AB30F1749FD"

  # This should be set to "all" or "conditional".  For least-privilege please set this to "conditional"
  #   (the default value) and specify the two role_policy variables below...
  role_policy_template = "all"

  # See above, if conditional is set you must specify the namespace and service account that is allowed to assume this role.
  # role_policy_namespace = "kube-system"
  # role_policy_service_account = "cluster-autoscaler-aws-cluster-autoscaler"

  # This is the policy we want to grant to our role
  aws_iam_policy_json = data.aws_iam_policy_document.my_document.json
}

output "my-oidc-arn" {
  value = module.my_iam_role.oidc_arn
}
output "my-oidc-url" {
  value = module.my_iam_role.oidc_url
}
output "my-role-arn" {
  value = module.my_iam_role.arn
}
output "my-role-name" {
  value = module.my_iam_role.name
}
```

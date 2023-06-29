data "aws_iam_policy_document" "github_runner" {
  statement {
    sid    = "AllowECRPullAndPush"
    effect = "Allow"
    actions = [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:GetAuthorizationToken",
        "ecr:CreateRepository",
        "eks:List*",
        "eks:DescribeCluster",
     ]
    resources = ["*"]
  }
}


module "github_runner" {
  source = "../../../modules/eks-oidc-iam-role"

  # The (prefix) name of the role to be created
  name = "github-runner"

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
  aws_iam_policy_json = data.aws_iam_policy_document.github_runner.json
}

output "github_runner_arn" {
  value = module.github_runner.arn
}




#################
# This attaches our policy from inside our oidc/irsa to our user
#################
# Generate an IAM user as well for github _for github runners_ needed incase of a static key
resource "aws_iam_user" "github_actions" {
  name = "github-runner"
}
resource "aws_iam_user_policy_attachment" "github_actions" {
  user       = aws_iam_user.github_actions.name
  policy_arn = module.github_runner.policy_arn
}

#
# resource "aws_iam_role_policy_attachment" "github_actions" {
#   role       = aws_iam_role.github_actions.name
#   policy_arn = aws_iam_policy.github_actions.arn
#   depends_on = [aws_iam_role.github_actions]
# }

# Generate an access/secret key
resource "aws_iam_access_key" "github_actions" {
  user = aws_iam_user.github_actions.name
  pgp_key = "keybase:farleyfarley"
}

output "AWS_ACCESS_KEY_ID" {
  description = "The access key ID"
  value = aws_iam_access_key.github_actions.id
}

output "AWS_SECRET_ACCESS_KEY_ENCRYPTED" {
  description = "The encrypted secret, base64 encoded"
  value       = aws_iam_access_key.github_actions.encrypted_secret
}

output "AWS_SECRET_ACCESS_KEY_DECRYPTED" {
  description = "Decrypt access secret key command"
  value       = <<EOF
echo "${aws_iam_access_key.github_actions.encrypted_secret}" | base64 --decode | keybase pgp decrypt
EOF
}

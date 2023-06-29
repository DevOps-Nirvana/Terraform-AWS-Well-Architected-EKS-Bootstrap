#################
# This is the OIDC provider that is creates for this EKS cluster to allow auth, this should only be done once, and only if we're creating the OIDC
#################
resource "aws_iam_openid_connect_provider" "default" {
  count           = length(var.eks_oidc_arn) > 0 ? 0 : 1
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.external.thumbprint.result.thumbprint]
  url             = length(data.aws_eks_cluster.default.0.identity) > 0 ? data.aws_eks_cluster.default.0.identity.0.oidc.0.issuer : null
}

#################
# This is the primary IAM role that is being created by this module
#################
resource "aws_iam_role" "default" {
  name_prefix = "${var.name}-"
  assume_role_policy =  templatefile("${path.module}/oidc_assume_role_policy_${var.role_policy_template}.json",
    {
      OIDC_ARN = local.oidc_arn,
      OIDC_URL = local.oidc_url,
      NAMESPACE = var.role_policy_namespace,
      SA_NAME = var.role_policy_service_account
    })
  tags = var.tags
}

#################
# This attaches our policy to our role
#################
resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.default.name
  policy_arn = aws_iam_policy.default.arn
  depends_on = [aws_iam_role.default]
}

#################
# This is the actual policy which includes the policy document json that is passed into this module
#################
resource "aws_iam_policy" "default" {
  name_prefix = "${var.name}-"
  description = "${var.name} - EKS policy for k8s service"
  policy      = var.aws_iam_policy_json
}

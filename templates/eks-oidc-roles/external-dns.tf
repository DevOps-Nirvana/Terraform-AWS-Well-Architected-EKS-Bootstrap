data "aws_iam_policy_document" "external_dns" {
  statement {
    sid    = "AllowNecessaryDescribes"
    effect = "Allow"
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AllowNecessaryWrites"
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
    ]
    resources = [
      "arn:aws:route53:::hostedzone/${var.route53_zone_id}",
    ]
  }
}

module "external_dns" {
  source = "../../../modules/eks-oidc-iam-role"

  # The (prefix) name of the role to be created
  name = "external-dns"

  # Specify the EKS Cluster's OIDC ARN and URL
  # TODO: Make this a lookup so we don't need to get all three manually...?
  eks_cluster_name = var.eks_cluster_name
  eks_oidc_arn = var.eks_oidc_arn
  eks_oidc_url = var.eks_oidc_url

  # role_policy_template = "all"
  # To restrict access to a specific namespace and service account you must specify them here
  role_policy_namespace = "infrastructure"
  role_policy_service_account = "external-dns"

  # This is the policy we want to grant to our role
  aws_iam_policy_json = data.aws_iam_policy_document.external_dns.json
}

output "external_dns_arn" {
  value = module.external_dns.arn
}

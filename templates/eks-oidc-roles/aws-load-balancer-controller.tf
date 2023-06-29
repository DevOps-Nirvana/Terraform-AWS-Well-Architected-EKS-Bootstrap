data "aws_iam_policy_document" "aws_load_balancer_controller" {
  statement {
    # Simplifed from: https://github.com/kubernetes-sigs/aws-load-balancer-controller/blob/main/docs/install/iam_policy.json
    sid    = "AllowNecessaryDescribes"
    effect = "Allow"
    actions = [
      "iam:CreateServiceLinkedRole",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeVpcs",
      "ec2:DescribeVpcPeeringConnections",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeInstances",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeTags",
      "ec2:GetCoipPoolUsage",
      "ec2:DescribeCoipPools",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeListenerCertificates",
      "elasticloadbalancing:DescribeSSLPolicies",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:DescribeTags",
      "cognito-idp:DescribeUserPoolClient",
      "acm:ListCertificates",
      "acm:DescribeCertificate",
      "iam:ListServerCertificates",
      "iam:GetServerCertificate",
      "waf-regional:GetWebACL",
      "waf-regional:GetWebACLForResource",
      "waf-regional:AssociateWebACL",
      "waf-regional:DisassociateWebACL",
      "wafv2:GetWebACL",
      "wafv2:GetWebACLForResource",
      "wafv2:AssociateWebACL",
      "wafv2:DisassociateWebACL",
      "shield:GetSubscriptionState",
      "shield:DescribeProtection",
      "shield:CreateProtection",
      "shield:DeleteProtection",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:DeleteSecurityGroup",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSecurityGroups",
      "elasticloadbalancing:SetSubnets",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:SetWebAcl",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:AddListenerCertificates",
      "elasticloadbalancing:RemoveListenerCertificates",
      "elasticloadbalancing:ModifyRule",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AllowNecessaryWritesEC2"
    effect = "Allow"
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:DeleteSecurityGroup",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:RevokeSecurityGroupIngress",
    ]
    # TODO: Target more specifically for more security, if desired
    resources = [
      "*",
    ]
  }

  statement {
    sid    = "AllowNecessaryWritesELB"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:AddListenerCertificates",
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:ModifyRule",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:RemoveListenerCertificates",
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSecurityGroups",
      "elasticloadbalancing:SetSubnets",
      "elasticloadbalancing:SetWebACL",
    ]
    # TODO: Target more specifically for more security, if desired
    resources = [
      "*",
    ]
  }


  statement {
    sid    = "AllowNecessaryWritesIAM"
    effect = "Allow"
    actions = [
      "iam:CreateServiceLinkedRole",
    ]
    # TODO: Target more specifically for more security, if desired
    resources = [
      "*",
    ]
  }



  statement {
    sid    = "AllowNecessaryWritesWAF"
    effect = "Allow"
    actions = [
      "waf-regional:AssociateWebACL",
      "waf-regional:DisassociateWebACL",
      "waf:GetWebACL",
      "wafv2:GetWebACL",
      "wafv2:GetWebACLForResource",
      "wafv2:AssociateWebACL",
      "wafv2:DisassociateWebACL",
    ]
    # TODO: Target more specifically for more security, if desired
    resources = [
      "*",
    ]
  }


  statement {
    sid    = "AllowNecessaryWritesTags"
    effect = "Allow"
    actions = [
      "tag:GetResources",
      "tag:TagResources",
    ]
    # TODO: Target more specifically for more security, if desired
    resources = [
      "*",
    ]
  }

    statement {
      sid    = "AllowNecessaryWritesShield"
      effect = "Allow"
      actions = [
        "shield:DeleteProtection",
        "shield:CreateProtection",
      ]
      # TODO: Target more specifically for more security, if desired
      resources = [
        "*",
      ]
    }
}

module "aws_load_balancer_controller" {
  source = "../../../modules/eks-oidc-iam-role"

  # The (prefix) name of the role to be created
  name = "aws-load-balancer-controller"

  # Specify the EKS Cluster's OIDC ARN and URL
  # TODO: Make this a lookup so we don't need to get all three manually...?
  eks_cluster_name = var.eks_cluster_name
  eks_oidc_arn = var.eks_oidc_arn
  eks_oidc_url = var.eks_oidc_url

  # role_policy_template = "all"
  # To restrict access to a specific namespace and service account you must specify them here
  role_policy_namespace = "infrastructure"
  role_policy_service_account = "aws-load-balancer-controller"
  # role_policy_service_account = "aws-load-balancer-controller-aws-aws-load-balancer-controller"

  # This is the policy we want to grant to our role
  aws_iam_policy_json = data.aws_iam_policy_document.aws_load_balancer_controller.json
}

output "aws_load_balancer_controller_arn" {
  value = module.aws_load_balancer_controller.arn
}

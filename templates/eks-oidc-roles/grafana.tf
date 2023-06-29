data "aws_iam_policy_document" "grafana" {
  statement {
    sid    = "AllowReadingMetricsFromCloudWatch"
    effect = "Allow"
    actions = [
        "cloudwatch:DescribeAlarmsForMetric",
        "cloudwatch:DescribeAlarmHistory",
        "cloudwatch:DescribeAlarms",
        "cloudwatch:ListMetrics",
        "cloudwatch:GetMetricStatistics",
        "cloudwatch:GetMetricData",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowReadingLogsFromCloudWatch"
    effect = "Allow"
    actions = [
        "logs:DescribeLogGroups",
        "logs:GetLogGroupFields",
        "logs:StartQuery",
        "logs:StopQuery",
        "logs:GetQueryResults",
        "logs:GetLogEvents",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowReadingTagsInstancesRegionsFromEC2"
    effect = "Allow"
    actions = [
      "ec2:DescribeTags",
      "ec2:DescribeInstances",
      "ec2:DescribeRegions",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowReadingResourcesForTags"
    effect = "Allow"
    actions = [
      "tag:GetResources",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowBillingReadonly"
    effect = "Allow"
    actions = [
      "aws-portal:ViewBilling",
      "aws-portal:ViewAccount",
      "aws-portal:ViewUsage",
      "budgets:ViewBudget",
      "budgets:CreateBudgetAction",
      "budgets:DescribeBudgetAction",
      "budgets:DescribeBudgetActionHistories",
      "budgets:DescribeBudgetActionsForAccount",
      "budgets:DescribeBudgetActionsForBudget",
      "cur:DescribeReportDefinitions",
      "ce:GetPreferences",
      "ce:DescribeReport",
      "ce:DescribeNotificationSubscription",
      "ce:DescribeCostCategoryDefinition",
      "ce:ListCostCategoryDefinitions",
      "ce:GetAnomalyMonitors",
      "ce:GetAnomalySubscriptions",
      "ce:GetAnomalies",
      "pricing:DescribeServices",
      "pricing:GetAttributeValues",
      "pricing:GetProducts",
      "purchase-orders:ViewPurchaseOrders"
    ]
    # TODO: Target more specifically for more security, if desired eg: dev-* prefixed resources
    resources = ["*"]
  }

}


module "grafana" {
  source = "../../../modules/eks-oidc-iam-role"

  # The (prefix) name of the role to be created
  name = "grafana"

  # Specify the EKS Cluster's OIDC ARN and URL
  # TODO: Make this a lookup so we don't need to get all three manually...?
  eks_cluster_name = var.eks_cluster_name
  eks_oidc_arn = var.eks_oidc_arn
  eks_oidc_url = var.eks_oidc_url

  # To restrict access to a specific namespace and service account you must specify them here
  # Temporarily allowing all so we can use this for Komiser
  role_policy_template = "all"
  # role_policy_namespace = "infrastructure"
  # role_policy_service_account = "grafana"

  # This is the policy we want to grant to our role
  aws_iam_policy_json = data.aws_iam_policy_document.grafana.json
}

output "grafana_arn" {
  value = module.grafana.arn
}

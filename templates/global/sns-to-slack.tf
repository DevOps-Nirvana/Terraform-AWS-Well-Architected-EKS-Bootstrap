#######################################
# Stack: sns-to-slack
# Purpose: Creates an SNS topic which automatically published to slack.  Intended for Cloudwatch Alerts Account-Wide
#######################################

######### Resource definitions #########

resource "aws_sns_topic" "sns_to_slack" {
  name = "sns-to-slack"
}

resource "aws_sns_topic_policy" "sns_to_slack" {
  arn    = aws_sns_topic.sns_to_slack.arn
  policy = data.aws_iam_policy_document.sns_to_slack.json
}

data "aws_iam_policy_document" "sns_to_slack" {
  statement {
    sid     = "AllowAccessToSNSForAnythingWithinOurAccount"
    effect  = "Allow"
    actions = [
      "SNS:GetTopicAttributes",
      "SNS:SetTopicAttributes",
      "SNS:AddPermission",
      "SNS:RemovePermission",
      "SNS:Subscribe",
      "SNS:ListSubscriptionsByTopic",
      "SNS:Publish",
      "SNS:Receive"
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [aws_sns_topic.sns_to_slack.arn]
    condition {
        test = "StringEquals"
        variable = "AWS:SourceOwner"
        values = [
            data.aws_caller_identity.current.account_id,
        ]
    }
  }

  statement {
    sid     = "AllowCoreAWSServicesToPublish"
    effect  = "Allow"
    actions = ["SNS:Publish"]
    principals {
      type        = "Service"
      identifiers = [
        "events.amazonaws.com",
        "guardduty.amazonaws.com",
        "budgets.amazonaws.com",
        "cloudwatch.amazonaws.com",
      ]
    }
    resources = [aws_sns_topic.sns_to_slack.arn]
  }
}


module "sns_to_slack" {
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "5.6.0"

  # Configure our module
  sns_topic_name    = aws_sns_topic.sns_to_slack.name
  create_sns_topic  = false
  slack_webhook_url = var.slack_webhook_url
  slack_channel     = "devops-${var.environment}" # Automatically gets determined from env name
  slack_username    = "AWS SNS To Slack for ${var.environment}"

  tags = module.terraform_tags.tags_no_name
}

######### Outputs #########

output "sns_to_slack_arn" {
  value = module.sns_to_slack.this_slack_topic_arn
}

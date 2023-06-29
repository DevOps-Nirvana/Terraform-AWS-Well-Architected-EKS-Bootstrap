# Create the Customer Master Key
resource "aws_kms_key" "this" {
  description             = "${var.environment} KMS Key"
  deletion_window_in_days = 15
  policy                  = data.aws_iam_policy_document.this.json
  tags                    = merge( module.terraform_tags.tags_no_name,{ "Name" = "${var.environment} KMS Key" } )
}

output "kms_key_arn" {
  value = aws_kms_key.this.arn
}


data "aws_iam_policy_document" "this" {

  statement {
    sid       = "Allow key administrators and assumed superadmins to do everything administrator-ey to the key"
    effect    = "Allow"
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
      "kms:Tag*",
      "kms:Untag*",
    ]
    principals {
      type        = "AWS"
      identifiers = concat(
        var.kms_key_administrator_iam_arns,
        local.additional_kms_key_admins
      )
    }
    resources = ["*"]
  }

  statement {
    sid       = "Allow users to encrypt, decrypt key"
    effect    = "Allow"
    actions   = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:ReEncrypt*"
    ]
    principals {
      type        = "AWS"
      identifiers = concat(
        var.kms_key_administrator_iam_arns,
        local.additional_kms_key_users
      )
    }
    resources = ["*"]
  }

  statement {
    sid       = "Allow EKS to encrypt, decrypt key"
    effect    = "Allow"
    actions   = [
      "kms:Decryp*",
      "kms:DescribeKey",
      "kms:Encry*",
      "kms:GenerateDataKey",
      "kms:ReEncrypt*"
    ]
    principals {
        type        = "Service"
        identifiers = ["eks.amazonaws.com"]
    }
    resources = ["*"]
  }

  statement {
    sid       = "Allow entire account to describe/view key NEEDED FOR EKS UPGRADES"
    effect    = "Allow"
    actions   = [
      "kms:DescribeKey",
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    resources = ["*"]
  }

}


locals {
  additional_kms_key_admins = []
  additional_kms_key_users = []
}



  # Enable EKS service to encrypt secrets and decrypt
#   statement {
#     sid       = "Allow EKS service to encrypt secrets and decrypt"
#     effect    = "Allow"
#     resources = ["*"]
#     actions   = [
#       "kms:GenerateDataKey*",
#       "kms:DescribeKey",
#     ]
#
#     principals {
#       type        = "*"
#       identifiers = ["*"]
#     }

#     condition {
#       test     = "StringEquals"
#       variable = "kms:CallerAccount"
#       values   = [data.aws_caller_identity.current.account_id]
#     }
#
#     condition {
#       test     = "StringEquals"
#       variable = "kms:ViaService"
#       values   = ["eks.${var.aws_region}.amazonaws.com"]
#     }
  # }

#   # Grant certain IAM ARNs the ability to decrypt CloudTrail logs, but no management rights.
#   statement {
#     sid       = "Grant CloudTrail log decrypt permissions"
#     effect    = "Allow"
#     resources = ["*"]
#     actions   = ["kms:Decrypt"]
#
#     principals {
#       type        = "AWS"
#       identifiers = var.kms_key_user_iam_arns
#     }
#
#     condition {
#       test     = "Null"
#       variable = "kms:EncryptionContext:aws:cloudtrail:arn"
#       values   = ["false"]
#     }
#   }

  # # Grant certain IAM ARNs full management rights, but no usage/decrypt rights.
  # statement {
  #   sid       = "Grant administrator privileges on the CloudTrail KMS CMK"
  #   effect    = "Allow"
  #   resources = ["*"]
  #
  #   actions = [
  #     "kms:Create*",
  #     "kms:Describe*",
  #     "kms:Enable*",
  #     "kms:List*",
  #     "kms:Put*",
  #     "kms:Update*",
  #     "kms:Revoke*",
  #     "kms:Disable*",
  #     "kms:Get*",
  #     "kms:Delete*",
  #     "kms:ScheduleKeyDeletion",
  #     "kms:CancelKeyDeletion",
  #     "kms:Tag*",
  #     "kms:Untag*",
  #   ]
  #
  #   principals {
  #     type        = "AWS"
  #     identifiers = var.kms_key_administrator_iam_arns
  #   }
  # }
  #
  # # If var.allow_kms_access_with_iam is true, grant the root AWS Account ID full permissions to the key,
  # # which has the effect of enabling IAM Policies to control permissions to the CMK.
  # statement {
  #   sid       = var.allow_kms_access_with_iam ? "Enable use of IAM Policies" : "This statement has no effect"
  #   effect    = "Allow"
  #   resources = ["*"]
  #   actions   = [var.allow_kms_access_with_iam ? "kms:*" : ""]
  #
  #   principals {
  #     type        = "AWS"
  #     identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
  #   }
  # }
# }

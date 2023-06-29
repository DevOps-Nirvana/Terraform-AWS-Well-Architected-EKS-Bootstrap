###########################################################################
# Stack: cloudtrail.tf                                                    #
# Purpose: Sets cloudtrail up to spit logs into our Shared AWS Account to #
#          ensure a unified and delegated source of truth and auditing    #
###########################################################################

######### Input Variables #########

variable "archive_log_data_after" {
  description = "After this number of days log files should be transitioned to Glacier"
  type        = number
  default     = 30
}

variable "delete_log_data_after" {
  description = "After this number of days, log files should be deleted from S3. Default: 0 (never delete logs)"
  type        = number
  default     = 180
}

variable "allow_cloudtrail_access_with_iam" {
  description = "If true, an IAM Policy that grants access to CloudTrail will be honored. If false, only the ARNs listed in var.kms_key_user_iam_arns will have access to CloudTrail and any IAM Policy grants will be ignored. (true or false)"
  type        = bool
  default     = true
}

variable "cloudtrail_name" {
  description = "The name of your CloudTrail.  Typically and simply your company name"
  type        = string
  # default     = "companyname"
}

######### Resources #########

# Create the S3 Bucket where S3 objects will be ARCHIVED after so many days
resource "aws_s3_bucket" "cloudtrail" {
  bucket        = local.cloudtrail_bucket_name
  policy        = data.aws_iam_policy_document.cloudtrail_s3_bucket_policy.json

  force_destroy = false
  tags          = merge( module.terraform_tags.tags,{ "Name" = local.cloudtrail_bucket_name } )

  # This is incase a log accidentally gets overwritten, should never happen though
  versioning {
    enabled = true
  }

  # Always encryption at rest forced
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.cloudtrail.id
        sse_algorithm     = "aws:kms"
      }
    }
  }

  # Automatically archive a log file into glacier after X days (30 by default)
  lifecycle_rule {
    id                                     = "archive-to-glacier-after-${var.archive_log_data_after}-days"
    prefix                                 = ""
    enabled                                = true
    abort_incomplete_multipart_upload_days = 7

    # Transition into Glacier
    transition {
      days          = var.archive_log_data_after
      storage_class = "GLACIER"
    }

    # If we want to eventually delete log data, lets do that...
    dynamic "expiration" {
      for_each = var.delete_log_data_after == 0 ? [] : [1]
      content {
        days = var.delete_log_data_after
      }
    }

    dynamic "noncurrent_version_expiration" {
      for_each = var.delete_log_data_after == 0 ? [] : [1]
      content {
        days = var.delete_log_data_after
      }
    }
  }
}

# We want to make this bucket never be public
resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

# Define an S3 Bucket Policy to allow CloudTrail to send lgos here
data "aws_iam_policy_document" "cloudtrail_s3_bucket_policy" {
  statement {
    sid       = "AllowCloudTrailToCheckS3BucketACL"
    effect    = "Allow"
    actions   = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::${local.cloudtrail_bucket_name}"]

    principals {
      type = "Service"
      identifiers = [
        "cloudtrail.amazonaws.com",
        "config.amazonaws.com",
      ]
    }
  }

  # Enable the CloudTrail service to write to this S3 Bucket
  statement {
    sid       = "AllowCloudTrailToWriteToS3"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${local.cloudtrail_bucket_name}/AWSLogs/*"]

    principals {
      type = "Service"
      identifiers = [
        "cloudtrail.amazonaws.com",
        "config.amazonaws.com",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  # Allow AWS Config to read from S3
  statement {
    sid       = "AllowConfigToReadFromS3"
    effect    = "Allow"
    actions   = ["s3:Get*"]
    resources = ["arn:aws:s3:::${local.cloudtrail_bucket_name}/AWSLogs/*"]

    principals {
      type = "Service"
      identifiers = [
        "config.amazonaws.com",
      ]
    }
  }
}


# This makes it so items uploaded are immediately owned by the bucket owner account, making it easier to get to
resource "aws_s3_bucket_ownership_controls" "cloudtrail_with_logs_archived" {
  bucket = aws_s3_bucket.cloudtrail.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Create the Customer Master Key
resource "aws_kms_key" "cloudtrail" {
  description             = "${module.terraform_tags.id} CloudTrail"
  deletion_window_in_days = 15
  policy                  = data.aws_iam_policy_document.cloudtrail_key_policy.json
  tags                    = merge( module.terraform_tags.tags,{ "Name" = "${module.terraform_tags.id} CloudTrail" } )
}

# See: http://docs.aws.amazon.com/awscloudtrail/latest/userguide/create-kms-key-policy-for-cloudtrail.html.
data "aws_iam_policy_document" "cloudtrail_key_policy" {
  # Enable CloudTrail service to encrypt logs.
  statement {
    sid       = "Allow CloudTrail service to encrypt logs"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["kms:GenerateDataKey*"]

    principals {
      type        = "Service"
      identifiers = [
        "cloudtrail.amazonaws.com",
        "config.amazonaws.com",
      ]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"]
    }
  }

  # Enable CloudTrail service to describe KMS CMK properties
  statement {
    sid       = "Enable CloudTrail service to describe KMS CMK properties"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["kms:DescribeKey"]

    principals {
      type        = "Service"
      identifiers = [
        "cloudtrail.amazonaws.com",
        "config.amazonaws.com",
      ]
    }
  }

  # Grant certain IAM ARNs the ability to decrypt CloudTrail logs, but no management rights.
  statement {
    sid       = "Grant CloudTrail log decrypt permissions"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["kms:Decrypt"]

    principals {
      type        = "AWS"
      identifiers = var.kms_key_user_iam_arns
    }

    condition {
      test     = "Null"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["false"]
    }
  }

  # Grant certain IAM ARNs full management rights, but no usage rights.
  statement {
    sid       = "Grant administrator privileges on the CloudTrail KMS CMK"
    effect    = "Allow"
    resources = ["*"]

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
      identifiers = var.kms_key_administrator_iam_arns
    }
  }

  # If var.allow_cloudtrail_access_with_iam is true, grant the root AWS Account ID full permissions to the key, which has the effect of enabling IAM Policies to control permissions to the CMK.
  statement {
    sid       = var.allow_cloudtrail_access_with_iam ? "Enable use of IAM Policies" : "This statement has no effect"
    effect    = "Allow"
    resources = ["*"]
    actions   = [var.allow_cloudtrail_access_with_iam ? "kms:*" : ""]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

# Create a friendly alias for the KMS Customer Master Key
resource "aws_kms_alias" "cloudtrail" {
  name          = "alias/cloudtrail-${var.environment}-${var.cloudtrail_name}"
  target_key_id = aws_kms_key.cloudtrail.id
}

# Enable Cloudtrail
resource "aws_cloudtrail" "cloudtrail" {
  name                  = var.cloudtrail_name
  s3_bucket_name        = local.cloudtrail_bucket_name
  is_multi_region_trail = true

  # Capture API events from global services such as IAM.
  include_global_service_events = true

  # Have CloudFront generate a file of hashes of all original log files so that we can use a CLI tool to validate log
  # file integrity. See http://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-log-file-validation-cli.html
  enable_log_file_validation = true

  # Encrypt all CloudWatch Logs with the KMS Key created above.
  kms_key_id = aws_kms_key.cloudtrail.arn

  tags = merge( module.terraform_tags.tags,{ "Name" = "cloudtrail-${var.cloudtrail_name}" } )

  depends_on = [
    aws_s3_bucket.cloudtrail,
  ]
}

######### Outputs #########

output "trail_arn" {
  value = coalesce(aws_cloudtrail.cloudtrail.arn, "not-yet")
}

output "cloudtrail_bucket_name" {
  value = local.cloudtrail_bucket_name
}

output "kms_key_arn" {
  value = aws_kms_key.cloudtrail.arn
}

output "kms_key_alias_name" {
  value = aws_kms_alias.cloudtrail.name
}

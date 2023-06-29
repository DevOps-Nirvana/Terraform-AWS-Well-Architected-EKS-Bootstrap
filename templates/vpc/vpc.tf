module "vpc" {
  source = "../../../modules/simple-vpc/"

  name                = var.environment
  cidr                = var.global_cidrs[var.environment]
  is_highly_available = var.is_production_ready

  # This is so our VPC is named of our environment properly
  tags = module.terraform_tags.tags_no_name

  # This is for flow logs
  enable_flow_log = false
  # flow_log_cloudwatch_log_group_kms_key_id = aws_kms_key.vpc.arn
  flow_log_cloudwatch_log_group_retention_in_days = 30
  flow_log_destination_type = "s3"
  flow_log_max_aggregation_interval = 600
  flow_log_destination_arn = aws_s3_bucket.vpc.arn
}

# Create an s3 bucket for VPC flow logs
resource "aws_s3_bucket" "vpc" {
  acl    = "private"
  bucket = "${local.stack_name}-${data.aws_caller_identity.current.account_id}-${var.environment}-vpc-flow-logs"
  tags = merge (
    { "Name" = "${local.stack_name}-${data.aws_caller_identity.current.account_id}-${var.environment}-vpc-flow-logs" },
    module.terraform_tags.tags_no_name
  )

  # For compliance we always want s3 bucket encryption (encrypted files at-rest)
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.vpc.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

# We want to make this bucket never be public
resource "aws_s3_bucket_public_access_block" "vpc" {
  bucket = aws_s3_bucket.vpc.id
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}


# Create the Customer Master Key
resource "aws_kms_key" "vpc" {
  description             = "${module.terraform_tags.id} VPC Flow Logs KMS Key"
  deletion_window_in_days = 15
  policy                  = data.aws_iam_policy_document.vpc.json
  tags                    = merge( module.terraform_tags.tags_no_name,{ "Name" = "${module.terraform_tags.id} VPC Flow Logs KMS Key" } )
}

# Create a friendly alias for the KMS Customer Master Key
resource "aws_kms_alias" "vpc" {
  name          = "alias/${module.terraform_tags.id}-vpc-flow-logs"
  target_key_id = aws_kms_key.vpc.id
}

# Setup an IAM Policy for vpc KMS key to restrict access to admins only to encrypt/decrypt vpc data, it is sensitive!
data "aws_iam_policy_document" "vpc" {
  statement {
    sid       = "TEMPORARY Allow EVERYTHING to all for now TODO restrict access"
    effect    = "Allow"
    resources = ["*"]
    actions   = [
      "kms:*"
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

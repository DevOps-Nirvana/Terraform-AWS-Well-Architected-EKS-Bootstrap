  # Make it optional to use KMS
variable "s3_bucket_enable_kms" {
  description = "Whether or not we want KMS enabled (encrypted S3 contents)"
  type        = bool
  default     = true
}

variable "s3_bucket_override_name" {
  description = "Whether or not we to override the bucket name"
  type        = string
  default     = ""
}

variable "s3_bucket_add_org_account_role" {
  description = "Whether or not we add the account id org role (assume role superuser from aws orgs)"
  type        = bool
  default     = false
}

variable "s3_bucket_allow_public_objects" {
  description = "Whether or not we allow the bucket objects to be public"
  type        = bool
  default     = false
}

variable "s3_bucket_lifecycle_rule" {
  description = "List of maps containing configuration of object lifecycle management."
  type        = any
  default     = []
}

variable "s3_bucket_cors_rule" {
  description = "List of maps containing rules for Cross-Origin Resource Sharing."
  type        = any
  default     = []
}

variable "s3_website" {
  description = "Map containing static web-site hosting or redirect configuration."
  type        = map(string)
  default     = {}
}

variable "s3_grant" {
  description = "An ACL policy grant. Conflicts with `acl`"
  type        = any
  default     = []
}



# Create the Customer Master Key, if we want KMS enabled
resource "aws_kms_key" "s3_bucket" {
  count                   = var.s3_bucket_enable_kms ? 1 : 0
  description             = "${module.terraform_tags.id} KMS Key"
  deletion_window_in_days = 15
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.s3_bucket_kms.json
  tags                    = merge( module.terraform_tags.tags_no_name,{ "Name" = "${module.terraform_tags.id} KMS Key" } )
}

# Create a friendly alias for the KMS Customer Master Key, if we want KMS enabled
resource "aws_kms_alias" "s3_bucket" {
  count         = var.s3_bucket_enable_kms ? 1 : 0
  name          = "alias/${module.terraform_tags.id}"
  target_key_id = aws_kms_key.s3_bucket.0.id
}

# Setup an IAM Policy for this KMS key to restrict access to admins only to encrypt/decrypt this data, it is sensitive!
data "aws_iam_policy_document" "s3_bucket_kms" {
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
        var.s3_bucket_add_org_account_role ? ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/OrganizationAccountAccessRole"] : [],
        local.additional_kms_key_admins
      )
    }
    resources = ["*"]
  }

  statement {
    sid       = "Allow users to decrypt and use key"
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
        var.s3_bucket_add_org_account_role ? ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/OrganizationAccountAccessRole"] : [],
        local.additional_kms_key_users
      )
    }
    resources = ["*"]
  }
}


#############
# S3 Bucket #
#############

# Create/update our S3 bucket
resource "aws_s3_bucket" "s3_bucket" {
  bucket = coalesce(
    var.s3_bucket_override_name,
    "${module.terraform_tags.id}-${data.aws_caller_identity.current.account_id}-${var.aws_region}"
  )

  # If we want KMS...
  dynamic "server_side_encryption_configuration" {
    for_each = var.s3_bucket_enable_kms ? tolist([aws_kms_key.s3_bucket.0.arn]) : []

    content {
      rule {
        apply_server_side_encryption_by_default {
          kms_master_key_id = server_side_encryption_configuration.value
          sse_algorithm     = "aws:kms"
        }
      }
    }
  }

  dynamic "cors_rule" {
    for_each = try(jsondecode(var.s3_bucket_cors_rule), var.s3_bucket_cors_rule)

    content {
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      allowed_headers = lookup(cors_rule.value, "allowed_headers", null)
      expose_headers  = lookup(cors_rule.value, "expose_headers", null)
      max_age_seconds = lookup(cors_rule.value, "max_age_seconds", null)
    }
  }

  # If we want a grant rule(s)
  # Copied from https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/blob/master/main.tf
  dynamic "grant" {
    for_each = try(jsondecode(var.s3_grant), var.s3_grant)

    content {
      id          = lookup(grant.value, "id", null)
      type        = grant.value.type
      permissions = grant.value.permissions
      uri         = lookup(grant.value, "uri", null)
    }
  }

  # If we want a static website rule
  # Copied from https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/blob/master/main.tf
  dynamic "website" {
    for_each = length(keys(var.s3_website)) == 0 ? [] : [var.s3_website]

    content {
      index_document           = lookup(website.value, "index_document", null)
      error_document           = lookup(website.value, "error_document", null)
      redirect_all_requests_to = lookup(website.value, "redirect_all_requests_to", null)
      routing_rules            = lookup(website.value, "routing_rules", null)
    }
  }

  # If we want a lifecycle/expiration rule
  # Copied from https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/blob/master/main.tf
  dynamic "lifecycle_rule" {
    for_each = try(jsondecode(var.s3_bucket_lifecycle_rule), var.s3_bucket_lifecycle_rule)

    content {
      id                                     = lookup(lifecycle_rule.value, "id", null)
      prefix                                 = lookup(lifecycle_rule.value, "prefix", null)
      tags                                   = lookup(lifecycle_rule.value, "tags", null)
      abort_incomplete_multipart_upload_days = lookup(lifecycle_rule.value, "abort_incomplete_multipart_upload_days", null)
      enabled                                = lifecycle_rule.value.enabled

      # Max 1 block - expiration
      dynamic "expiration" {
        for_each = length(keys(lookup(lifecycle_rule.value, "expiration", {}))) == 0 ? [] : [lookup(lifecycle_rule.value, "expiration", {})]

        content {
          date                         = lookup(expiration.value, "date", null)
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }

      # Several blocks - transition
      dynamic "transition" {
        for_each = lookup(lifecycle_rule.value, "transition", [])

        content {
          date          = lookup(transition.value, "date", null)
          days          = lookup(transition.value, "days", null)
          storage_class = transition.value.storage_class
        }
      }

      # Max 1 block - noncurrent_version_expiration
      dynamic "noncurrent_version_expiration" {
        for_each = length(keys(lookup(lifecycle_rule.value, "noncurrent_version_expiration", {}))) == 0 ? [] : [lookup(lifecycle_rule.value, "noncurrent_version_expiration", {})]

        content {
          days = lookup(noncurrent_version_expiration.value, "days", null)
        }
      }

      # Several blocks - noncurrent_version_transition
      dynamic "noncurrent_version_transition" {
        for_each = lookup(lifecycle_rule.value, "noncurrent_version_transition", [])

        content {
          days          = lookup(noncurrent_version_transition.value, "days", null)
          storage_class = noncurrent_version_transition.value.storage_class
        }
      }
    }
  }

  versioning {
    enabled = true
  }

  tags = merge(
          module.terraform_tags.tags_no_name,
          { "Name" = "${module.terraform_tags.id}-${data.aws_caller_identity.current.account_id}-${var.aws_region}" }
        )
}

# We want to make this bucket never be public
resource "aws_s3_bucket_public_access_block" "s3_bucket" {
  count = var.s3_bucket_allow_public_objects ? 0 : 1

  bucket                  = aws_s3_bucket.s3_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


###########
# Outputs #
###########

output "s3_bucket_name" {
  value = aws_s3_bucket.s3_bucket.id
}
output "s3_bucket_domain" {
  value = aws_s3_bucket.s3_bucket.bucket_domain_name
}
output "s3_bucket_regional_domain" {
  value = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
}
output "s3_bucket_kms_key_arn" {
  # This is a little nonsense Terraform trick to allow for an optional resource without errors
  value = coalesce(element(concat(aws_kms_key.s3_bucket.*.arn,[""]),0,), "not-used")
}
output "s3_bucket_kms_alias_arn" {
  # This is a little nonsense Terraform trick to allow for an optional resource without errors
  value = coalesce(element(concat(aws_kms_alias.s3_bucket.*.arn,[""]),0,), "not-used")
}

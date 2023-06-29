# Every stack has a name and a version, this is used in all the tags
locals {
  # The unique name of this stack.  This is typically copied from the folder name in our "templates" folder
  stack_name = "efs"
  # The version of this stack name, should always be 3 octets, major.minor.sub
  stack_version = "1.0.0"
}

# This pulls in our remote vpc stack variables from our project/stage/region subenvironment vpc
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "terraform-deploy-fragments-${data.aws_caller_identity.current.account_id}-${var.aws_region}"
    key    = "${var.client_name_short}-${var.environment}-${var.subenvironment != "" ? format("%s-", var.subenvironment) : ""}vpc.tfstate"
    region = var.aws_region
  }
}

# A helper module which generates our standardized tags for all objects
module "terraform_tags" {
  source = "../../../modules/terraform-tags"
  name   = local.stack_name
  stage  = var.subenvironment != "" ? var.subenvironment : var.environment
  tags   = tomap({ "StackVersion" = local.stack_version }) # Add more in here to add more tags for eg: tenants, or owners, or team names, etc.
}

# This is used in some templates for adding KMS support, and allowing eg: your application/role for this stack to allow it to read/write to that KMS
# Ignore/delete this if your stack isn't doing anything with KMS
locals {
  additional_kms_key_admins = []
  additional_kms_key_users  = []
}

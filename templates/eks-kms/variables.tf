# Every stack has a name and a version, this is used in all the tags
locals {
    # The unique name of this stack.  This is typically copied from the folder name
    stack_name = "eks-kms"
    # The version of this stack name, should always be 3 octets, major.minor.sub
    stack_version = "1.0.0"
}

# A helper module which generates our standardized tags for all objects
module "terraform_tags" {
    source     = "../../../modules/terraform-tags"
    name       = local.stack_name
    stage      = var.subenvironment != "" ? var.subenvironment : var.environment
    tags       = tomap({"StackVersion"=local.stack_version})
}

variable "allow_kms_access_with_iam" {
  description = "If true, an IAM Policy that grants access to this eks kms key will be honored. If false, only the ARNs listed in var.kms_key_user_iam_arns will have access to kms and any IAM Policy grants will be ignored. (true or false)"
  type        = bool
  default     = true
}

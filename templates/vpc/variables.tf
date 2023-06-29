# Every stack has a name and a version, this is used in all the tags
locals {
    # The unique name of this stack.  This is typically copied from the folder name
    stack_name = "vpc"
    # The version of this stack name, should always be 3 octets, major.minor.sub
    stack_version = "1.0.0"
}

# A helper module which generates our standardized tags for all objects
module "terraform_tags" {
    source     = "../../../modules/terraform-tags"
    name       = local.stack_name
    stage      = var.subenvironment != "" ? var.subenvironment : var.environment
    tags       = tomap({
        "StackVersion"=local.stack_version,
        "kubernetes.io/cluster/${var.subenvironment != "" ? var.subenvironment : var.environment}"="shared",
    })
}

# A simple flag that when enabled will make a variety of things properly highly available.  This will cost more
variable "is_production_ready" {
  type        = bool
  default     = false
  description = "A flag that when set to true will make things properly highly available.  This will cost more"
}

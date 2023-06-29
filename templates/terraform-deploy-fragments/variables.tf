# Every stack has a name and a version, this is used in all the tags
locals {
    # The unique name of this stack.  This is typically copied from the folder name
    stack_name = "terraform-deploy-fragments"
    # The version of this stack name, should always be 3 octets, major.minor.sub
    stack_version = "1.0.0"
}

# A helper module which generates our standardized tags for all objects
module "terraform_tags" {
    source     = "../../../modules/terraform-tags"
    name       = local.stack_name
    stage      = var.environment
    tags       = tomap({"StackVersion": local.stack_version})
}

locals {
  additional_kms_key_admins = []
  additional_kms_key_users = []
}

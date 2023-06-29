# Every stack has a name and a version, this is used in all the tags
locals {
    # The unique name of this stack.  This is typically copied from the folder name in our "templates" folder
    stack_name = "sns-to-slack"
    # The version of this stack name, should always be 3 octets, major.minor.sub
    stack_version = "1.0.0"
}

# A helper module which generates our standardized tags for all objects
module "terraform_tags" {
    source     = "../../../modules/terraform-tags"
    name       = local.stack_name
    stage      = var.subenvironment != "" ? var.subenvironment : var.environment
    tags       = tomap({"StackVersion"=local.stack_version}) # Add more in here to add more tags for eg: tenants, or owners, or team names, etc.
}

# This is used in some templates for adding KMS support, and allowing eg: your application/role for this stack to allow it to read/write to that KMS
# Ignore/delete this if your stack isn't doing anything with KMS
locals {
    additional_kms_key_admins = []
    additional_kms_key_users = []
}

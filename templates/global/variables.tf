# Every stack has a name and a version, this is used in all the tags
locals {
    # The unique name of this stack.  This is typically copied from the folder name
    stack_name = "global"
    # The version of this stack name, should always be 3 octets, major.minor.sub
    stack_version = "1.0.0"
    # The name of the cloudtrail bucket
    cloudtrail_bucket_name = "cloudtrail-${data.aws_caller_identity.current.account_id}-${var.aws_region}"
}

# A helper module which generates our standardized tags for all objects
module "terraform_tags" {
    source     = "../../modules/terraform-tags"
    name       = local.stack_name
    stage      = var.environment
    tags       = tomap({"StackVersion"=local.stack_version})
}

provider "aws" {
	region  = "us-east-1"  # You must edit this for the region you want to deploy to, cannot be read from a variable.  :(  Silly TF
}

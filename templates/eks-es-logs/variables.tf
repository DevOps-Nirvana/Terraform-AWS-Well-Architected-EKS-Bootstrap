# Every stack has a name and a version, this is used in all the tags
locals {
  # The unique name of this stack.  This is typically copied from the folder name
  stack_name = "eks-es-logs"
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

# This grabs our global remote state for the SNS to slack topic
data "terraform_remote_state" "sns-to-slack" {
  backend = "s3"
  config = {
    bucket = "terraform-deploy-fragments-${data.aws_caller_identity.current.account_id}-${var.aws_region}"
    key    = "${var.client_name_short}-${var.environment}-${var.subenvironment != "" ? format("%s-", var.subenvironment) : ""}sns-to-slack${contains(["dev", "stage"], var.environment) ? "-regional" : ""}.tfstate"
    # key    = "${var.client_name_short}-${var.environment}-sns-to-slack-regional.tfstate"
    region = var.aws_region
  }
}

# A helper module which generates our standardized tags for all objects
module "terraform_tags" {
  source = "../../../modules/terraform-tags"
  name   = local.stack_name
  stage  = var.subenvironment != "" ? var.subenvironment : var.environment
  tags   = tomap({ "StackVersion" = local.stack_version })
}

variable "elasticsearch_disk_size" {
  type        = string
  description = "The size of the disk (per node)"
  default     = "50" # In GB
}

variable "elasticsearch_instance_type" {
  description = "The elasticsearch instance type we want"
  type        = string
  default     = "t3.medium.search"
}

variable "elasticsearch_instance_count" {
  description = "The number of nodes in the elasticsearch cluster"
  type        = number
  default     = 2
}

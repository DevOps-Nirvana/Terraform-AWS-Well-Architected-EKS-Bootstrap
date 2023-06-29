# Here's our VPC module as a submodule initialized with automatic AZ and CIDR subnetting
module "vpc" {
  source = "../../../modules/simple-vpc/"

  # These are the few that we're overriding the logic for this module
  name = var.environment
  cidr = var.global_cidrs[var.environment]
  is_highly_available = var.is_production_ready

  # For less wasted overhead, we'll only go into 2 AZs instead of 3
  number_of_azs = 2

  # This is so our VPC is named of our environment properly
  tags =  module.terraform_tags.tags_no_name
}

# Output copied from upstream module verbatim from:
#   https://github.com/terraform-aws-modules/terraform-aws-vpc/blob/master/outputs.tf
#
# NOTE: Not a verbatim copy, because using it as a sub-module

output "vpc_id" {
  value = module.vpc.vpc_id
}
output "vpc_arn" {
  value = module.vpc.vpc_arn
}
output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}
output "default_security_group_id" {
  value = module.vpc.default_security_group_id
}
output "default_network_acl_id" {
  value = module.vpc.default_network_acl_id
}
output "default_route_table_id" {
  value = module.vpc.default_route_table_id
}
output "vpc_instance_tenancy" {
  value = module.vpc.vpc_instance_tenancy
}
output "vpc_enable_dns_support" {
  value = module.vpc.vpc_enable_dns_support
}
output "vpc_enable_dns_hostnames" {
  value = module.vpc.vpc_enable_dns_hostnames
}
output "vpc_main_route_table_id" {
  value = module.vpc.vpc_main_route_table_id
}
output "vpc_ipv6_association_id" {
  value = module.vpc.vpc_ipv6_association_id
}
output "vpc_ipv6_cidr_block" {
  value = module.vpc.vpc_ipv6_cidr_block
}
output "vpc_secondary_cidr_blocks" {
  value = module.vpc.vpc_secondary_cidr_blocks
}
output "vpc_owner_id" {
  value = module.vpc.vpc_owner_id
}
output "dhcp_options_id" {
  value = module.vpc.dhcp_options_id
}
output "igw_id" {
  value = module.vpc.igw_id
}
output "igw_arn" {
  value = module.vpc.igw_arn
}
output "public_subnets" {
  value = module.vpc.public_subnets
}
output "public_subnet_arns" {
  value = module.vpc.public_subnet_arns
}
output "public_subnets_cidr_blocks" {
  value = module.vpc.public_subnets_cidr_blocks
}
output "public_subnets_ipv6_cidr_blocks" {
  value = module.vpc.public_subnets_ipv6_cidr_blocks
}
output "public_route_table_ids" {
  value = module.vpc.public_route_table_ids
}
output "public_internet_gateway_route_id" {
  value = module.vpc.public_internet_gateway_route_id
}
output "public_internet_gateway_ipv6_route_id" {
  value = module.vpc.public_internet_gateway_ipv6_route_id
}
output "public_route_table_association_ids" {
  value = module.vpc.public_route_table_association_ids
}
output "public_network_acl_id" {
  value = module.vpc.public_network_acl_id
}
output "public_network_acl_arn" {
  value = module.vpc.public_network_acl_arn
}
output "private_subnets" {
  value = module.vpc.private_subnets
}
output "private_subnet_arns" {
  value = module.vpc.private_subnet_arns
}
output "private_subnets_cidr_blocks" {
  value = module.vpc.private_subnets_cidr_blocks
}
output "private_subnets_ipv6_cidr_blocks" {
  value = module.vpc.private_subnets_ipv6_cidr_blocks
}
output "private_route_table_ids" {
  value = module.vpc.private_route_table_ids
}
output "private_nat_gateway_route_ids" {
  value = module.vpc.private_nat_gateway_route_ids
}
output "private_ipv6_egress_route_ids" {
  value = module.vpc.private_ipv6_egress_route_ids
}
output "private_route_table_association_ids" {
  value = module.vpc.private_route_table_association_ids
}
output "private_network_acl_id" {
  value = module.vpc.private_network_acl_id
}
output "private_network_acl_arn" {
  value = module.vpc.private_network_acl_arn
}
output "outpost_subnets" {
  value = module.vpc.outpost_subnets
}
output "outpost_subnet_arns" {
  value = module.vpc.outpost_subnet_arns
}
output "outpost_subnets_cidr_blocks" {
  value = module.vpc.outpost_subnets_cidr_blocks
}
output "outpost_subnets_ipv6_cidr_blocks" {
  value = module.vpc.outpost_subnets_ipv6_cidr_blocks
}
output "outpost_network_acl_id" {
  value = module.vpc.outpost_network_acl_id
}
output "outpost_network_acl_arn" {
  value = module.vpc.outpost_network_acl_arn
}
output "database_subnets" {
  value = module.vpc.database_subnets
}
output "database_subnet_arns" {
  value = module.vpc.database_subnet_arns
}
output "database_subnets_cidr_blocks" {
  value = module.vpc.database_subnets_cidr_blocks
}
output "database_subnets_ipv6_cidr_blocks" {
  value = module.vpc.database_subnets_ipv6_cidr_blocks
}
output "database_subnet_group" {
  value = module.vpc.database_subnet_group
}
output "database_subnet_group_name" {
  value = module.vpc.database_subnet_group_name
}
output "database_route_table_ids" {
  value = module.vpc.database_route_table_ids
}
output "database_internet_gateway_route_id" {
  value = module.vpc.database_internet_gateway_route_id
}
output "database_nat_gateway_route_ids" {
  value = module.vpc.database_nat_gateway_route_ids
}
output "database_ipv6_egress_route_id" {
  value = module.vpc.database_ipv6_egress_route_id
}
output "database_route_table_association_ids" {
  value = module.vpc.database_route_table_association_ids
}
output "database_network_acl_id" {
  value = module.vpc.database_network_acl_id
}
output "database_network_acl_arn" {
  value = module.vpc.database_network_acl_arn
}
output "redshift_subnets" {
  value = module.vpc.redshift_subnets
}
output "redshift_subnet_arns" {
  value = module.vpc.redshift_subnet_arns
}
output "redshift_subnets_cidr_blocks" {
  value = module.vpc.redshift_subnets_cidr_blocks
}
output "redshift_subnets_ipv6_cidr_blocks" {
  value = module.vpc.redshift_subnets_ipv6_cidr_blocks
}
output "redshift_subnet_group" {
  value = module.vpc.redshift_subnet_group
}
output "redshift_route_table_ids" {
  value = module.vpc.redshift_route_table_ids
}
output "redshift_route_table_association_ids" {
  value = module.vpc.redshift_route_table_association_ids
}
output "redshift_public_route_table_association_ids" {
  value = module.vpc.redshift_public_route_table_association_ids
}
output "redshift_network_acl_id" {
  value = module.vpc.redshift_network_acl_id
}
output "redshift_network_acl_arn" {
  value = module.vpc.redshift_network_acl_arn
}
output "elasticache_subnets" {
  value = module.vpc.elasticache_subnets
}
output "elasticache_subnet_arns" {
  value = module.vpc.elasticache_subnet_arns
}
output "elasticache_subnets_cidr_blocks" {
  value = module.vpc.elasticache_subnets_cidr_blocks
}
output "elasticache_subnets_ipv6_cidr_blocks" {
  value = module.vpc.elasticache_subnets_ipv6_cidr_blocks
}
output "elasticache_subnet_group" {
  value = module.vpc.elasticache_subnet_group
}
output "elasticache_subnet_group_name" {
  value = module.vpc.elasticache_subnet_group_name
}
output "elasticache_route_table_ids" {
  value = module.vpc.elasticache_route_table_ids
}
output "elasticache_route_table_association_ids" {
  value = module.vpc.elasticache_route_table_association_ids
}
output "elasticache_network_acl_id" {
  value = module.vpc.elasticache_network_acl_id
}
output "elasticache_network_acl_arn" {
  value = module.vpc.elasticache_network_acl_arn
}
output "intra_subnets" {
  value = module.vpc.intra_subnets
}
output "intra_subnet_arns" {
  value = module.vpc.intra_subnet_arns
}
output "intra_subnets_cidr_blocks" {
  value = module.vpc.intra_subnets_cidr_blocks
}
output "intra_subnets_ipv6_cidr_blocks" {
  value = module.vpc.intra_subnets_ipv6_cidr_blocks
}
output "intra_route_table_ids" {
  value = module.vpc.intra_route_table_ids
}
output "intra_route_table_association_ids" {
  value = module.vpc.intra_route_table_association_ids
}
output "intra_network_acl_id" {
  value = module.vpc.intra_network_acl_id
}
output "intra_network_acl_arn" {
  value = module.vpc.intra_network_acl_arn
}
output "nat_ids" {
  value = module.vpc.nat_ids
}
output "nat_public_ips" {
  value = module.vpc.nat_public_ips
}
output "natgw_ids" {
  value = module.vpc.natgw_ids
}
output "egress_only_internet_gateway_id" {
  value = module.vpc.egress_only_internet_gateway_id
}
output "cgw_ids" {
  value = module.vpc.cgw_ids
}
output "cgw_arns" {
  value = module.vpc.cgw_arns
}
output "this_customer_gateway" {
  value = module.vpc.this_customer_gateway
}
output "vgw_id" {
  value = module.vpc.vgw_id
}
output "vgw_arn" {
  value = module.vpc.vgw_arn
}
output "default_vpc_id" {
  value = module.vpc.default_vpc_id
}
output "default_vpc_arn" {
  value = module.vpc.default_vpc_arn
}
output "default_vpc_cidr_block" {
  value = module.vpc.default_vpc_cidr_block
}
output "default_vpc_default_security_group_id" {
  value = module.vpc.default_vpc_default_security_group_id
}
output "default_vpc_default_network_acl_id" {
  value = module.vpc.default_vpc_default_network_acl_id
}
output "default_vpc_default_route_table_id" {
  value = module.vpc.default_vpc_default_route_table_id
}
output "default_vpc_instance_tenancy" {
  value = module.vpc.default_vpc_instance_tenancy
}
output "default_vpc_enable_dns_support" {
  value = module.vpc.default_vpc_enable_dns_support
}
output "default_vpc_enable_dns_hostnames" {
  value = module.vpc.default_vpc_enable_dns_hostnames
}
output "default_vpc_main_route_table_id" {
  value = module.vpc.default_vpc_main_route_table_id
}
output "vpc_flow_log_id" {
  value = module.vpc.vpc_flow_log_id
}
output "vpc_flow_log_destination_arn" {
  value = module.vpc.vpc_flow_log_destination_arn
}
output "vpc_flow_log_destination_type" {
  value = module.vpc.vpc_flow_log_destination_type
}
output "vpc_flow_log_cloudwatch_iam_role_arn" {
  value = module.vpc.vpc_flow_log_cloudwatch_iam_role_arn
}
output "azs" {
  value = module.vpc.azs
}
output "name" {
  value = module.vpc.name
}


# output "vpc_id" {
#   value = module.vpc.vpc_id
# }
# output "vpc_arn" {
#   value = module.vpc.vpc_arn
# }
# output "vpc_cidr_block" {
#   value = module.vpc.vpc_cidr_block
# }
# output "default_security_group_id" {
#   value = module.vpc.default_security_group_id
# }
# output "default_network_acl_id" {
#   value = module.vpc.default_network_acl_id
# }
# output "default_route_table_id" {
#   value = module.vpc.default_route_table_id
# }
# output "vpc_instance_tenancy" {
#   value = module.vpc.vpc_instance_tenancy
# }
# output "vpc_enable_dns_support" {
#   value = module.vpc.vpc_enable_dns_support
# }
# output "vpc_enable_dns_hostnames" {
#   value = module.vpc.vpc_enable_dns_hostnames
# }
# output "vpc_main_route_table_id" {
#   value = module.vpc.vpc_main_route_table_id
# }
# output "vpc_ipv6_association_id" {
#   value = module.vpc.vpc_ipv6_association_id
# }
# output "vpc_ipv6_cidr_block" {
#   value = module.vpc.vpc_ipv6_cidr_block
# }
# output "vpc_secondary_cidr_blocks" {
#   value = module.vpc.vpc_secondary_cidr_blocks
# }
# output "vpc_owner_id" {
#   value = module.vpc.vpc_owner_id
# }
# output "private_subnets" {
#   value = module.vpc.private_subnets
# }
# output "private_subnet_arns" {
#   value = module.vpc.private_subnet_arns
# }
# output "private_subnets_cidr_blocks" {
#   value = module.vpc.private_subnets_cidr_blocks
# }
# output "private_subnets_ipv6_cidr_blocks" {
#   value = module.vpc.private_subnets_ipv6_cidr_blocks
# }
# output "public_subnets" {
#   value = module.vpc.public_subnets
# }
# output "public_subnet_arns" {
#   value = module.vpc.public_subnet_arns
# }
# output "public_subnets_cidr_blocks" {
#   value = module.vpc.public_subnets_cidr_blocks
# }
# output "public_subnets_ipv6_cidr_blocks" {
#   value = module.vpc.public_subnets_ipv6_cidr_blocks
# }
# output "database_subnets" {
#   value = module.vpc.database_subnets
# }
# output "database_subnet_arns" {
#   value = module.vpc.database_subnet_arns
# }
# output "database_subnets_cidr_blocks" {
#   value = module.vpc.database_subnets_cidr_blocks
# }
# output "database_subnets_ipv6_cidr_blocks" {
#   value = module.vpc.database_subnets_ipv6_cidr_blocks
# }
# output "database_subnet_group" {
#   value = module.vpc.database_subnet_group
# }
# output "redshift_subnets" {
#   value = module.vpc.redshift_subnets
# }
# output "redshift_subnet_arns" {
#   value = module.vpc.redshift_subnet_arns
# }
# output "redshift_subnets_cidr_blocks" {
#   value = module.vpc.redshift_subnets_cidr_blocks
# }
# output "redshift_subnets_ipv6_cidr_blocks" {
#   value = module.vpc.redshift_subnets_ipv6_cidr_blocks
# }
# output "redshift_subnet_group" {
#   value = module.vpc.redshift_subnet_group
# }
# output "elasticache_subnets" {
#   value = module.vpc.elasticache_subnets
# }
# output "elasticache_subnet_arns" {
#   value = module.vpc.elasticache_subnet_arns
# }
# output "elasticache_subnets_cidr_blocks" {
#   value = module.vpc.elasticache_subnets_cidr_blocks
# }
# output "elasticache_subnets_ipv6_cidr_blocks" {
#   value = module.vpc.elasticache_subnets_ipv6_cidr_blocks
# }
# output "intra_subnets" {
#   value = module.vpc.intra_subnets
# }
# output "intra_subnet_arns" {
#   value = module.vpc.intra_subnet_arns
# }
# output "intra_subnets_cidr_blocks" {
#   value = module.vpc.intra_subnets_cidr_blocks
# }
# output "intra_subnets_ipv6_cidr_blocks" {
#   value = module.vpc.intra_subnets_ipv6_cidr_blocks
# }
# output "elasticache_subnet_group" {
#   value = module.vpc.elasticache_subnet_group
# }
# output "elasticache_subnet_group_name" {
#   value = module.vpc.elasticache_subnet_group_name
# }
# output "public_route_table_ids" {
#   value = module.vpc.public_route_table_ids
# }
# output "private_route_table_ids" {
#   value = module.vpc.private_route_table_ids
# }
# output "database_route_table_ids" {
#   value = module.vpc.database_route_table_ids
# }
# output "redshift_route_table_ids" {
#   value = module.vpc.redshift_route_table_ids
# }
# output "elasticache_route_table_ids" {
#   value = module.vpc.elasticache_route_table_ids
# }
# output "intra_route_table_ids" {
#   value = module.vpc.intra_route_table_ids
# }
# output "public_internet_gateway_route_id" {
#   value = module.vpc.public_internet_gateway_route_id
# }
# output "public_internet_gateway_ipv6_route_id" {
#   value = module.vpc.public_internet_gateway_ipv6_route_id
# }
# output "database_internet_gateway_route_id" {
#   value = module.vpc.database_internet_gateway_route_id
# }
# output "database_nat_gateway_route_ids" {
#   value = module.vpc.database_nat_gateway_route_ids
# }
# output "database_ipv6_egress_route_id" {
#   value = module.vpc.database_ipv6_egress_route_id
# }
# output "private_nat_gateway_route_ids" {
#   value = module.vpc.private_nat_gateway_route_ids
# }
# output "private_ipv6_egress_route_ids" {
#   value = module.vpc.private_ipv6_egress_route_ids
# }
# output "private_route_table_association_ids" {
#   value = module.vpc.private_route_table_association_ids
# }
# output "database_route_table_association_ids" {
#   value = module.vpc.database_route_table_association_ids
# }
# output "redshift_route_table_association_ids" {
#   value = module.vpc.redshift_route_table_association_ids
# }
# output "redshift_public_route_table_association_ids" {
#   value = module.vpc.redshift_public_route_table_association_ids
# }
# output "elasticache_route_table_association_ids" {
#   value = module.vpc.elasticache_route_table_association_ids
# }
# output "intra_route_table_association_ids" {
#   value = module.vpc.intra_route_table_association_ids
# }
# output "public_route_table_association_ids" {
#   value = module.vpc.public_route_table_association_ids
# }
# output "nat_ids" {
#   value = module.vpc.nat_ids
# }
# output "nat_public_ips" {
#   value = module.vpc.nat_public_ips
# }
# output "natgw_ids" {
#   value = module.vpc.natgw_ids
# }
# output "igw_id" {
#   value = module.vpc.igw_id
# }
# output "igw_arn" {
#   value = module.vpc.igw_arn
# }
# output "egress_only_internet_gateway_id" {
#   value = module.vpc.egress_only_internet_gateway_id
# }
# output "cgw_ids" {
#   value = module.vpc.cgw_ids
# }
# output "cgw_arns" {
#   value = module.vpc.cgw_arns
# }
# output "this_customer_gateway" {
#   value = module.vpc.this_customer_gateway
# }
# output "vgw_id" {
#   value = module.vpc.vgw_id
# }
# output "vgw_arn" {
#   value = module.vpc.vgw_arn
# }
# output "default_vpc_id" {
#   value = module.vpc.default_vpc_id
# }
# output "default_vpc_arn" {
#   value = module.vpc.default_vpc_arn
# }
# output "default_vpc_cidr_block" {
#   value = module.vpc.default_vpc_cidr_block
# }
# output "default_vpc_default_security_group_id" {
#   value = module.vpc.default_vpc_default_security_group_id
# }
# output "default_vpc_default_network_acl_id" {
#   value = module.vpc.default_vpc_default_network_acl_id
# }
# output "default_vpc_default_route_table_id" {
#   value = module.vpc.default_vpc_default_route_table_id
# }
# output "default_vpc_instance_tenancy" {
#   value = module.vpc.default_vpc_instance_tenancy
# }
# output "default_vpc_enable_dns_support" {
#   value = module.vpc.default_vpc_enable_dns_support
# }
# output "default_vpc_enable_dns_hostnames" {
#   value = module.vpc.default_vpc_enable_dns_hostnames
# }
# output "default_vpc_main_route_table_id" {
#   value = module.vpc.default_vpc_main_route_table_id
# }
# output "public_network_acl_id" {
#   value = module.vpc.public_network_acl_id
# }
# output "public_network_acl_arn" {
#   value = module.vpc.public_network_acl_arn
# }
# output "private_network_acl_id" {
#   value = module.vpc.private_network_acl_id
# }
# output "private_network_acl_arn" {
#   value = module.vpc.private_network_acl_arn
# }
# output "intra_network_acl_id" {
#   value = module.vpc.intra_network_acl_id
# }
# output "intra_network_acl_arn" {
#   value = module.vpc.intra_network_acl_arn
# }
# output "database_network_acl_id" {
#   value = module.vpc.database_network_acl_id
# }
# output "database_network_acl_arn" {
#   value = module.vpc.database_network_acl_arn
# }
# output "redshift_network_acl_id" {
#   value = module.vpc.redshift_network_acl_id
# }
# output "redshift_network_acl_arn" {
#   value = module.vpc.redshift_network_acl_arn
# }
# output "elasticache_network_acl_id" {
#   value = module.vpc.elasticache_network_acl_id
# }
# output "elasticache_network_acl_arn" {
#   value = module.vpc.elasticache_network_acl_arn
# }
# output "vpc_endpoint_s3_id" {
#   value = module.vpc.vpc_endpoint_s3_id
# }
# output "vpc_endpoint_s3_pl_id" {
#   value = module.vpc.vpc_endpoint_s3_pl_id
# }
# output "vpc_endpoint_dynamodb_id" {
#   value = module.vpc.vpc_endpoint_dynamodb_id
# }
# output "vpc_endpoint_dynamodb_pl_id" {
#   value = module.vpc.vpc_endpoint_dynamodb_pl_id
# }
# output "vpc_endpoint_sqs_id" {
#   value = module.vpc.vpc_endpoint_sqs_id
# }
# output "vpc_endpoint_sqs_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_sqs_network_interface_ids
# }
# output "vpc_endpoint_sqs_dns_entry" {
#   value = module.vpc.vpc_endpoint_sqs_dns_entry
# }
# output "vpc_endpoint_codebuild_id" {
#   value = module.vpc.vpc_endpoint_codebuild_id
# }
# output "vpc_endpoint_codebuild_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_codebuild_network_interface_ids
# }
# output "vpc_endpoint_codebuild_dns_entry" {
#   value = module.vpc.vpc_endpoint_codebuild_dns_entry
# }
# output "vpc_endpoint_codecommit_id" {
#   value = module.vpc.vpc_endpoint_codecommit_id
# }
# output "vpc_endpoint_codecommit_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_codecommit_network_interface_ids
# }
# output "vpc_endpoint_codecommit_dns_entry" {
#   value = module.vpc.vpc_endpoint_codecommit_dns_entry
# }
# output "vpc_endpoint_git_codecommit_id" {
#   value = module.vpc.vpc_endpoint_git_codecommit_id
# }
# output "vpc_endpoint_git_codecommit_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_git_codecommit_network_interface_ids
# }
# output "vpc_endpoint_git_codecommit_dns_entry" {
#   value = module.vpc.vpc_endpoint_git_codecommit_dns_entry
# }
# output "vpc_endpoint_config_id" {
#   value = module.vpc.vpc_endpoint_config_id
# }
# output "vpc_endpoint_config_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_config_network_interface_ids
# }
# output "vpc_endpoint_config_dns_entry" {
#   value = module.vpc.vpc_endpoint_config_dns_entry
# }
# output "vpc_endpoint_secretsmanager_id" {
#   value = module.vpc.vpc_endpoint_secretsmanager_id
# }
# output "vpc_endpoint_secretsmanager_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_secretsmanager_network_interface_ids
# }
# output "vpc_endpoint_secretsmanager_dns_entry" {
#   value = module.vpc.vpc_endpoint_secretsmanager_dns_entry
# }
# output "vpc_endpoint_ssm_id" {
#   value = module.vpc.vpc_endpoint_ssm_id
# }
# output "vpc_endpoint_ssm_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_ssm_network_interface_ids
# }
# output "vpc_endpoint_ssm_dns_entry" {
#   value = module.vpc.vpc_endpoint_ssm_dns_entry
# }
# output "vpc_endpoint_ssmmessages_id" {
#   value = module.vpc.vpc_endpoint_ssmmessages_id
# }
# output "vpc_endpoint_ssmmessages_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_ssmmessages_network_interface_ids
# }
# output "vpc_endpoint_ssmmessages_dns_entry" {
#   value = module.vpc.vpc_endpoint_ssmmessages_dns_entry
# }
# output "vpc_endpoint_ec2_id" {
#   value = module.vpc.vpc_endpoint_ec2_id
# }
# output "vpc_endpoint_ec2_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_ec2_network_interface_ids
# }
# output "vpc_endpoint_ec2_dns_entry" {
#   value = module.vpc.vpc_endpoint_ec2_dns_entry
# }
# output "vpc_endpoint_ec2messages_id" {
#   value = module.vpc.vpc_endpoint_ec2messages_id
# }
# output "vpc_endpoint_ec2messages_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_ec2messages_network_interface_ids
# }
# output "vpc_endpoint_ec2messages_dns_entry" {
#   value = module.vpc.vpc_endpoint_ec2messages_dns_entry
# }
# output "vpc_endpoint_ec2_autoscaling_id" {
#   value = module.vpc.vpc_endpoint_ec2_autoscaling_id
# }
# output "vpc_endpoint_ec2_autoscaling_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_ec2_autoscaling_network_interface_ids
# }
# output "vpc_endpoint_ec2_autoscaling_dns_entry" {
#   value = module.vpc.vpc_endpoint_ec2_autoscaling_dns_entry
# }
# output "vpc_endpoint_transferserver_id" {
#   value = module.vpc.vpc_endpoint_transferserver_id
# }
# output "vpc_endpoint_transferserver_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_transferserver_network_interface_ids
# }
# output "vpc_endpoint_transferserver_dns_entry" {
#   value = module.vpc.vpc_endpoint_transferserver_dns_entry
# }
# output "vpc_endpoint_glue_id" {
#   value = module.vpc.vpc_endpoint_glue_id
# }
# output "vpc_endpoint_glue_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_glue_network_interface_ids
# }
# output "vpc_endpoint_glue_dns_entry" {
#   value = module.vpc.vpc_endpoint_glue_dns_entry
# }
# output "vpc_endpoint_kms_id" {
#   value = module.vpc.vpc_endpoint_kms_id
# }
# output "vpc_endpoint_kms_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_kms_network_interface_ids
# }
# output "vpc_endpoint_kms_dns_entry" {
#   value = module.vpc.vpc_endpoint_kms_dns_entry
# }
# output "vpc_endpoint_kinesis_firehose_id" {
#   value = module.vpc.vpc_endpoint_kinesis_firehose_id
# }
# output "vpc_endpoint_kinesis_firehose_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_kinesis_firehose_network_interface_ids
# }
# output "vpc_endpoint_kinesis_firehose_dns_entry" {
#   value = module.vpc.vpc_endpoint_kinesis_firehose_dns_entry
# }
# output "vpc_endpoint_kinesis_streams_id" {
#   value = module.vpc.vpc_endpoint_kinesis_streams_id
# }
# output "vpc_endpoint_kinesis_streams_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_kinesis_streams_network_interface_ids
# }
# output "vpc_endpoint_kinesis_streams_dns_entry" {
#   value = module.vpc.vpc_endpoint_kinesis_streams_dns_entry
# }
# output "vpc_endpoint_ecr_api_id" {
#   value = module.vpc.vpc_endpoint_ecr_api_id
# }
# output "vpc_endpoint_ecr_api_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_ecr_api_network_interface_ids
# }
# output "vpc_endpoint_ecr_api_dns_entry" {
#   value = module.vpc.vpc_endpoint_ecr_api_dns_entry
# }
# output "vpc_endpoint_ecr_dkr_id" {
#   value = module.vpc.vpc_endpoint_ecr_dkr_id
# }
# output "vpc_endpoint_ecr_dkr_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_ecr_dkr_network_interface_ids
# }
# output "vpc_endpoint_ecr_dkr_dns_entry" {
#   value = module.vpc.vpc_endpoint_ecr_dkr_dns_entry
# }
# output "vpc_endpoint_apigw_id" {
#   value = module.vpc.vpc_endpoint_apigw_id
# }
# output "vpc_endpoint_apigw_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_apigw_network_interface_ids
# }
# output "vpc_endpoint_apigw_dns_entry" {
#   value = module.vpc.vpc_endpoint_apigw_dns_entry
# }
# output "vpc_endpoint_ecs_id" {
#   value = module.vpc.vpc_endpoint_ecs_id
# }
# output "vpc_endpoint_ecs_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_ecs_network_interface_ids
# }
# output "vpc_endpoint_ecs_dns_entry" {
#   value = module.vpc.vpc_endpoint_ecs_dns_entry
# }
# output "vpc_endpoint_ecs_agent_id" {
#   value = module.vpc.vpc_endpoint_ecs_agent_id
# }
# output "vpc_endpoint_ecs_agent_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_ecs_agent_network_interface_ids
# }
# output "vpc_endpoint_ecs_agent_dns_entry" {
#   value = module.vpc.vpc_endpoint_ecs_agent_dns_entry
# }
# output "vpc_endpoint_ecs_telemetry_id" {
#   value = module.vpc.vpc_endpoint_ecs_telemetry_id
# }
# output "vpc_endpoint_ecs_telemetry_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_ecs_telemetry_network_interface_ids
# }
# output "vpc_endpoint_ecs_telemetry_dns_entry" {
#   value = module.vpc.vpc_endpoint_ecs_telemetry_dns_entry
# }
# output "vpc_endpoint_sns_id" {
#   value = module.vpc.vpc_endpoint_sns_id
# }
# output "vpc_endpoint_sns_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_sns_network_interface_ids
# }
# output "vpc_endpoint_sns_dns_entry" {
#   value = module.vpc.vpc_endpoint_sns_dns_entry
# }
# output "vpc_endpoint_monitoring_id" {
#   value = module.vpc.vpc_endpoint_monitoring_id
# }
# output "vpc_endpoint_monitoring_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_monitoring_network_interface_ids
# }
# output "vpc_endpoint_monitoring_dns_entry" {
#   value = module.vpc.vpc_endpoint_monitoring_dns_entry
# }
# output "vpc_endpoint_logs_id" {
#   value = module.vpc.vpc_endpoint_logs_id
# }
# output "vpc_endpoint_logs_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_logs_network_interface_ids
# }
# output "vpc_endpoint_logs_dns_entry" {
#   value = module.vpc.vpc_endpoint_logs_dns_entry
# }
# output "vpc_endpoint_events_id" {
#   value = module.vpc.vpc_endpoint_events_id
# }
# output "vpc_endpoint_events_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_events_network_interface_ids
# }
# output "vpc_endpoint_events_dns_entry" {
#   value = module.vpc.vpc_endpoint_events_dns_entry
# }
# output "vpc_endpoint_elasticloadbalancing_id" {
#   value = module.vpc.vpc_endpoint_elasticloadbalancing_id
# }
# output "vpc_endpoint_elasticloadbalancing_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_elasticloadbalancing_network_interface_ids
# }
# output "vpc_endpoint_elasticloadbalancing_dns_entry" {
#   value = module.vpc.vpc_endpoint_elasticloadbalancing_dns_entry
# }
# output "vpc_endpoint_cloudtrail_id" {
#   value = module.vpc.vpc_endpoint_cloudtrail_id
# }
# output "vpc_endpoint_cloudtrail_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_cloudtrail_network_interface_ids
# }
# output "vpc_endpoint_cloudtrail_dns_entry" {
#   value = module.vpc.vpc_endpoint_cloudtrail_dns_entry
# }
# output "vpc_endpoint_sts_id" {
#   value = module.vpc.vpc_endpoint_sts_id
# }
# output "vpc_endpoint_sts_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_sts_network_interface_ids
# }
# output "vpc_endpoint_sts_dns_entry" {
#   value = module.vpc.vpc_endpoint_sts_dns_entry
# }
# output "vpc_endpoint_cloudformation_id" {
#   value = module.vpc.vpc_endpoint_cloudformation_id
# }
# output "vpc_endpoint_cloudformation_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_cloudformation_network_interface_ids
# }
# output "vpc_endpoint_cloudformation_dns_entry" {
#   value = module.vpc.vpc_endpoint_cloudformation_dns_entry
# }
# output "vpc_endpoint_codepipeline_id" {
#   value = module.vpc.vpc_endpoint_codepipeline_id
# }
# output "vpc_endpoint_codepipeline_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_codepipeline_network_interface_ids
# }
# output "vpc_endpoint_codepipeline_dns_entry" {
#   value = module.vpc.vpc_endpoint_codepipeline_dns_entry
# }
# output "vpc_endpoint_appmesh_envoy_management_id" {
#   value = module.vpc.vpc_endpoint_appmesh_envoy_management_id
# }
# output "vpc_endpoint_appmesh_envoy_management_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_appmesh_envoy_management_network_interface_ids
# }
# output "vpc_endpoint_appmesh_envoy_management_dns_entry" {
#   value = module.vpc.vpc_endpoint_appmesh_envoy_management_dns_entry
# }
# output "vpc_endpoint_servicecatalog_id" {
#   value = module.vpc.vpc_endpoint_servicecatalog_id
# }
# output "vpc_endpoint_servicecatalog_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_servicecatalog_network_interface_ids
# }
# output "vpc_endpoint_servicecatalog_dns_entry" {
#   value = module.vpc.vpc_endpoint_servicecatalog_dns_entry
# }
# output "vpc_endpoint_storagegateway_id" {
#   value = module.vpc.vpc_endpoint_storagegateway_id
# }
# output "vpc_endpoint_storagegateway_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_storagegateway_network_interface_ids
# }
# output "vpc_endpoint_storagegateway_dns_entry" {
#   value = module.vpc.vpc_endpoint_storagegateway_dns_entry
# }
# output "vpc_endpoint_transfer_id" {
#   value = module.vpc.vpc_endpoint_transfer_id
# }
# output "vpc_endpoint_transfer_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_transfer_network_interface_ids
# }
# output "vpc_endpoint_transfer_dns_entry" {
#   value = module.vpc.vpc_endpoint_transfer_dns_entry
# }
# output "vpc_endpoint_sagemaker_api_id" {
#   value = module.vpc.vpc_endpoint_sagemaker_api_id
# }
# output "vpc_endpoint_sagemaker_api_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_sagemaker_api_network_interface_ids
# }
# output "vpc_endpoint_sagemaker_api_dns_entry" {
#   value = module.vpc.vpc_endpoint_sagemaker_api_dns_entry
# }
# output "vpc_endpoint_sagemaker_runtime_id" {
#   value = module.vpc.vpc_endpoint_sagemaker_runtime_id
# }
# output "vpc_endpoint_sagemaker_runtime_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_sagemaker_runtime_network_interface_ids
# }
# output "vpc_endpoint_sagemaker_runtime_dns_entry" {
#   value = module.vpc.vpc_endpoint_sagemaker_runtime_dns_entry
# }
# output "vpc_endpoint_appstream_api_id" {
#   value = module.vpc.vpc_endpoint_appstream_api_id
# }
# output "vpc_endpoint_appstream_api_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_appstream_api_network_interface_ids
# }
# output "vpc_endpoint_appstream_api_dns_entry" {
#   value = module.vpc.vpc_endpoint_appstream_api_dns_entry
# }
# output "vpc_endpoint_appstream_streaming_id" {
#   value = module.vpc.vpc_endpoint_appstream_streaming_id
# }
# output "vpc_endpoint_appstream_streaming_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_appstream_streaming_network_interface_ids
# }
# output "vpc_endpoint_appstream_streaming_dns_entry" {
#   value = module.vpc.vpc_endpoint_appstream_streaming_dns_entry
# }
# output "vpc_endpoint_athena_id" {
#   value = module.vpc.vpc_endpoint_athena_id
# }
# output "vpc_endpoint_athena_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_athena_network_interface_ids
# }
# output "vpc_endpoint_athena_dns_entry" {
#   value = module.vpc.vpc_endpoint_athena_dns_entry
# }
# output "vpc_endpoint_rekognition_id" {
#   value = module.vpc.vpc_endpoint_rekognition_id
# }
# output "vpc_endpoint_rekognition_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_rekognition_network_interface_ids
# }
# output "vpc_endpoint_rekognition_dns_entry" {
#   value = module.vpc.vpc_endpoint_rekognition_dns_entry
# }
# output "vpc_endpoint_efs_id" {
#   value = module.vpc.vpc_endpoint_efs_id
# }
# output "vpc_endpoint_efs_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_efs_network_interface_ids
# }
# output "vpc_endpoint_efs_dns_entry" {
#   value = module.vpc.vpc_endpoint_efs_dns_entry
# }
# output "vpc_endpoint_cloud_directory_id" {
#   value = module.vpc.vpc_endpoint_cloud_directory_id
# }
# output "vpc_endpoint_cloud_directory_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_cloud_directory_network_interface_ids
# }
# output "vpc_endpoint_cloud_directory_dns_entry" {
#   value = module.vpc.vpc_endpoint_cloud_directory_dns_entry
# }
# output "vpc_endpoint_elasticmapreduce_id" {
#   value = module.vpc.vpc_endpoint_elasticmapreduce_id
# }
# output "vpc_endpoint_elasticmapreduce_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_elasticmapreduce_network_interface_ids
# }
# output "vpc_endpoint_elasticmapreduce_dns_entry" {
#   value = module.vpc.vpc_endpoint_elasticmapreduce_dns_entry
# }
# output "vpc_endpoint_sms_id" {
#   value = module.vpc.vpc_endpoint_sms_id
# }
# output "vpc_endpoint_sms_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_sms_network_interface_ids
# }
# output "vpc_endpoint_sms_dns_entry" {
#   value = module.vpc.vpc_endpoint_sms_dns_entry
# }
# output "vpc_endpoint_states_id" {
#   value = module.vpc.vpc_endpoint_states_id
# }
# output "vpc_endpoint_states_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_states_network_interface_ids
# }
# output "vpc_endpoint_states_dns_entry" {
#   value = module.vpc.vpc_endpoint_states_dns_entry
# }
# output "vpc_endpoint_elastic_inference_runtime_id" {
#   value = module.vpc.vpc_endpoint_elastic_inference_runtime_id
# }
# output "vpc_endpoint_elastic_inference_runtime_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_elastic_inference_runtime_network_interface_ids
# }
# output "vpc_endpoint_elastic_inference_runtime_dns_entry" {
#   value = module.vpc.vpc_endpoint_elastic_inference_runtime_dns_entry
# }
# output "vpc_endpoint_elasticbeanstalk_id" {
#   value = module.vpc.vpc_endpoint_elasticbeanstalk_id
# }
# output "vpc_endpoint_elasticbeanstalk_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_elasticbeanstalk_network_interface_ids
# }
# output "vpc_endpoint_elasticbeanstalk_dns_entry" {
#   value = module.vpc.vpc_endpoint_elasticbeanstalk_dns_entry
# }
# output "vpc_endpoint_elasticbeanstalk_health_id" {
#   value = module.vpc.vpc_endpoint_elasticbeanstalk_health_id
# }
# output "vpc_endpoint_elasticbeanstalk_health_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_elasticbeanstalk_health_network_interface_ids
# }
# output "vpc_endpoint_elasticbeanstalk_health_dns_entry" {
#   value = module.vpc.vpc_endpoint_elasticbeanstalk_health_dns_entry
# }
# output "vpc_endpoint_workspaces_id" {
#   value = module.vpc.vpc_endpoint_workspaces_id
# }
# output "vpc_endpoint_workspaces_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_workspaces_network_interface_ids
# }
# output "vpc_endpoint_workspaces_dns_entry" {
#   value = module.vpc.vpc_endpoint_workspaces_dns_entry
# }
# output "vpc_endpoint_auto_scaling_plans_id" {
#   value = module.vpc.vpc_endpoint_auto_scaling_plans_id
# }
# output "vpc_endpoint_auto_scaling_plans_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_auto_scaling_plans_network_interface_ids
# }
# output "vpc_endpoint_auto_scaling_plans_dns_entry" {
#   value = module.vpc.vpc_endpoint_auto_scaling_plans_dns_entry
# }
# output "vpc_endpoint_ebs_id" {
#   value = module.vpc.vpc_endpoint_ebs_id
# }
# output "vpc_endpoint_ebs_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_ebs_network_interface_ids
# }
# output "vpc_endpoint_ebs_dns_entry" {
#   value = module.vpc.vpc_endpoint_ebs_dns_entry
# }
# output "vpc_endpoint_qldb_session_id" {
#   value = module.vpc.vpc_endpoint_qldb_session_id
# }
# output "vpc_endpoint_qldb_session_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_qldb_session_network_interface_ids
# }
# output "vpc_endpoint_qldb_session_dns_entry" {
#   value = module.vpc.vpc_endpoint_qldb_session_dns_entry
# }
# output "vpc_endpoint_datasync_id" {
#   value = module.vpc.vpc_endpoint_datasync_id
# }
# output "vpc_endpoint_datasync_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_datasync_network_interface_ids
# }
# output "vpc_endpoint_datasync_dns_entry" {
#   value = module.vpc.vpc_endpoint_datasync_dns_entry
# }
# output "vpc_endpoint_access_analyzer_id" {
#   value = module.vpc.vpc_endpoint_access_analyzer_id
# }
# output "vpc_endpoint_access_analyzer_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_access_analyzer_network_interface_ids
# }
# output "vpc_endpoint_access_analyzer_dns_entry" {
#   value = module.vpc.vpc_endpoint_access_analyzer_dns_entry
# }
# output "vpc_endpoint_acm_pca_id" {
#   value = module.vpc.vpc_endpoint_acm_pca_id
# }
# output "vpc_endpoint_acm_pca_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_acm_pca_network_interface_ids
# }
# output "vpc_endpoint_acm_pca_dns_entry" {
#   value = module.vpc.vpc_endpoint_acm_pca_dns_entry
# }
# output "vpc_endpoint_ses_id" {
#   value = module.vpc.vpc_endpoint_ses_id
# }
# output "vpc_endpoint_ses_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_ses_network_interface_ids
# }
# output "vpc_endpoint_ses_dns_entry" {
#   value = module.vpc.vpc_endpoint_ses_dns_entry
# }
# output "vpc_endpoint_textract_id" {
#   value = module.vpc.vpc_endpoint_textract_id
# }
# output "vpc_endpoint_textract_network_interface_ids" {
#   value = module.vpc.vpc_endpoint_textract_network_interface_ids
# }
# output "vpc_endpoint_textract_dns_entry" {
#   value = module.vpc.vpc_endpoint_textract_dns_entry
# }
# output "vpc_flow_log_id" {
#   value = module.vpc.vpc_flow_log_id
# }
# output "vpc_flow_log_destination_arn" {
#   value = module.vpc.vpc_flow_log_destination_arn
# }
# output "vpc_flow_log_destination_type" {
#   value = module.vpc.vpc_flow_log_destination_type
# }
# output "vpc_flow_log_cloudwatch_iam_role_arn" {
#   value = module.vpc.vpc_flow_log_cloudwatch_iam_role_arn
# }
# output "azs" {
#   value = module.vpc.azs
# }
# output "name" {
#   value = module.vpc.name
# }
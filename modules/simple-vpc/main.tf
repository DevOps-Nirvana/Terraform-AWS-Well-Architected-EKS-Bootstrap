terraform {
  required_version = ">= 0.12"
}

# Variables for the typical user to set
variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden.  Note: This should be a /16 for this module to work properly."
  type        = string
  # default     = "10.0.0.0/16"
}
variable "is_highly_available" {
  description = "Sets logic if this should be highly available (aka, for production).  This will cost more money (eg: create nat gateway per AZ)"
  type        = bool
  default     = true
}

# This is our input (instead of asking the user) to get the AZ's available in this region
data "aws_availability_zones" "azs" {}

# These are the "magic" of this ezvpc module, specifying the azs and subnetting automatically
locals {
  # Figure out our number of AZs, if the user set it or if we automatically use best practice
  number_of_azs = (var.number_of_azs > 0 ? var.number_of_azs : (var.is_highly_available == true ? 3 : 2))
  # Get an array of the named AZs, unless the user overrides it
  azs = (length(var.azs) > 0 ? var.azs : slice(sort(data.aws_availability_zones.azs.names), 0, local.number_of_azs))
  # Generate the private subnetting automatically
  private_subnets = (length(var.private_subnets) > 0 ? var.private_subnets :
                      [for num in var.number_of_azs_subnet_numbers[local.number_of_azs]:
                        cidrsubnet(var.cidr, lookup(var.cidr_addition_map, local.number_of_azs), num)
                      ]
                    )
  # Generate the public subnetting automatically
  public_subnets  = (length(var.public_subnets) > 0 ? var.public_subnets :
                      [for num in var.number_of_azs_subnet_numbers[local.number_of_azs]:
                        cidrsubnet(var.cidr, lookup(var.cidr_addition_map, local.number_of_azs), num + local.number_of_azs)
                      ]
                    )
  # Custom logic for nat based on is_highly_available
  single_nat_gateway = (var.single_nat_gateway != null ? var.single_nat_gateway : 
                          (var.is_highly_available == true ? false : true)
                        )
  one_nat_gateway_per_az = (var.one_nat_gateway_per_az != null ? var.one_nat_gateway_per_az : 
                              (var.is_highly_available == true ? true: false)
                            )
}

# These are variables that help us function and do CIDR math, DO NOT EDIT unless you know what you're doing
# TODO: This seems wholly unnecessary but I could not find a better way to do this with the inline-for loop 
#       above in locals.private_subnets and locals.public_subnets
variable "number_of_azs_subnet_numbers" {
  default = {
    "1" = [0]
    "2" = [0,1]
    "3" = [0,1,2]
    "4" = [0,1,2,3]
  }
}
# These are pre-calculated values to maximize usage of a /16 CIDR range assuming one public and one private subnet
variable "cidr_addition_map" {
  description = "lookup map for cidr additions for automatic subnetting"
  default = {
    "1" = "1"
    "2" = "2"
    "3" = "3"
    "4" = "3"
  }
}
# This allows you to force-set the number of AZs, this is incase you only want 2 AZ's or maybe even 4 AZs on a production infra
variable "number_of_azs" {
  description = "Override the number of AZs to span, this should be 1, 2, 3 or 4.  Optional, if not specified it will use intelligent value based on is_highly_available (2 for no, 3 for yes)"
  type        = number
  default     = 0
}
# This allows you to force the list of AZs used.  This is useful if you want to ensure you're using the same list of AZs as some previous infra
variable "azs" {
  description = "OPTIONAL - A list of availability zones names or ids in the region, only set this if you want to force certain AZs, with ezvpc this is automatic"
  type        = list(string)
  default     = []
}

output "number_of_azs" {
  description = "number_of_azs"
  value       = local.number_of_azs
}

# Here's our VPC module as a submodule initialized with automatic AZ and CIDR subnetting
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.58.0"

  # These are the few that we're overriding the logic for this module
  azs = local.azs
  public_subnets = local.public_subnets
  private_subnets = local.private_subnets
  single_nat_gateway = local.single_nat_gateway
  one_nat_gateway_per_az = local.one_nat_gateway_per_az

  # Pass-through basically all the rest of the input variables
  create_vpc = var.create_vpc
  name = var.name
  cidr = var.cidr
  enable_ipv6 = var.enable_ipv6
  private_subnet_ipv6_prefixes = var.private_subnet_ipv6_prefixes
  public_subnet_ipv6_prefixes = var.public_subnet_ipv6_prefixes
  database_subnet_ipv6_prefixes = var.database_subnet_ipv6_prefixes
  redshift_subnet_ipv6_prefixes = var.redshift_subnet_ipv6_prefixes
  elasticache_subnet_ipv6_prefixes = var.elasticache_subnet_ipv6_prefixes
  intra_subnet_ipv6_prefixes = var.intra_subnet_ipv6_prefixes
  assign_ipv6_address_on_creation = var.assign_ipv6_address_on_creation
  private_subnet_assign_ipv6_address_on_creation = var.private_subnet_assign_ipv6_address_on_creation
  public_subnet_assign_ipv6_address_on_creation = var.public_subnet_assign_ipv6_address_on_creation
  database_subnet_assign_ipv6_address_on_creation = var.database_subnet_assign_ipv6_address_on_creation
  redshift_subnet_assign_ipv6_address_on_creation = var.redshift_subnet_assign_ipv6_address_on_creation
  elasticache_subnet_assign_ipv6_address_on_creation = var.elasticache_subnet_assign_ipv6_address_on_creation
  intra_subnet_assign_ipv6_address_on_creation = var.intra_subnet_assign_ipv6_address_on_creation
  secondary_cidr_blocks = var.secondary_cidr_blocks
  instance_tenancy = var.instance_tenancy
  public_subnet_suffix = var.public_subnet_suffix
  private_subnet_suffix = var.private_subnet_suffix
  intra_subnet_suffix = var.intra_subnet_suffix
  database_subnet_suffix = var.database_subnet_suffix
  redshift_subnet_suffix = var.redshift_subnet_suffix
  elasticache_subnet_suffix = var.elasticache_subnet_suffix
  database_subnets = var.database_subnets
  redshift_subnets = var.redshift_subnets
  elasticache_subnets = var.elasticache_subnets
  intra_subnets = var.intra_subnets
  create_database_subnet_route_table = var.create_database_subnet_route_table
  create_redshift_subnet_route_table = var.create_redshift_subnet_route_table
  enable_public_redshift = var.enable_public_redshift
  create_elasticache_subnet_route_table = var.create_elasticache_subnet_route_table
  create_database_subnet_group = var.create_database_subnet_group
  create_elasticache_subnet_group = var.create_elasticache_subnet_group
  create_redshift_subnet_group = var.create_redshift_subnet_group
  create_database_internet_gateway_route = var.create_database_internet_gateway_route
  create_database_nat_gateway_route = var.create_database_nat_gateway_route
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support = var.enable_dns_support
  enable_classiclink = var.enable_classiclink
  enable_classiclink_dns_support = var.enable_classiclink_dns_support
  enable_nat_gateway = var.enable_nat_gateway
  reuse_nat_ips = var.reuse_nat_ips
  external_nat_ip_ids = var.external_nat_ip_ids
  external_nat_ips = var.external_nat_ips
  enable_public_s3_endpoint = var.enable_public_s3_endpoint
  enable_dynamodb_endpoint = var.enable_dynamodb_endpoint
  enable_s3_endpoint = var.enable_s3_endpoint
  enable_codebuild_endpoint = var.enable_codebuild_endpoint
  codebuild_endpoint_security_group_ids = var.codebuild_endpoint_security_group_ids
  codebuild_endpoint_subnet_ids = var.codebuild_endpoint_subnet_ids
  codebuild_endpoint_private_dns_enabled = var.codebuild_endpoint_private_dns_enabled
  enable_codecommit_endpoint = var.enable_codecommit_endpoint
  codecommit_endpoint_security_group_ids = var.codecommit_endpoint_security_group_ids
  codecommit_endpoint_subnet_ids = var.codecommit_endpoint_subnet_ids
  codecommit_endpoint_private_dns_enabled = var.codecommit_endpoint_private_dns_enabled
  enable_git_codecommit_endpoint = var.enable_git_codecommit_endpoint
  git_codecommit_endpoint_security_group_ids = var.git_codecommit_endpoint_security_group_ids
  git_codecommit_endpoint_subnet_ids = var.git_codecommit_endpoint_subnet_ids
  git_codecommit_endpoint_private_dns_enabled = var.git_codecommit_endpoint_private_dns_enabled
  enable_config_endpoint = var.enable_config_endpoint
  config_endpoint_security_group_ids = var.config_endpoint_security_group_ids
  config_endpoint_subnet_ids = var.config_endpoint_subnet_ids
  config_endpoint_private_dns_enabled = var.config_endpoint_private_dns_enabled
  enable_sqs_endpoint = var.enable_sqs_endpoint
  sqs_endpoint_security_group_ids = var.sqs_endpoint_security_group_ids
  sqs_endpoint_subnet_ids = var.sqs_endpoint_subnet_ids
  sqs_endpoint_private_dns_enabled = var.sqs_endpoint_private_dns_enabled
  enable_ssm_endpoint = var.enable_ssm_endpoint
  ssm_endpoint_security_group_ids = var.ssm_endpoint_security_group_ids
  ssm_endpoint_subnet_ids = var.ssm_endpoint_subnet_ids
  ssm_endpoint_private_dns_enabled = var.ssm_endpoint_private_dns_enabled
  enable_secretsmanager_endpoint = var.enable_secretsmanager_endpoint
  secretsmanager_endpoint_security_group_ids = var.secretsmanager_endpoint_security_group_ids
  secretsmanager_endpoint_subnet_ids = var.secretsmanager_endpoint_subnet_ids
  secretsmanager_endpoint_private_dns_enabled = var.secretsmanager_endpoint_private_dns_enabled
  enable_apigw_endpoint = var.enable_apigw_endpoint
  apigw_endpoint_security_group_ids = var.apigw_endpoint_security_group_ids
  apigw_endpoint_private_dns_enabled = var.apigw_endpoint_private_dns_enabled
  apigw_endpoint_subnet_ids = var.apigw_endpoint_subnet_ids
  enable_ssmmessages_endpoint = var.enable_ssmmessages_endpoint
  ssmmessages_endpoint_security_group_ids = var.ssmmessages_endpoint_security_group_ids
  ssmmessages_endpoint_subnet_ids = var.ssmmessages_endpoint_subnet_ids
  ssmmessages_endpoint_private_dns_enabled = var.ssmmessages_endpoint_private_dns_enabled
  enable_textract_endpoint = var.enable_textract_endpoint
  textract_endpoint_security_group_ids = var.textract_endpoint_security_group_ids
  textract_endpoint_subnet_ids = var.textract_endpoint_subnet_ids
  textract_endpoint_private_dns_enabled = var.textract_endpoint_private_dns_enabled
  enable_transferserver_endpoint = var.enable_transferserver_endpoint
  transferserver_endpoint_security_group_ids = var.transferserver_endpoint_security_group_ids
  transferserver_endpoint_subnet_ids = var.transferserver_endpoint_subnet_ids
  transferserver_endpoint_private_dns_enabled = var.transferserver_endpoint_private_dns_enabled
  enable_ec2_endpoint = var.enable_ec2_endpoint
  ec2_endpoint_security_group_ids = var.ec2_endpoint_security_group_ids
  ec2_endpoint_private_dns_enabled = var.ec2_endpoint_private_dns_enabled
  ec2_endpoint_subnet_ids = var.ec2_endpoint_subnet_ids
  enable_ec2messages_endpoint = var.enable_ec2messages_endpoint
  ec2messages_endpoint_security_group_ids = var.ec2messages_endpoint_security_group_ids
  ec2messages_endpoint_private_dns_enabled = var.ec2messages_endpoint_private_dns_enabled
  ec2messages_endpoint_subnet_ids = var.ec2messages_endpoint_subnet_ids
  enable_ec2_autoscaling_endpoint = var.enable_ec2_autoscaling_endpoint
  ec2_autoscaling_endpoint_security_group_ids = var.ec2_autoscaling_endpoint_security_group_ids
  ec2_autoscaling_endpoint_private_dns_enabled = var.ec2_autoscaling_endpoint_private_dns_enabled
  ec2_autoscaling_endpoint_subnet_ids = var.ec2_autoscaling_endpoint_subnet_ids
  enable_ecr_api_endpoint = var.enable_ecr_api_endpoint
  ecr_api_endpoint_subnet_ids = var.ecr_api_endpoint_subnet_ids
  ecr_api_endpoint_private_dns_enabled = var.ecr_api_endpoint_private_dns_enabled
  ecr_api_endpoint_security_group_ids = var.ecr_api_endpoint_security_group_ids
  enable_ecr_dkr_endpoint = var.enable_ecr_dkr_endpoint
  ecr_dkr_endpoint_subnet_ids = var.ecr_dkr_endpoint_subnet_ids
  ecr_dkr_endpoint_private_dns_enabled = var.ecr_dkr_endpoint_private_dns_enabled
  ecr_dkr_endpoint_security_group_ids = var.ecr_dkr_endpoint_security_group_ids
  enable_kms_endpoint = var.enable_kms_endpoint
  kms_endpoint_security_group_ids = var.kms_endpoint_security_group_ids
  kms_endpoint_subnet_ids = var.kms_endpoint_subnet_ids
  kms_endpoint_private_dns_enabled = var.kms_endpoint_private_dns_enabled
  enable_ecs_endpoint = var.enable_ecs_endpoint
  ecs_endpoint_security_group_ids = var.ecs_endpoint_security_group_ids
  ecs_endpoint_subnet_ids = var.ecs_endpoint_subnet_ids
  ecs_endpoint_private_dns_enabled = var.ecs_endpoint_private_dns_enabled
  enable_ecs_agent_endpoint = var.enable_ecs_agent_endpoint
  ecs_agent_endpoint_security_group_ids = var.ecs_agent_endpoint_security_group_ids
  ecs_agent_endpoint_subnet_ids = var.ecs_agent_endpoint_subnet_ids
  ecs_agent_endpoint_private_dns_enabled = var.ecs_agent_endpoint_private_dns_enabled
  enable_ecs_telemetry_endpoint = var.enable_ecs_telemetry_endpoint
  ecs_telemetry_endpoint_security_group_ids = var.ecs_telemetry_endpoint_security_group_ids
  ecs_telemetry_endpoint_subnet_ids = var.ecs_telemetry_endpoint_subnet_ids
  ecs_telemetry_endpoint_private_dns_enabled = var.ecs_telemetry_endpoint_private_dns_enabled
  enable_sns_endpoint = var.enable_sns_endpoint
  sns_endpoint_security_group_ids = var.sns_endpoint_security_group_ids
  sns_endpoint_subnet_ids = var.sns_endpoint_subnet_ids
  sns_endpoint_private_dns_enabled = var.sns_endpoint_private_dns_enabled
  enable_monitoring_endpoint = var.enable_monitoring_endpoint
  monitoring_endpoint_security_group_ids = var.monitoring_endpoint_security_group_ids
  monitoring_endpoint_subnet_ids = var.monitoring_endpoint_subnet_ids
  monitoring_endpoint_private_dns_enabled = var.monitoring_endpoint_private_dns_enabled
  enable_elasticloadbalancing_endpoint = var.enable_elasticloadbalancing_endpoint
  elasticloadbalancing_endpoint_security_group_ids = var.elasticloadbalancing_endpoint_security_group_ids
  elasticloadbalancing_endpoint_subnet_ids = var.elasticloadbalancing_endpoint_subnet_ids
  elasticloadbalancing_endpoint_private_dns_enabled = var.elasticloadbalancing_endpoint_private_dns_enabled
  enable_events_endpoint = var.enable_events_endpoint
  events_endpoint_security_group_ids = var.events_endpoint_security_group_ids
  events_endpoint_subnet_ids = var.events_endpoint_subnet_ids
  events_endpoint_private_dns_enabled = var.events_endpoint_private_dns_enabled
  enable_logs_endpoint = var.enable_logs_endpoint
  logs_endpoint_security_group_ids = var.logs_endpoint_security_group_ids
  logs_endpoint_subnet_ids = var.logs_endpoint_subnet_ids
  logs_endpoint_private_dns_enabled = var.logs_endpoint_private_dns_enabled
  enable_cloudtrail_endpoint = var.enable_cloudtrail_endpoint
  cloudtrail_endpoint_security_group_ids = var.cloudtrail_endpoint_security_group_ids
  cloudtrail_endpoint_subnet_ids = var.cloudtrail_endpoint_subnet_ids
  cloudtrail_endpoint_private_dns_enabled = var.cloudtrail_endpoint_private_dns_enabled
  enable_kinesis_streams_endpoint = var.enable_kinesis_streams_endpoint
  kinesis_streams_endpoint_security_group_ids = var.kinesis_streams_endpoint_security_group_ids
  kinesis_streams_endpoint_subnet_ids = var.kinesis_streams_endpoint_subnet_ids
  kinesis_streams_endpoint_private_dns_enabled = var.kinesis_streams_endpoint_private_dns_enabled
  enable_kinesis_firehose_endpoint = var.enable_kinesis_firehose_endpoint
  kinesis_firehose_endpoint_security_group_ids = var.kinesis_firehose_endpoint_security_group_ids
  kinesis_firehose_endpoint_subnet_ids = var.kinesis_firehose_endpoint_subnet_ids
  kinesis_firehose_endpoint_private_dns_enabled = var.kinesis_firehose_endpoint_private_dns_enabled
  enable_glue_endpoint = var.enable_glue_endpoint
  glue_endpoint_security_group_ids = var.glue_endpoint_security_group_ids
  glue_endpoint_subnet_ids = var.glue_endpoint_subnet_ids
  glue_endpoint_private_dns_enabled = var.glue_endpoint_private_dns_enabled
  enable_sagemaker_notebook_endpoint = var.enable_sagemaker_notebook_endpoint
  sagemaker_notebook_endpoint_region = var.sagemaker_notebook_endpoint_region
  sagemaker_notebook_endpoint_security_group_ids = var.sagemaker_notebook_endpoint_security_group_ids
  sagemaker_notebook_endpoint_subnet_ids = var.sagemaker_notebook_endpoint_subnet_ids
  sagemaker_notebook_endpoint_private_dns_enabled = var.sagemaker_notebook_endpoint_private_dns_enabled
  enable_sts_endpoint = var.enable_sts_endpoint
  sts_endpoint_security_group_ids = var.sts_endpoint_security_group_ids
  sts_endpoint_subnet_ids = var.sts_endpoint_subnet_ids
  sts_endpoint_private_dns_enabled = var.sts_endpoint_private_dns_enabled
  enable_cloudformation_endpoint = var.enable_cloudformation_endpoint
  cloudformation_endpoint_security_group_ids = var.cloudformation_endpoint_security_group_ids
  cloudformation_endpoint_subnet_ids = var.cloudformation_endpoint_subnet_ids
  cloudformation_endpoint_private_dns_enabled = var.cloudformation_endpoint_private_dns_enabled
  enable_codepipeline_endpoint = var.enable_codepipeline_endpoint
  codepipeline_endpoint_security_group_ids = var.codepipeline_endpoint_security_group_ids
  codepipeline_endpoint_subnet_ids = var.codepipeline_endpoint_subnet_ids
  codepipeline_endpoint_private_dns_enabled = var.codepipeline_endpoint_private_dns_enabled
  enable_appmesh_envoy_management_endpoint = var.enable_appmesh_envoy_management_endpoint
  appmesh_envoy_management_endpoint_security_group_ids = var.appmesh_envoy_management_endpoint_security_group_ids
  appmesh_envoy_management_endpoint_subnet_ids = var.appmesh_envoy_management_endpoint_subnet_ids
  appmesh_envoy_management_endpoint_private_dns_enabled = var.appmesh_envoy_management_endpoint_private_dns_enabled
  enable_servicecatalog_endpoint = var.enable_servicecatalog_endpoint
  servicecatalog_endpoint_security_group_ids = var.servicecatalog_endpoint_security_group_ids
  servicecatalog_endpoint_subnet_ids = var.servicecatalog_endpoint_subnet_ids
  servicecatalog_endpoint_private_dns_enabled = var.servicecatalog_endpoint_private_dns_enabled
  enable_storagegateway_endpoint = var.enable_storagegateway_endpoint
  storagegateway_endpoint_security_group_ids = var.storagegateway_endpoint_security_group_ids
  storagegateway_endpoint_subnet_ids = var.storagegateway_endpoint_subnet_ids
  storagegateway_endpoint_private_dns_enabled = var.storagegateway_endpoint_private_dns_enabled
  enable_transfer_endpoint = var.enable_transfer_endpoint
  transfer_endpoint_security_group_ids = var.transfer_endpoint_security_group_ids
  transfer_endpoint_subnet_ids = var.transfer_endpoint_subnet_ids
  transfer_endpoint_private_dns_enabled = var.transfer_endpoint_private_dns_enabled
  enable_sagemaker_api_endpoint = var.enable_sagemaker_api_endpoint
  sagemaker_api_endpoint_security_group_ids = var.sagemaker_api_endpoint_security_group_ids
  sagemaker_api_endpoint_subnet_ids = var.sagemaker_api_endpoint_subnet_ids
  sagemaker_api_endpoint_private_dns_enabled = var.sagemaker_api_endpoint_private_dns_enabled
  enable_sagemaker_runtime_endpoint = var.enable_sagemaker_runtime_endpoint
  sagemaker_runtime_endpoint_security_group_ids = var.sagemaker_runtime_endpoint_security_group_ids
  sagemaker_runtime_endpoint_subnet_ids = var.sagemaker_runtime_endpoint_subnet_ids
  sagemaker_runtime_endpoint_private_dns_enabled = var.sagemaker_runtime_endpoint_private_dns_enabled
  enable_appstream_api_endpoint = var.enable_appstream_api_endpoint
  appstream_api_endpoint_security_group_ids = var.appstream_api_endpoint_security_group_ids
  appstream_api_endpoint_subnet_ids = var.appstream_api_endpoint_subnet_ids
  appstream_api_endpoint_private_dns_enabled = var.appstream_api_endpoint_private_dns_enabled
  enable_appstream_streaming_endpoint = var.enable_appstream_streaming_endpoint
  appstream_streaming_endpoint_security_group_ids = var.appstream_streaming_endpoint_security_group_ids
  appstream_streaming_endpoint_subnet_ids = var.appstream_streaming_endpoint_subnet_ids
  appstream_streaming_endpoint_private_dns_enabled = var.appstream_streaming_endpoint_private_dns_enabled
  enable_athena_endpoint = var.enable_athena_endpoint
  athena_endpoint_security_group_ids = var.athena_endpoint_security_group_ids
  athena_endpoint_subnet_ids = var.athena_endpoint_subnet_ids
  athena_endpoint_private_dns_enabled = var.athena_endpoint_private_dns_enabled
  enable_rekognition_endpoint = var.enable_rekognition_endpoint
  rekognition_endpoint_security_group_ids = var.rekognition_endpoint_security_group_ids
  rekognition_endpoint_subnet_ids = var.rekognition_endpoint_subnet_ids
  rekognition_endpoint_private_dns_enabled = var.rekognition_endpoint_private_dns_enabled
  enable_efs_endpoint = var.enable_efs_endpoint
  efs_endpoint_security_group_ids = var.efs_endpoint_security_group_ids
  efs_endpoint_subnet_ids = var.efs_endpoint_subnet_ids
  efs_endpoint_private_dns_enabled = var.efs_endpoint_private_dns_enabled
  enable_cloud_directory_endpoint = var.enable_cloud_directory_endpoint
  cloud_directory_endpoint_security_group_ids = var.cloud_directory_endpoint_security_group_ids
  cloud_directory_endpoint_subnet_ids = var.cloud_directory_endpoint_subnet_ids
  cloud_directory_endpoint_private_dns_enabled = var.cloud_directory_endpoint_private_dns_enabled
  enable_ses_endpoint = var.enable_ses_endpoint
  ses_endpoint_security_group_ids = var.ses_endpoint_security_group_ids
  ses_endpoint_subnet_ids = var.ses_endpoint_subnet_ids
  enable_auto_scaling_plans_endpoint = var.enable_auto_scaling_plans_endpoint
  auto_scaling_plans_endpoint_security_group_ids = var.auto_scaling_plans_endpoint_security_group_ids
  auto_scaling_plans_endpoint_subnet_ids = var.auto_scaling_plans_endpoint_subnet_ids
  auto_scaling_plans_endpoint_private_dns_enabled = var.auto_scaling_plans_endpoint_private_dns_enabled
  ses_endpoint_private_dns_enabled = var.ses_endpoint_private_dns_enabled
  enable_workspaces_endpoint = var.enable_workspaces_endpoint
  workspaces_endpoint_security_group_ids = var.workspaces_endpoint_security_group_ids
  workspaces_endpoint_subnet_ids = var.workspaces_endpoint_subnet_ids
  workspaces_endpoint_private_dns_enabled = var.workspaces_endpoint_private_dns_enabled
  enable_access_analyzer_endpoint = var.enable_access_analyzer_endpoint
  access_analyzer_endpoint_security_group_ids = var.access_analyzer_endpoint_security_group_ids
  access_analyzer_endpoint_subnet_ids = var.access_analyzer_endpoint_subnet_ids
  access_analyzer_endpoint_private_dns_enabled = var.access_analyzer_endpoint_private_dns_enabled
  enable_ebs_endpoint = var.enable_ebs_endpoint
  ebs_endpoint_security_group_ids = var.ebs_endpoint_security_group_ids
  ebs_endpoint_subnet_ids = var.ebs_endpoint_subnet_ids
  ebs_endpoint_private_dns_enabled = var.ebs_endpoint_private_dns_enabled
  enable_datasync_endpoint = var.enable_datasync_endpoint
  datasync_endpoint_security_group_ids = var.datasync_endpoint_security_group_ids
  datasync_endpoint_subnet_ids = var.datasync_endpoint_subnet_ids
  datasync_endpoint_private_dns_enabled = var.datasync_endpoint_private_dns_enabled
  enable_elastic_inference_runtime_endpoint = var.enable_elastic_inference_runtime_endpoint
  elastic_inference_runtime_endpoint_security_group_ids = var.elastic_inference_runtime_endpoint_security_group_ids
  elastic_inference_runtime_endpoint_subnet_ids = var.elastic_inference_runtime_endpoint_subnet_ids
  elastic_inference_runtime_endpoint_private_dns_enabled = var.elastic_inference_runtime_endpoint_private_dns_enabled
  enable_sms_endpoint = var.enable_sms_endpoint
  sms_endpoint_security_group_ids = var.sms_endpoint_security_group_ids
  sms_endpoint_subnet_ids = var.sms_endpoint_subnet_ids
  sms_endpoint_private_dns_enabled = var.sms_endpoint_private_dns_enabled
  enable_emr_endpoint = var.enable_emr_endpoint
  emr_endpoint_security_group_ids = var.emr_endpoint_security_group_ids
  emr_endpoint_subnet_ids = var.emr_endpoint_subnet_ids
  emr_endpoint_private_dns_enabled = var.emr_endpoint_private_dns_enabled
  enable_qldb_session_endpoint = var.enable_qldb_session_endpoint
  qldb_session_endpoint_security_group_ids = var.qldb_session_endpoint_security_group_ids
  qldb_session_endpoint_subnet_ids = var.qldb_session_endpoint_subnet_ids
  qldb_session_endpoint_private_dns_enabled = var.qldb_session_endpoint_private_dns_enabled
  enable_elasticbeanstalk_endpoint = var.enable_elasticbeanstalk_endpoint
  elasticbeanstalk_endpoint_security_group_ids = var.elasticbeanstalk_endpoint_security_group_ids
  elasticbeanstalk_endpoint_subnet_ids = var.elasticbeanstalk_endpoint_subnet_ids
  elasticbeanstalk_endpoint_private_dns_enabled = var.elasticbeanstalk_endpoint_private_dns_enabled
  enable_elasticbeanstalk_health_endpoint = var.enable_elasticbeanstalk_health_endpoint
  elasticbeanstalk_health_endpoint_security_group_ids = var.elasticbeanstalk_health_endpoint_security_group_ids
  elasticbeanstalk_health_endpoint_subnet_ids = var.elasticbeanstalk_health_endpoint_subnet_ids
  elasticbeanstalk_health_endpoint_private_dns_enabled = var.elasticbeanstalk_health_endpoint_private_dns_enabled
  enable_states_endpoint = var.enable_states_endpoint
  states_endpoint_security_group_ids = var.states_endpoint_security_group_ids
  states_endpoint_subnet_ids = var.states_endpoint_subnet_ids
  states_endpoint_private_dns_enabled = var.states_endpoint_private_dns_enabled
  enable_acm_pca_endpoint = var.enable_acm_pca_endpoint
  enable_rds_endpoint = var.enable_rds_endpoint
  rds_endpoint_security_group_ids = var.rds_endpoint_security_group_ids
  rds_endpoint_subnet_ids = var.rds_endpoint_subnet_ids
  rds_endpoint_private_dns_enabled = var.rds_endpoint_private_dns_enabled
  enable_codedeploy_endpoint = var.enable_codedeploy_endpoint
  codedeploy_endpoint_security_group_ids = var.codedeploy_endpoint_security_group_ids
  codedeploy_endpoint_subnet_ids = var.codedeploy_endpoint_subnet_ids
  codedeploy_endpoint_private_dns_enabled = var.codedeploy_endpoint_private_dns_enabled
  enable_codedeploy_commands_secure_endpoint = var.enable_codedeploy_commands_secure_endpoint
  codedeploy_commands_secure_endpoint_security_group_ids = var.codedeploy_commands_secure_endpoint_security_group_ids
  codedeploy_commands_secure_endpoint_subnet_ids = var.codedeploy_commands_secure_endpoint_subnet_ids
  codedeploy_commands_secure_endpoint_private_dns_enabled = var.codedeploy_commands_secure_endpoint_private_dns_enabled
  acm_pca_endpoint_security_group_ids = var.acm_pca_endpoint_security_group_ids
  acm_pca_endpoint_subnet_ids = var.acm_pca_endpoint_subnet_ids
  acm_pca_endpoint_private_dns_enabled = var.acm_pca_endpoint_private_dns_enabled
  map_public_ip_on_launch = var.map_public_ip_on_launch
  customer_gateways = var.customer_gateways
  enable_vpn_gateway = var.enable_vpn_gateway
  vpn_gateway_id = var.vpn_gateway_id
  amazon_side_asn = var.amazon_side_asn
  vpn_gateway_az = var.vpn_gateway_az
  propagate_intra_route_tables_vgw = var.propagate_intra_route_tables_vgw
  propagate_private_route_tables_vgw = var.propagate_private_route_tables_vgw
  propagate_public_route_tables_vgw = var.propagate_public_route_tables_vgw
  tags = var.tags
  vpc_tags = var.vpc_tags
  igw_tags = var.igw_tags
  public_subnet_tags = var.public_subnet_tags
  private_subnet_tags = var.private_subnet_tags
  public_route_table_tags = var.public_route_table_tags
  private_route_table_tags = var.private_route_table_tags
  database_route_table_tags = var.database_route_table_tags
  redshift_route_table_tags = var.redshift_route_table_tags
  elasticache_route_table_tags = var.elasticache_route_table_tags
  intra_route_table_tags = var.intra_route_table_tags
  database_subnet_tags = var.database_subnet_tags
  database_subnet_group_tags = var.database_subnet_group_tags
  redshift_subnet_tags = var.redshift_subnet_tags
  redshift_subnet_group_tags = var.redshift_subnet_group_tags
  elasticache_subnet_tags = var.elasticache_subnet_tags
  intra_subnet_tags = var.intra_subnet_tags
  public_acl_tags = var.public_acl_tags
  private_acl_tags = var.private_acl_tags
  intra_acl_tags = var.intra_acl_tags
  database_acl_tags = var.database_acl_tags
  redshift_acl_tags = var.redshift_acl_tags
  elasticache_acl_tags = var.elasticache_acl_tags
  dhcp_options_tags = var.dhcp_options_tags
  nat_gateway_tags = var.nat_gateway_tags
  nat_eip_tags = var.nat_eip_tags
  customer_gateway_tags = var.customer_gateway_tags
  vpn_gateway_tags = var.vpn_gateway_tags
  vpc_endpoint_tags = var.vpc_endpoint_tags
  vpc_flow_log_tags = var.vpc_flow_log_tags
  enable_dhcp_options = var.enable_dhcp_options
  dhcp_options_domain_name = var.dhcp_options_domain_name
  dhcp_options_domain_name_servers = var.dhcp_options_domain_name_servers
  dhcp_options_ntp_servers = var.dhcp_options_ntp_servers
  dhcp_options_netbios_name_servers = var.dhcp_options_netbios_name_servers
  dhcp_options_netbios_node_type = var.dhcp_options_netbios_node_type
  manage_default_vpc = var.manage_default_vpc
  default_vpc_name = var.default_vpc_name
  default_vpc_enable_dns_support = var.default_vpc_enable_dns_support
  default_vpc_enable_dns_hostnames = var.default_vpc_enable_dns_hostnames
  default_vpc_enable_classiclink = var.default_vpc_enable_classiclink
  default_vpc_tags = var.default_vpc_tags
  manage_default_network_acl = var.manage_default_network_acl
  default_network_acl_name = var.default_network_acl_name
  default_network_acl_tags = var.default_network_acl_tags
  public_dedicated_network_acl = var.public_dedicated_network_acl
  private_dedicated_network_acl = var.private_dedicated_network_acl
  intra_dedicated_network_acl = var.intra_dedicated_network_acl
  database_dedicated_network_acl = var.database_dedicated_network_acl
  redshift_dedicated_network_acl = var.redshift_dedicated_network_acl
  elasticache_dedicated_network_acl = var.elasticache_dedicated_network_acl
  default_network_acl_ingress = var.default_network_acl_ingress
  default_network_acl_egress = var.default_network_acl_egress
  public_inbound_acl_rules = var.public_inbound_acl_rules
  public_outbound_acl_rules = var.public_outbound_acl_rules
  private_inbound_acl_rules = var.private_inbound_acl_rules
  private_outbound_acl_rules = var.private_outbound_acl_rules
  intra_inbound_acl_rules = var.intra_inbound_acl_rules
  intra_outbound_acl_rules = var.intra_outbound_acl_rules
  database_inbound_acl_rules = var.database_inbound_acl_rules
  database_outbound_acl_rules = var.database_outbound_acl_rules
  redshift_inbound_acl_rules = var.redshift_inbound_acl_rules
  redshift_outbound_acl_rules = var.redshift_outbound_acl_rules
  elasticache_inbound_acl_rules = var.elasticache_inbound_acl_rules
  elasticache_outbound_acl_rules = var.elasticache_outbound_acl_rules
  manage_default_security_group = var.manage_default_security_group
  default_security_group_name = var.default_security_group_name
  default_security_group_ingress = var.default_security_group_ingress
  enable_flow_log = var.enable_flow_log
  default_security_group_egress = var.default_security_group_egress
  default_security_group_tags = var.default_security_group_tags
  create_flow_log_cloudwatch_log_group = var.create_flow_log_cloudwatch_log_group
  create_flow_log_cloudwatch_iam_role = var.create_flow_log_cloudwatch_iam_role
  flow_log_traffic_type = var.flow_log_traffic_type
  flow_log_destination_type = var.flow_log_destination_type
  flow_log_log_format = var.flow_log_log_format
  flow_log_destination_arn = var.flow_log_destination_arn
  flow_log_cloudwatch_iam_role_arn = var.flow_log_cloudwatch_iam_role_arn
  flow_log_cloudwatch_log_group_name_prefix = var.flow_log_cloudwatch_log_group_name_prefix
  flow_log_cloudwatch_log_group_retention_in_days = var.flow_log_cloudwatch_log_group_retention_in_days
  flow_log_cloudwatch_log_group_kms_key_id = var.flow_log_cloudwatch_log_group_kms_key_id
  flow_log_max_aggregation_interval = var.flow_log_max_aggregation_interval
  create_igw = var.create_igw
  create_egress_only_igw = var.create_egress_only_igw
}

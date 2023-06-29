################
# Inputs
################

variable "redis_allow_entire_vpc_subnet" {
  description = "Allow the entire VPC subnet to connect, eg: for dev clusters"
  type        = string
  default     = false
}
variable "redis_engine_version" {
  description = "The minor version of redis"
  type        = string
  default     = "3.2.4"
}
variable "redis_major_engine_version" {
  description = "The major version of redis"
  type        = string
  default     = "3.2"
}
variable "redis_instance_type" {
  description = "The instance type of redis"
  type        = string
  default     = "cache.t2.micro"  # 500MB RAM 1VCPUs
}
variable "redis_snapshot_retention_limit" {
  description = "The amount of snapshots to retain for redis, default to 0, set higher for prod"
  type        = number
  default     = 0
}


################
# Resources
################

# Security group to assign to redis instance
resource "aws_security_group" "allow-connections-to-redis" {
  name        = "allow-connections-to-${module.terraform_tags.id}-redis"
  description = "Have this SG if you want to connect to ${module.terraform_tags.id}-redis"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "Allow all traffic outbound"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge( module.terraform_tags.tags_no_name,{ "Name" = "allow-connections-to-${module.terraform_tags.id}-redis" } )
}

# Security group to assign to redis instance
resource "aws_security_group" "redis" {
  name        = "${module.terraform_tags.id}-redis"
  description = "${module.terraform_tags.id} allow all from local"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    description = "Redis from our internal network (if allowed)"
    cidr_blocks = [var.redis_allow_entire_vpc_subnet ? var.global_cidrs[var.environment] : "127.0.0.1/32"]
  }

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    description     = "Redis from our dedicated SG for ${module.terraform_tags.id}-redis"
    security_groups = [aws_security_group.allow-connections-to-redis.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "Allow all traffic outbound"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge( module.terraform_tags.tags_no_name,{ "Name" = "${module.terraform_tags.id}-redis" } )
}

# Create a subnet group for Redis (only one needed, if more than one EC deployed in this vpc, please `terraform import` this into a secondary stack)
# And if doing this, before deleting this stack, `terraform state rm aws_elasticache_subnet_group.redis` then delete this stack.  Its okay if you
# forget to do this, because it won't allow the deletion if its in use by the other EC cluster
resource "aws_elasticache_subnet_group" "redis" {
  name        = "${var.environment}-${var.aws_region}-elasticache-subnet"
  subnet_ids  = data.terraform_remote_state.vpc.outputs.private_subnets
}

# Create a parameter group for Redis incase we need to customize
resource "aws_elasticache_parameter_group" "redis" {
  name   = "${module.terraform_tags.id}-redis"
  family = "redis${var.redis_major_engine_version}"

  # This enables cluster mode (only in use for HA/production setups)
  parameter {
    name  = "cluster-enabled"
    value = "yes"
  }

  # As of Nov 10, 2017 these (commented out values) were default params from default.redis3.2 from AWS
  // parameter {
  //   name  = "activerehashing"
  //   value = "yes"
  // }
  // parameter {
  //   name  = "appendfsync"
  //   value = "everysec"
  // }
  // parameter {
  //   name  = "appendonly"
  //   value = "no"
  // }
  // parameter {
  //   name  = "client-output-buffer-limit-normal-hard-limit"
  //   value = "0"
  // }
  // parameter {
  //   name  = "client-output-buffer-limit-normal-soft-limit"
  //   value = "0"
  // }
  // parameter {
  //   name  = "client-output-buffer-limit-normal-soft-seconds"
  //   value = "0"
  // }
  // parameter {
  //   name  = "client-output-buffer-limit-pubsub-hard-limit"
  //   value = "33554432"
  // }
  // parameter {
  //   name  = "client-output-buffer-limit-pubsub-soft-limit"
  //   value = "8388608"
  // }
  // parameter {
  //   name  = "client-output-buffer-limit-pubsub-soft-seconds"
  //   value = "60"
  // }
  // parameter {
  //   name  = "client-output-buffer-limit-slave-soft-seconds"
  //   value = "60"
  // }
}

# Create a Redis cluster
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id          = "${module.terraform_tags.id}-redis"
  replication_group_description = "Created by Terraform for ${module.terraform_tags.id}"
  engine_version                = var.redis_engine_version
  parameter_group_name          = aws_elasticache_parameter_group.redis.name
  node_type                     = var.redis_instance_type
  port                          = "6379"
  availability_zones            = data.terraform_remote_state.vpc.outputs.azs
  automatic_failover_enabled    = true
  security_group_ids            = [aws_security_group.redis.id]
  subnet_group_name             = aws_elasticache_subnet_group.redis.name
  snapshot_retention_limit      = var.redis_snapshot_retention_limit
  multi_az_enabled              = true
  maintenance_window            = "sun:02:00-sun:03:00"
  number_cache_clusters         = 2 # For multiAZ this must be 2

  tags                          = merge( module.terraform_tags.tags_no_name,{ "Name" = "allow-connections-to-${module.terraform_tags.id}-redis" } )
}






################
# Outputs
################

output "redis_primary_endpoint_address" {
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}
output "redis_reader_endpoint_address" {
  value       = aws_elasticache_replication_group.redis.reader_endpoint_address
}
output "redis_endpoint_config_endpoint" {
  value       = aws_elasticache_replication_group.redis.configuration_endpoint_address
}
output "redis_member_clusters" {
  value       = aws_elasticache_replication_group.redis.member_clusters
}
output "redis_cluster_enabled" {
  value       = aws_elasticache_replication_group.redis.cluster_enabled
}
output "redis_security_group" {
  value = aws_security_group.redis.id
}
output "redis_allow_connections_to_security_group" {
  value = aws_security_group.allow-connections-to-redis.id
}



# TODO: Add ALARMS



# # Set our standardized alarms for our elasticache cluster
# module "elasticache_alarms" {
#   source           = "github.com/DevOps-Nirvana/terraform-aws-elasticache-memcached-alarms?ref=main"
#
#   # Our cache cluster name (todo: manage in TF instead of manual)
#   cache_cluster_id = "memclive"
#
#   # Alarm only after a few evictions (eg: not zero, the default)
#   evictions_threshold = 10
#
#   # A list of actions to take when alarms are triggered. Will likely be an SNS topic for event distribution, Default: []
#   sns_topic_alarm_arns = [data.terraform_remote_state.global.outputs.sns_to_slack_arn]
#   # A list of actions to take when alarms are cleared. Will likely be an SNS topic for event distribution, Default: []
#   sns_topic_ok_arns = [data.terraform_remote_state.global.outputs.sns_to_slack_arn]
#
#   # Set our standard tags
#   tags = module.terraform_tags.tags_no_name
# }

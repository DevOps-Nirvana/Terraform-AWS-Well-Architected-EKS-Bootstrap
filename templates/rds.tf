resource "aws_security_group" "allow-connections-to-rds" {
  name        = "allow-connections-to-${module.terraform_tags.id}-rds"
  description = "Have this SG if you want to connect ${module.terraform_tags.id}-rds"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "Allow all traffic outbound"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge( module.terraform_tags.tags_no_name,{ "Name" = "allow-connections-to-${module.terraform_tags.id}-rds" } )
}

# Security group to restrict access
resource "aws_security_group" "rds" {
  name        = "${module.terraform_tags.id}-rds"
  description = "${module.terraform_tags.id} allow all from local"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port   = local.rds_port
    to_port     = local.rds_port
    protocol    = "tcp"
    description = "${var.rds_engine} from our internal network (if allowed)"
    cidr_blocks = [ (var.rds_allow_local_connections ? var.global_cidrs[var.environment] : "127.0.0.1/32" ) ]
  }

  ingress {
    from_port   = local.rds_port
    to_port     = local.rds_port
    protocol    = "tcp"
    description = "${var.rds_engine} from our SG attached"
    security_groups = [aws_security_group.allow-connections-to-rds.id]
  }

  tags = merge( module.terraform_tags.tags_no_name,{ "Name" = "${module.terraform_tags.id}-rds" } )
}

# Random password for root username/password
resource "random_string" "rds" {
  length = 16
  special = false
}

# Create the Customer Master Key
resource "aws_kms_key" "rds" {
  count                   = var.rds_enable_kms ? 1 : 0
  description             = "${module.terraform_tags.id} RDS KMS Key"
  deletion_window_in_days = 15
  policy                  = data.aws_iam_policy_document.rds[0].json

  tags = merge( module.terraform_tags.tags_no_name,{ "Name" = "${module.terraform_tags.id}-rds" } )
}

# Create a friendly alias for the KMS Customer Master Key
resource "aws_kms_alias" "rds" {
  count         = var.rds_enable_kms ? 1 : 0
  name          = "alias/${module.terraform_tags.id}-rds"
  target_key_id = aws_kms_key.rds[0].id
}

data "aws_iam_policy_document" "rds" {
  count       = var.rds_enable_kms ? 1 : 0
  statement {
    sid       = "Allow key administrators and assumed superadmins to do everything administrator-ey to the key"
    effect    = "Allow"
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
      "kms:Tag*",
      "kms:Untag*",
    ]
    principals {
      type        = "AWS"
      identifiers = concat(
        var.kms_key_administrator_iam_arns,
        local.additional_kms_key_admins
      )
    }
    resources = ["*"]
  }

  statement {
    sid       = "Allow users to encrypt, decrypt key"
    effect    = "Allow"
    actions   = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:ReEncrypt*"
    ]
    principals {
      type        = "AWS"
      identifiers = concat(
        var.kms_key_administrator_iam_arns,
        local.additional_kms_key_users
      )
    }
    resources = ["*"]
  }

  statement {
    sid       = "Allow RDS to encrypt, decrypt key"
    effect    = "Allow"
    actions   = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:ReEncrypt*"
    ]
    principals {
            type        = "Service"
            identifiers = ["rds.amazonaws.com"]
        }
    resources = ["*"]
  }

}




# Actual RDS instance (+ parameter/option group)
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "3.1.0"

  # Identifiers
  identifier                = var.rds_force_name != "" ? var.rds_force_name : "${module.terraform_tags.id}-rds"
  final_snapshot_identifier = var.rds_force_name != "" ? var.rds_force_name : "${module.terraform_tags.id}-rds"

  # Engine core details
  engine                = var.rds_engine
  major_engine_version  = var.rds_major_engine_version
  engine_version        = var.rds_engine_version
  instance_class        = var.rds_instance_type
  allocated_storage     = var.rds_initially_allocated_storage
  max_allocated_storage = var.rds_max_allocated_storage_autoscaling
  deletion_protection   = var.rds_deletion_protection   # Set this to false to perform a delete of this

  # We always want encryption for regulatory purposes
  storage_encrypted = var.rds_enable_kms ? true : false
  kms_key_id = var.rds_enable_kms ? aws_kms_key.rds[0].arn : null

  # DB subnet group (aka, which VPC to live in)
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets

  # Pre-created database and username information
  name     = var.rds_initial_db_name
  username = var.rds_initial_username
  password = random_string.rds.result
  port     = local.rds_port

  # If we want to support IAM Authentication
  # iam_database_authentication_enabled = true

  # If we want multi-az / redundancy
  multi_az = var.rds_multiaz

  # What security groups to assign to this instance
  vpc_security_group_ids = [aws_security_group.rds.id]

  # What/when backup and maintenance windows exist
  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Tags for all objects created
  tags = merge( module.terraform_tags.tags_no_name,{ "Name" = "${module.terraform_tags.id}-rds" } )

  # Snapshot to restore from, if desired
  snapshot_identifier = var.rds_snapshot_identifier != "" ? var.rds_snapshot_identifier : null

  # DB parameter group
  family = "${var.rds_engine}${var.rds_major_engine_version}"
  parameters = var.rds_parameters
    # SHOULDN'T NEED THESE
    # {
    #   name = "character_set_client"
    #   value = "ascii"
    #   apply_method = "pending-reboot"
    # },
    # {
    #   name = "character_set_server"
    #   value = "ascii"
    #   apply_method = "pending-reboot"
    # },
    # This is a hack to help dump/load from other mysql databases/versions
    # {
    #   name = "log_bin_trust_function_creators"
    #   value = "1"
    #   apply_method = "pending-reboot"
    # },
    # {
    #   name = "general_log"
    #   value = "1"
    #   apply_method = "pending-reboot"
    # },

  # DB option group
#   options = [
#     {
#       option_name = "MARIADB_AUDIT_PLUGIN"
#
#       option_settings = [
#         {
#           name  = "SERVER_AUDIT_EVENTS"
#           value = "CONNECT"
#         },
#         {
#           name  = "SERVER_AUDIT_FILE_ROTATIONS"
#           value = "37"
#         },
#       ]
#     },
#   ]

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  # DISABLED BY DEFAULT, NOT NEEDED FOR DEV
  # monitoring_interval = "30"
  # monitoring_role_name = "MyRDSMonitoringRole"
  # create_monitoring_role = true

}

# INPUT variables to configure the RDS instance
variable "rds_engine" {
  description = "The engine to use, mysql, postgres, aurora, etc"
  type        = string
  default     = "postgres"  # Can be mysql
}
variable "rds_initial_db_name" {
  description = "The initial db created in rds"
  type        = string
  default     = "initial_db_name"
}
variable "rds_major_engine_version" {
  description = "The major version of rds"
  type        = string
  default     = "12"   # For mysql use 8.0, or for PG use 12 or 13
}
variable "rds_engine_version" {
  description = "The minor version of rds"
  type        = string
  default     = "12.8"  # for mysql use 8.0.20, or for PG use 13.3 or 12.5
}
variable "rds_instance_type" {
  description = "The instance type of RDS"
  type        = string
  default     = "db.t4g.micro"
}
variable "rds_multiaz" {
  description = "The instance type of RDS"
  type        = bool
  default     = false
}
variable "rds_initially_allocated_storage" {
  description = "The initial disk size of RDS in GB (min 5)"
  type        = number
  default     = 5
}
variable "rds_max_allocated_storage_autoscaling" {
  description = "The initial disk size of RDS in GB (min 5)"
  type        = number
  default     = 1000
}
variable "rds_allow_local_connections" {
  description = "To allow our entire (internal) CIDR to connect (eg: for dev)"
  type        = bool
  default     = false
}
variable "rds_deletion_protection" {
  description = "To allow our RDS to be deleted, set this to false first, apply, then can delete it"
  type        = bool
  default     = true
}
# Make it optional to use KMS
variable "rds_enable_kms" {
  description = "Whether or not we want KMS enabled (encrypted at rest)"
  type        = bool
  default     = true
}
variable "rds_force_port" {
  description = "If you want to force what port it is on (not recommended)"
  type        = number
  default     = 0
}
variable "rds_snapshot_identifier" {
  description = "If you want to restore from an snapshot"
  type        = string
  default     = null
}
variable "rds_initial_username" {
  description = "The initial superuser username created in rds"
  type        = string
  default     = "superuser"
}
variable "rds_parameters" {
  description = "The parameters to customize for this instance"
  type        = list
  default     = []
}
variable "rds_create_anomaly_alert" {
  description = "Whether or not we create the noisy anomaly alarm, its especially noisy on dev environments"
  type        = bool
  default     = true
}
variable "rds_force_name" {
  description = "Whether to force the name to something (eg: to be able to terraform import), should not use this unless you're importing"
  type        = string
  default     = ""
}
variable "rds_freeable_memory_low_threshold" {
  description = "If you want to force what port it is on (not recommended)"
  type        = number
  default     = 256000000
}


locals {
  # Automatically get the port based on the engine
  rds_port = (var.rds_force_port > 0 ? var.rds_force_port : (var.rds_engine == "postgres" ? 5432 : 3306))
}


# This wonderful module creates all the alarms you'll ever need for your RDS instance
module "rds-alarms" {
  source  = "lorenzoaiello/rds-alarms/aws"
  version = "2.2.0"

  db_instance_id = module.rds.db_instance_id

  # A list of actions to take when alarms are triggered. Will likely be an SNS topic for event distribution, Default: []
  actions_alarm     = [data.terraform_remote_state.global.outputs.sns_to_slack_arn]
  # A list of actions to take when alarms are cleared. Will likely be an SNS topic for event distribution, Default: []
  actions_ok = [data.terraform_remote_state.global.outputs.sns_to_slack_arn]
  # The default of 100 was alerting too much...
  disk_burst_balance_too_low_threshold = 80
  # This helps us detect if we are using CPU Credits (and adds alarms for it)
  db_instance_class = var.rds_instance_type
  # Disk free storage space too low threshhold
  disk_free_storage_space_too_low_threshold = 1000000000
  # Lower memory warning
  memory_freeable_too_low_threshold = var.rds_freeable_memory_low_threshold
  # Anomalous detection
  anomaly_period = 900
  anomaly_band_width = 4
  create_anomaly_alarm = var.rds_create_anomaly_alert
}


################
# Outputs
################

output "database-hostname" {
  value = module.rds.db_instance_address
}

output "database-port" {
  value = module.rds.db_instance_port
}

output "database-endpoint" {
  value = module.rds.db_instance_endpoint
}

output "database-name" {
  value = module.rds.db_instance_name
}


## Un-sensitive-ize it...
#data "template_file" "database-username" {
#  template = module.rds.db_instance_username
#  /*sensitive = true*/
#}
output "database-username" {
  value = var.rds_initial_username
}

output "database-password" {
  value = random_string.rds.result
}

output "database-sg-to-connect" {
  value = aws_security_group.allow-connections-to-rds.id
}

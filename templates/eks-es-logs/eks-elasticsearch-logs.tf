#############
# EKS Elasticsearch Logs
#############
variable "eks_es_logs_override_name" {
  description = "Whether or not we to override the name of the ES cluster (eg: to import from an existing or older name)"
  type        = string
  default     = ""
}

# The security group for our ElasticSearch cluster
resource "aws_security_group" "this" {
  name        = coalesce(var.eks_es_logs_override_name,module.terraform_tags.id)
  description = "${coalesce(var.eks_es_logs_override_name,module.terraform_tags.id)} allow all from local"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    description     = "http from our security group"
    security_groups = [aws_security_group.allow-connect-to-elasticsearch.id]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "http from our internal network (if allowed)"
    cidr_blocks = [(var.es_allow_local_connections ? var.global_cidrs[var.subenvironment != "" ? var.subenvironment : var.environment] : "127.0.0.1/32")]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "http from any network (if allowed)"
    cidr_blocks = [(var.es_allow_any_connections ? "0.0.0.0/0" : "127.0.0.2/32")]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    description     = "https from our security group"
    security_groups = [aws_security_group.allow-connect-to-elasticsearch.id]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "https from our internal network (if allowed)"
    cidr_blocks = [(var.es_allow_local_connections ? var.global_cidrs[var.subenvironment != "" ? var.subenvironment : var.environment] : "127.0.0.1/32")]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "https from any network (if allowed)"
    cidr_blocks = [(var.es_allow_any_connections ? "0.0.0.0/0" : "127.0.0.3/32")]
  }
}

resource "aws_security_group" "allow-connect-to-elasticsearch" {
  name        = "${coalesce(var.eks_es_logs_override_name,module.terraform_tags.id)}-allow-connections"
  description = "${coalesce(var.eks_es_logs_override_name,module.terraform_tags.id)} allow connections to Elasticsearch if this SG is assigned"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
}

# This is a unique role which must be present for ES clusters to be created
resource "aws_iam_service_linked_role" "this" {
  aws_service_name = "es.amazonaws.com"
}

# Create our ElasticSearch cluster
resource "aws_opensearch_domain" "this" {
  # TEMP
  domain_name = coalesce(var.eks_es_logs_override_name,module.terraform_tags.id)
  engine_version = "OpenSearch_2.5"
  tags           = module.terraform_tags.tags

  cluster_config {
    instance_type            = var.elasticsearch_instance_type
    instance_count           = var.elasticsearch_instance_count
    dedicated_master_enabled = false
    zone_awareness_enabled   = var.elasticsearch_instance_count > 1
  }

  vpc_options {
    subnet_ids         = slice(data.terraform_remote_state.vpc.outputs.private_subnets, 0, var.elasticsearch_instance_count)
    security_group_ids = [aws_security_group.this.id]
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  ebs_options {
    ebs_enabled = true
    throughput  = 250
    volume_size = var.elasticsearch_disk_size
    volume_type = "gp3"
  }

  # snapshot_options {
  #   automated_snapshot_start_hour = 23
  # }

  # For compliance reasons we always want encryption at rest
  encrypt_at_rest {
    enabled    = true
    kms_key_id = aws_kms_key.this.arn
  }

  access_policies = <<POLICIES
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Action": ["es:*","es:ESHttp*"],
          "Principal": { "AWS": "*" },
          "Effect": "Allow",
          "Resource": "arn:aws:es:${var.aws_region}:${data.aws_caller_identity.current.account_id}:domain/${coalesce(var.eks_es_logs_override_name,module.terraform_tags.id)}/*"
        }
    ]
}
POLICIES

  depends_on = [aws_iam_service_linked_role.this]
}

variable "es_allow_local_connections" {
  description = "To allow our entire (internal) CIDR to connect (eg: for dev)"
  type        = bool
  default     = false
}

# For cluster management via terraform over office networks
variable "es_allow_any_connections" {
  description = "To allow any (internal) CIDR to connect (eg: for office networks)"
  type        = bool
  default     = false
}

# Pre-create a bunch of best-practice alarms for ElasticSearch
module "eks-elasticsearch-logs-alarms" {
  source  = "dubiety/elasticsearch-cloudwatch-sns-alarms/aws"
  version = "3.0.3"
  # source            = "/Users/farley/Projects/terraform-aws-elasticsearch-cloudwatch-sns-alarms"

  domain_name       = coalesce(var.eks_es_logs_override_name,module.terraform_tags.id)
  alarm_name_prefix = "${coalesce(var.eks_es_logs_override_name,module.terraform_tags.id)}-"
  sns_topic         = data.terraform_remote_state.sns-to-slack.outputs.sns_to_slack_arn
  create_sns_topic  = false

  # This should be ~25% of your node size storage in bytes
  # Note: at 10% ES gets unusable, never let it get to <10%
  free_storage_space_threshold = var.elasticsearch_disk_size * var.elasticsearch_instance_count * 1024 * 0.15
  # This enables the minimum available node check
  min_available_nodes = var.elasticsearch_instance_count

  # Monitor all the things
  monitor_kms = true

  # These two make it much less verbose until there is an actual problem
  alarm_cluster_status_is_yellow_periods   = 5
  alarm_free_storage_space_too_low_periods = 10
  jvm_memory_pressure_threshold            = 95
  # This CPU threshold will trigger a bit more, but it won't miss overloaded issues as much.  Ref: Farley on May 10, 2023
  cpu_utilization_threshold = 72

  # Tag our resources
  tags = module.terraform_tags.tags_no_name
}


#####################
# Outputs
#####################
output "elasticsearch_domain_name" {
  value = aws_opensearch_domain.this.domain_name
}

output "elasticsearch_endpoint" {
  value = aws_opensearch_domain.this.endpoint
}

output "elasticsearch_kibana_endpoint" {
  value = aws_opensearch_domain.this.kibana_endpoint
}

output "elasticsearch_domain_id" {
  value = aws_opensearch_domain.this.domain_id
}

output "elasticsearch_arn" {
  value = aws_opensearch_domain.this.arn
}

output "elasticsearch_security_group_for_connections" {
  value = aws_security_group.allow-connect-to-elasticsearch.id
}









# Create the Customer Master Key
resource "aws_kms_key" "this" {
  description             = "${module.terraform_tags.id} KMS Key"
  deletion_window_in_days = 15
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.this.json

  tags = merge(module.terraform_tags.tags_no_name, { "Name" = "${module.terraform_tags.id}-kms" })
}

# Create a friendly alias for the KMS Customer Master Key
resource "aws_kms_alias" "this" {
  name          = "alias/${module.terraform_tags.id}-kms"
  target_key_id = aws_kms_key.this.id
}

# Setup an IAM Policy for this KMS key to restrict access to ElasticSearch and to Admins only to encrypt/decrypt this data, it is sensitive!
data "aws_iam_policy_document" "this" {
  statement {
    sid       = "Allow EVERYTHING to all for now TODO restrict access if desired"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "kms:*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

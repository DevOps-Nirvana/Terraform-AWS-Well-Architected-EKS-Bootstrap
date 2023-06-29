# Outputs of this module
output "id" {
  value       = null_resource.default.triggers.id
  description = "Disambiguated ID"
}

output "name" {
  value       = null_resource.default.triggers.name
  description = "Normalized name"
}

output "stage" {
  value       = null_resource.default.triggers.stage
  description = "Normalized stage"
}

output "client" {
  value       = null_resource.default.triggers.client
  description = "Normalized client name"
}

# Merge input tags with our tags.
output "tags" {
  value = merge(
            tomap({
              "Id"        = null_resource.default.triggers.id,
              "Name"      = null_resource.default.triggers.name,
              "Stage"     = null_resource.default.triggers.stage,
              "Client"    = null_resource.default.triggers.client,
              "Terraform" = "true"
            }), var.tags
          )
  description = "Normalized tag map"
}

# Merge input tags with our tags.
output "tags_no_name" {
  value = merge(
            tomap({
              "Id"        = null_resource.default.triggers.id,
              "Stage"     = null_resource.default.triggers.stage,
              "Client"    = null_resource.default.triggers.client,
              "Terraform" = "true"
            }), var.tags
          )

  description = "Normalized tag map without name set"
}


# Use the same tag map as above, but autoscalers expect a list instead of a map
output "asg_tags" {
  value = tolist([
      tomap({"key"="Id",        "value"=null_resource.default.triggers.id,     "propagate_at_launch"=true}),
      tomap({"key"="Name",      "value"=null_resource.default.triggers.name,   "propagate_at_launch"=true}),
      tomap({"key"="Stage",     "value"=null_resource.default.triggers.stage,  "propagate_at_launch"=true}),
      tomap({"key"="Client",    "value"=null_resource.default.triggers.client, "propagate_at_launch"=true}),
      tomap({"key"="Terraform", "value"="true",                                "propagate_at_launch"=true})
    ])

  description = "Normalized tag list for an autoscaler to propogate tags"
}

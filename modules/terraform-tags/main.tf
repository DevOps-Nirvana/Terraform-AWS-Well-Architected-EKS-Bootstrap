# A null resource which allows us to collect data, make local vars out of it, and trigger updates if/when changed
resource "null_resource" "default" {
  triggers = {
    id         = lower(join(var.delimiter, compact(concat(tolist([var.client, var.stage, var.name])))))
    name       = lower(format("%v", var.name))
    # stage      = substr(lower(format("%v", var.stage)),0,  length(var.stage) > 4 ? 4 : -1 )
    stage      = lower(format("%v", var.stage))
    # client     = substr(lower(format("%v", var.client)),0, length(var.client) > 3 ? 3 : -1 )
    client     = lower(format("%v", var.client))
  }

  lifecycle {
    create_before_destroy = true
  }
}

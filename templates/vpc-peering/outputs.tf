output "vpc_peering_connection_ids" {
  value = { for env, connection in aws_vpc_peering_connection.requester : env => connection.id }
}

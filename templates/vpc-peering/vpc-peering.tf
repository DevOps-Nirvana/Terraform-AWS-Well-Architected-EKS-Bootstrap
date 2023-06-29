resource "aws_vpc_peering_connection" "requester" {
  for_each      = var.peering_type == "requester" ? var.peer_environments : {}
  vpc_id        = data.terraform_remote_state.vpc_this.outputs.vpc_id
  peer_owner_id = var.aws_account_ids[each.key]
  peer_region   = each.value.region
  peer_vpc_id   = data.terraform_remote_state.vpc_peers[each.key].outputs.vpc_id
  auto_accept   = false
  tags = merge(module.terraform_tags.tags, {
    "Name" = "vpc-peering-${var.environment}-${each.key}",
    "Side" = "Requester",
    "Peer" = each.key
  })
}

resource "aws_vpc_peering_connection_accepter" "accepter" {
  for_each                  = var.peering_type == "accepter" ? var.peer_environments : {}
  vpc_peering_connection_id = data.terraform_remote_state.vpc_peerings[each.key].outputs.vpc_peering_connection_ids[var.environment]
  auto_accept               = true
  tags = merge(module.terraform_tags.tags, {
    "Name" = "vpc-peering-${each.key}-${var.environment}",
    "Side" = "Accepter",
    "Peer" = each.key
  })
}

resource "aws_route" "peer_routing_private" {
  for_each                  = var.peer_environments
  route_table_id            = data.terraform_remote_state.vpc_this.outputs.private_route_table_ids[0]
  destination_cidr_block    = var.global_cidrs[each.key]
  vpc_peering_connection_id = var.peering_type == "requester" ? aws_vpc_peering_connection.requester[each.key].id : data.terraform_remote_state.vpc_peerings[each.key].outputs.vpc_peering_connection_ids[var.environment]
}

resource "aws_route" "peer_routing_public" {
  for_each                  = var.peer_environments
  route_table_id            = data.terraform_remote_state.vpc_this.outputs.public_route_table_ids[0]
  destination_cidr_block    = var.global_cidrs[each.key]
  vpc_peering_connection_id = var.peering_type == "requester" ? aws_vpc_peering_connection.requester[each.key].id : data.terraform_remote_state.vpc_peerings[each.key].outputs.vpc_peering_connection_ids[var.environment]
}

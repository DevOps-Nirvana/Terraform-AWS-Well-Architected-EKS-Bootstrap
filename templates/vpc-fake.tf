# This is/was created to simulate creating an VPC and setting the outputs accordingly
# this stack is/was used to utilize an already-existing VPC, and generally to minimise cost
# and simplicity.  This is usually used when we don't want a private subnet range to exist

output "vpc_id" {
  value = "vpc-123123123123123"
}

output "azs" {
  value = tolist([
    "us-west-2a",
    "us-west-2b",
    "us-west-2c",
  ])
}

output "private_subnets" {
  value = [
    "subnet-11111111111111111",
    "subnet-22222222222222222",
    "subnet-33333333333333333",
  ]
}

output "public_subnets" {
  value = [
    "subnet-44444444444444444",
    "subnet-55555555555555555",
    "subnet-66666666666666666",
  ]
}

output "private_route_table_ids" {
  value = [
    "rtb-12312312312312312"
  ]
}

output "public_route_table_ids" {
  value = [
    "rtb-34534534534534534"
  ]
}

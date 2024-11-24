output "vpc_id" {
  value = aws_vpc.this.id
}

# output "subnets" {
#   value = [ for key, subnet in aws_subnet.this : this.id ]
#   description = "List of subnets with IDs"
# }

# output "sg" {
#   value = [ for key, sg in aws_security_group.this : this.id ]
#   description = "List of security groups with IDs"
# }
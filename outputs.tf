output "VPC ID" {
    description = "VPC ID"
    value = aws_vpc.dev.id
}

output "Public Subnet 1" {
  description = "Public Subnet 1"
  value = aws_subnet.public1.id
}

output "Private Subnet 1" {
  description = "Privat Subnet 1"
  value = aws_subnet.private1.id
}
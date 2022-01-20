output "vpc_id" {
    description = "VPC ID"
    value = aws_vpc.dev.id
}

output "public_subnet_1" {
  description = "Public Subnet 1"
  value = aws_subnet.public1.id
}

output "private_subnet_1" {
  description = "Privat Subnet 1"
  value = aws_subnet.private1.id
}
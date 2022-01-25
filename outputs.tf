output "region" {
  description = "AWS region"
  value = var.aws_region
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.dev.id
}

output "public_subnet" {
  description = "Public Subnet IDs"
  value       = aws_subnet.public.*.id
}

output "private_subnet" {
  description = "Privat Subnet IDs"
  value       = aws_subnet.private.*.id
}

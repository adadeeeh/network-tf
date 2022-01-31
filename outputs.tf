output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.dev.id
}

output "sq_web" {
  description = "Security group web"
  value       = [aws_security_group.sg_web.id]
}

output "public_subnet" {
  description = "Public Subnet IDs"
  value       = aws_subnet.public.*.id
}

output "private_subnet" {
  description = "Privat Subnet IDs"
  value       = aws_subnet.private.*.id
}

output "lb_target_group_http_arn" {
  description = "ARN of load balancer HTTP target group"
  value       = aws_lb_target_group.http.arn
}

output "public_dns_name" {
  value = aws_lb.lb.dns_name
}
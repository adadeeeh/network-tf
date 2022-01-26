terraform {
  cloud {
    organization = "YtseJam"

    workspaces {
      name = "Network-TF"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.72.0"
    }
  }
  required_version = "~> 1.1.3"
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "dev" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "public" {
  count = var.public_subnet_count

  vpc_id                  = aws_vpc.dev.id
  cidr_block              = var.subnet_cidr_blocks[count.index * 2]
  availability_zone       = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available)]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count = var.private_subnet_count

  vpc_id                  = aws_vpc.dev.id
  cidr_block              = var.subnet_cidr_blocks[(count.index * 2) + 1]
  availability_zone       = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available)]
  map_public_ip_on_launch = false

  tags = {
    Name = "Private subnet ${count.index + 1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = "IGW Dev"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.dev.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "RT Public"
  }

}

resource "aws_route_table_association" "public" {
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = "RT Private"
  }
}

resource "aws_route_table_association" "private" {
  count          = var.private_subnet_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "sg_lb" {
  description = "Allow HTTP"
  name        = "SG Load Balancer"
  vpc_id      = aws_vpc.dev.id

  ingress {
    description = "HTTP ingress"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG Load Balancer"
  }
}

resource "aws_security_group" "sg_web" {
  description = "Allow HTTP"
  name        = "SG Web"
  vpc_id      = aws_vpc.dev.id

  ingress {
    description = "HTTP ingress"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = aws_subnet.public.*.cidr_block
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = aws_subnet.public.*.cidr_block
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "SG Web"
  }
}

resource "aws_lb" "lb" {
  name               = "load-balancer-dev"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_lb.id]
  subnets            = aws_subnet.public.*.id

  tags = {
    Name = "Load Balancer Dev"
  }
}

resource "aws_lb_target_group" "http" {
  name     = "target-group-dev"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.dev.id

  target_type = "instance"

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 1800
    enabled         = true
  }

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    path                = "/index.html"
    port                = 80
  }

  tags = {
    Name = "Load balancer dev target group"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }
}
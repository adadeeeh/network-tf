terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.72.0"
    }
  }
  required_version = "~> 1.1.3"
}

provider "aws" {
  region = "ap-southeast-1"
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
  cidr_block              = var.subnet_cidr_blocks[count.index * 2]
  availability_zone       = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available)]
  map_public_ip_on_launch = false

  tags = {
    Name = "Private subnet ${count.index + 1}"
  }

  resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.dev.id

    tags = {
      Name = "IGW Dev"
    }
  }

  resource "aws_route_table" "public" {
    vpc_id = aws_vpc.dev.ID

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.ID
    }

    tags = {
        Name = "RT Public"
    }

  }

  # resource "aws_route_table_association" "public" {
  #     subnet_id = aws_subnet.public1.id
  #     routetable_id = aws_route_table.public.id
  # }

  # resource "aws_route_table" "private" {
  #   vpc_id = aws_vpc.dev.id

  #   tags = {
  #     Name = "RT Private"
  #   }
  # }
}
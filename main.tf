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
resource "aws_vpc" "dev" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.dev
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public1"
  }
}

resource "aws_subnet" "private1" {
  vpc_id                  = aws_vpc.dev
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "private1"
  }
}
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  required_version = ">= 0.12"
}

provider "aws" {
  profile = "default"
  region  = "ap-southeast-1"
}

locals {
  resource   = "vpc"
  env        = "dev"
  created_at = timestamp()
}


resource "aws_vpc" "dev_angel_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    name       = "dev_angel_vpc"
    env        = local.env
    created_at = local.created_at
  }
}

resource "aws_subnet" "dev_public_subnet" {
  vpc_id                  = aws_vpc.dev_angel_vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-1a"

  tags = {
    Name       = "dev_public_subnet"
    env        = local.env
    created_at = local.created_at
    terraform  = true
  }
}

resource "aws_internet_gateway" "dev_internet_gateway" {
  vpc_id = aws_vpc.dev_angel_vpc.id

  tags = {
    Name       = "dev_igw"
    env        = local.env
    created_at = local.created_at
    terraform  = true
  }
}


resource "aws_route_table" "dev_public_route_table" {
  vpc_id = aws_vpc.dev_angel_vpc.id
  tags = {
    Name       = "dev_public_rt"
    env        = local.env
    created_at = local.created_at
    terraform  = true
  }
}


# Destination_Block need to update based on  permission
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.dev_public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dev_internet_gateway.id
}

resource "aws_route_table_association" "dev_public_route_assoc" {
  subnet_id      = aws_subnet.dev_public_subnet.id
  route_table_id = aws_route_table.dev_public_route_table.id
}


resource "aws_security_group" "dev_security_group" {
  name        = "dev_angel"
  description = "Allow SSH and PostgreSQL inbound traffic"
  vpc_id      = aws_vpc.dev_angel_vpc.id

  #   ingress {
  #     from_port   = 0
  #     to_port     = 0
  #     protocol    = "-1"
  #     cidr_blocks = [aws_vpc.dev_angel_vpc.cidr_block]
  #   }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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
    Name = "allow_tls"
  }
}

## Generate public key gen locally first, before adding public key
# resource "aws_key_pair" "dev_auth" {
#   key_name   = "dev_key"
#   public_key = file("/Users/angel/Keys/angel-key.pub")
# }

## Can add user data template file and then bootstrap commands in that. (user_data)
# need to add datasource file for ami server details
resource "aws_instance" "dev_angel" {
  instance_type          = "t2.micro"
  ami                    = "ami-0f74c08b8b5effa56"
  key_name               = "angel-dev"
  vpc_security_group_ids = [aws_security_group.dev_security_group.id]
  subnet_id              = aws_subnet.dev_public_subnet.id

  root_block_device {
    volume_size = 10
  }
  tags = {
    Name       = "dev_angel"
    env        = local.env
    created_at = local.created_at
    terraform  = true
  }

}
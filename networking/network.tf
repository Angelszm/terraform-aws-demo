##################################################################################
# DATA
##################################################################################

data "aws_availability_zones" "available" {}

##################################################################################
# RESOURCES
##################################################################################

# NETWORKING #
resource "aws_default_vpc" "default" {
  # cidr_block           = var.vpc_cidr_block
  # enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

# resource "aws_internet_gateway" "igw" {
#   vpc_id = aws_default_vpc.default.id

#   tags = merge(local.common_tags, {
#     Name = "${local.name_prefix}-igw"
#   })
# }

resource "aws_subnet" "private_subnet" {
  count                   = var.vpc_private_subnet_count
  cidr_block = var.vpc_private_subnet_cidr_blocks[count.index]
  # cidr_block              = cidrsubnets(var.vpc_private_subnet_cidr_block, 2, count.index)
  # cidr_block              = "${element(var.vpc_private_subnet_cidr_block, count.index)}"
  vpc_id                  = aws_default_vpc.default.id
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-subnet-${count.index}"
  })
}

resource "aws_default_subnet" "default" {
  for_each = toset(local.subnet_azs)

  availability_zone = each.key
}
# resource "aws_subnet" "subnets" {
#   count                   = var.vpc_subnet_count
#   cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index)
#   vpc_id                  = aws_default_vpc.default.id
#   # map_public_ip_on_launch = var.map_public_ip_on_launch
#   availability_zone       = data.aws_availability_zones.available.names[count.index]

#   tags = merge(local.common_tags, {
#     Name = "${local.name_prefix}-subnet-${count.index}"
#   })
# }

# ROUTING #
# resource "aws_route_table" "rtb" {
#   vpc_id = aws_default_vpc.default.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.igw.id
#   }

#   tags = merge(local.common_tags, {
#     Name = "${local.name_prefix}-rtb"
#   })
# }

# resource "aws_route_table_association" "rta-subnets" {
#   count          = var.vpc_subnet_count
#   subnet_id      = aws_subnet.subnets[count.index].id
#   route_table_id = aws_route_table.rtb.id
# }

# SECURITY GROUPS #
# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name   = "${local.name_prefix}-nginx_alb_sg"
  vpc_id = aws_default_vpc.default.id

  #Allow HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags

}

# Nginx security group 
resource "aws_security_group" "nginx-sg" {
  name   = "${local.name_prefix}-nginx_sg"
  vpc_id = aws_default_vpc.default.id

  # HTTP access from VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

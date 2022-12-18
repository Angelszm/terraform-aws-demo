##################################################################################
# DATA
##################################################################################

data "aws_availability_zones" "all"{
 state = "available"
}


##################################################################################
# Local
##################################################################################
locals {
 subnet_count = var.vpc_private_subnet_count >= 2 ? var.vpc_private_subnet_count : length(data.aws_availability_zones.all.names)
}
##################################################################################
# RESOURCES
##################################################################################

# NETWORKING #
resource "aws_default_vpc" "default" {
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-default-vpc"
  })
}

# For Each ## 
resource "aws_default_subnet" "default_subnet" {
  for_each = toset(local.subnet_azs)

  availability_zone = each.key
}

# resource "aws_default_subnet" "default_az1" {
#     availability_zone = "ap-southeast-1a"
#     tags = merge(local.common_tags, {
#     Name = "${local.name_prefix}-default-subnet-ap-southeast-1a"
#   })
# }

# resource "aws_default_subnet" "default_az2" {
#     availability_zone = "ap-southeast-1b"
#     tags = merge(local.common_tags, {
#     Name = "${local.name_prefix}-default-subnet-ap-southeast-1b"
#   })
# }

# resource "aws_default_subnet" "default_az3" {
#     availability_zone = "ap-southeast-1c"
#     tags = merge(local.common_tags, {
#     Name = "${local.name_prefix}-default-subnet-ap-southeast-1c"
#   })
# }

# Create Private Subnet
resource "aws_subnet" "private_subnet" {
  count                   = var.vpc_private_subnet_count
   cidr_block         = cidrsubnet(aws_vpc.vpc_private_subnet_cidr_block, local.subnet_count, count.index)
  # cidr_block = var.vpc_private_subnet_cidr_blocks[count.index]
  # cidr_block              = cidrsubnets(var.vpc_private_subnet_cidr_block, 2, count.index)
  # cidr_block              = "${element(var.vpc_private_subnet_cidr_block, count.index)}"
  vpc_id                  = aws_default_vpc.default.id
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.all.names[count.index]
}

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-subnet-${count.index}"
  })
}


# Create EIP for NAT GW1  
resource "aws_eip" "eip_natgw" {  
    count = local.eip_count
} 

# Create NAT gateway1
resource "aws_nat_gateway" "natgateway" {  
    count = local.eip_count
     dynamic "subnet_mapping" {
      for_each = aws_default_subnet.default_subnet

    content {
      subnet_id     = subnet_mapping.value.id
      allocation_id = aws_eip.eip_natgw[index(local.subnet_azs, subnet_mapping.value.availability_zone)].id : null
    }
} 
}

# ROUTE Table for Private Subnet#
resource "aws_route_table" "private_rtb" {
  vpc_id = aws_default_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgateway[count_index].id
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-subnet-rt-${count.index}"
  })
}

#Create route table association betn private subnet & NAT GW

resource "aws_route_table_association" "private_rta_subnet" {
  count          = var.vpc_private_subnet_count
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rtb.id
}


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
resource "aws_security_group" "nginx_sg" {
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
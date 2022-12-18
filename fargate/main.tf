terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  required_version = ">= 0.12"
}

provider "aws" {
  region  = var.aws_region
}

# SECURITY GROUPS #
# Application Load Balancer Security Group
resource "aws_security_group" "alb_sg" {
  name   = "alb-sg"
  vpc_id = var.vpc_id

  # HTTP & HTTPS access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "alb" {
  name               = local.common_tags.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.vpc_subnets

  enable_deletion_protection = false
  tags = local.common_tags
}

resource "aws_lb_target_group" "angel" {
  name     = local.common_tags.name
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"
   health_check {
    path = "/health"
  }
  tags = local.common_tags
}

resource "aws_lb_listener" "angel" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
    }
  tags = local.common_tags
}

resource "aws_lb_listener" "angel_secure" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.angel.arn
  }

  tags = local.common_tags
}


resource "aws_security_group" "ecs_service" {
  name        = "ecs-service-test"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "-1"
    from_port       = 0
    to_port         = 0
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_ecs_cluster" "angel" {
  name = local.name
}

resource "aws_ecs_cluster_capacity_providers" "angel" {
  cluster_name = aws_ecs_cluster.angel.name

  capacity_providers = ["FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 0
    weight            = 1
    capacity_provider = "FARGATE_SPOT"
  }
}


resource "aws_ecs_service" "angel_service" {
  tags= local.common_tags
  name            = local.name
  cluster         = aws_ecs_cluster.angel.id
  task_definition = "arn:aws:ecs:ap-southeast-1:account_id:task-definition/angel:2"
  capacity_provider_strategy {
      capacity_provider = "FARGATE_SPOT"
      weight = 1
      base = 0
  }
#   launch_type     = "FARGATE"
  desired_count   = 1
  network_configuration {
    subnets          = var.vpc_subnets
    security_groups = [aws_security_group.ecs_service.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.angel.arn
    container_name   = "angel_container"
    container_port   = 8080
  }
    depends_on = [aws_lb_listener.angel]
}

# resource "aws_ecs_cluster" "angel_cluster" {
#   name = local.name
#   tags = {
#     Name                   = local.name
#     Cloud_Service          = local.resource
#     Deployment_Environment = local.env
#     Created_at             = local.created_at
#   }
# }

# resource "aws_ecs_service" "angel_service" {
#   name            = local.name
#   cluster         = aws_ecs_cluster.angel_cluster.id
#   task_definition = aws_ecs_task_definition.angel_task.arn
#   launch_type     = "FARGATE"
#   desired_count   = 1
#   network_configuration {
#     subnets          = ["subnet-0c25aaaabdd43385c", "subnet-0f6118018e84d763f", "subnet-0c996d6558d24862e"]
#     assign_public_ip = false
#   }
# }

# resource "aws_ecs_task_definition" "angel_task" {
#   family                   = "angel_task"
#   container_definitions    = <<DEFINITION
#   [
#     {
#       "name": "angel_task",
#       "image": "account-id.dkr.ecr.ap-southeast-1.amazonaws.com/angel-service",
#       "essential": true,
#       "cpu": 256,
#       "memory": 512,
#       "portMappings": [
#         {
#           "containerPort": 8080,
#           "hostPort": 8080
#         }
#       ]
#     }
#   ]
#   DEFINITION
#   requires_compatibilities = ["FARGATE"]
#   network_mode             = "awsvpc"
#   memory                   = 512
#   cpu                      = 256
#   execution_role_arn  = "arn:aws:iam::account-id:role/ecsTaskExecutionRole"
#   task_role_arn = "arn:aws:iam::account-id:role/ecsTaskExecutionRole"
# }


# resource "aws_ecs_task_definition" "angel_task" {
#   family                   = "angel_task"
#   container_definitions    = <<DEFINITION
#   [
#     {
#       "name": "angel_task",
#       "image": "account-id.dkr.ecr.ap-southeast-1.amazonaws.com/angel-service",
#       "essential": true,
#       "cpu": 256,
#       "memory": 512,
#       "portMappings": [
#         {
#           "containerPort": 8080,
#           "hostPort": 8080
#         }
#       ]
#     }
#   ]
#   DEFINITION
#   requires_compatibilities = ["FARGATE"]
#   network_mode             = "awsvpc"
#   memory                   = 512
#   cpu                      = 256
#   execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
# }
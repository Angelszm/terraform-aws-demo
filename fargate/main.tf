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
  name       = "angel-service"
  resource   = "ecs"
  env        = var.env
  created_at = timestamp()
}

resource "aws_ecs_cluster" "angel_cluster" {
  name = local.name
  tags = {
    Name                   = local.name
    Cloud_Service          = local.resource
    Deployment_Environment = local.env
    Created_at             = local.created_at
  }
}

resource "aws_ecs_service" "angel_service" {
  name            = local.name
  cluster         = aws_ecs_cluster.angel_cluster.id
  task_definition = aws_ecs_task_definition.angel_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  network_configuration {
    subnets          = ["subnet-0c25aaaabdd43385c", "subnet-0f6118018e84d763f", "subnet-0c996d6558d24862e"]
    assign_public_ip = false
  }
}

resource "aws_ecs_task_definition" "angel_task" {
  family                   = "angel_task"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "angel_task",
      "image": "account-id.dkr.ecr.ap-southeast-1.amazonaws.com/angel-service",
      "essential": true,
      "cpu": 256,
      "memory": 512,
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 8080
        }
      ]
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn  = "arn:aws:iam::account-id:role/ecsTaskExecutionRole"
  task_role_arn = "arn:aws:iam::account-id:role/ecsTaskExecutionRole"
}


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
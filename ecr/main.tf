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
  name         = "angel-service"
  resource     = "ecr"
  created_at   = timestamp()
}

resource "aws_ecr_repository" "angel-service" {
  name                 = var.repo_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
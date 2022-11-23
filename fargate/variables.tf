variable "ecs_name" {
  type        = string
  default     = "angel-service"
  description = "ECS Fargate Name"
}

variable "env" {
  description = "Environment Name / Workspace Name"
  type = string
  default = "default"
}
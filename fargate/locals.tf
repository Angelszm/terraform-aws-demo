locals {
  common_tags={
      name = "${var.org}-${var.env}"
  }
  name       = var.ecs_service_name
  env        = var.env
  created_at = timestamp()
}
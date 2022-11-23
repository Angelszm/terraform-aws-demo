output "ecs_cluster_arn" {
  value       = aws_ecs_cluster.angel_cluster.id
  description = "Full Arn of ECS Cluster"
}

output "ecs_service_arn" {
  value       = aws_ecs_service.angel_service.id
  description = "Full Arn of ECS Cluster Service"
}
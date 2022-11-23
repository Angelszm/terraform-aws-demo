output "arn" {
  value       = aws_ecr_repository.angel-service.arn
  description = "Full ARN to image in ECR with Tag"
}
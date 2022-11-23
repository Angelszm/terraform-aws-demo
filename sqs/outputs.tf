output "sqs_arn" {
  value       = aws_sqs_queue.angel_sqs.arn
  description = "Full Arn of SQS Queue"
}


output "sqs_queue_url" {
  value       = aws_sqs_queue.angel_sqs.url
  description = "Queue Url"
}

output "thing_id" {
  value       = aws_iot_thing.angel_test.id
  description = "Full Arn of IoT Thing"
}

output "thing_type" {
  value       = aws_iot_thing_type.angel_test.id
  description = "IoT Thing Type"
}

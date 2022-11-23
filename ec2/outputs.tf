output "instance_ip_addr" {
  value = aws_instance.dev_angel.*.public_ip
}
variable "sqs_name" {
  description = "Name of the sqs queue to be created. You can assign any unique name for the Queue"
  default = "angel-sqs"
}

variable "env" {
  description = "Environment Name / Workspace Name"
  type = string
  default = "default"
}
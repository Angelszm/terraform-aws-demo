locals {
   subnet_azs = [
    "ap-southeast-1a",
    "ap-southeast-1b",
    "ap-southeast-1c",
  ]

  eip_count = length(local.subnet_azs)

  common_tags = {
    company      = var.company
    project      = "${var.company}-${var.project}"
  }

  name_prefix    = "${var.naming_prefix}-dev"
  s3_bucket_name = "${local.name_prefix}-${var.project}"
}

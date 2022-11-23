variable "bucket_name" {
  description = "S3 Bucket-Name. Must be unique."
  type        = string
}

variable "bucket_prefix" {
  description = "Can add region as prefix for our hosting buckets.A unique bucket name beginning with the specified prefix."
  type        = string
  default     = ""
}


variable "acl" {
  description = "(Optional)The canned ACL to apply to the bucket. Valid values are private, public-read, public-read-write, aws-exec-read, authenticated-read, bucket-owner-read, and bucket-owner-full-control. Defaults to private."
  type        = string
  default     = "private"

}

# variable "Description" {
#   description = "Description of bucket"
#   type        = string
# }

variable "region" {
  description = "Region where s3 bucket exists"
  type        = string
  default     = "ap-southeast-1"
}

variable "env" {
  description = "Workspace Name"
  type = string
  default = "default"
}

variable "cloudfront_allowed_methods" {
  description = "Cloudfront allowed methods"
  type = list
  default = []
}

variable "default_root_object" { 
  description = "Default root object"
  type = string
  default = ""
}
## This is for S3 Bucket, Cloudfront and Route 53 : Public Website Hosting

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  required_version = ">= 0.12"
}

locals {
  name         = "${var.env}-${var.bucket_name}"
  env          = "${var.env}"
  created_at   = timestamp()
}

########################
# S3 Bucket creation
########################
resource "aws_s3_bucket" "angel-public-website_s3_terraform_bucket" {
  bucket = local.name
  tags = {
    Name              = local.name
    Cloud_Service     = local.resource
    Deployment_Environment = local.env
    Created_at   = local.created_at
    terraform    = true
  }
}

########################
# Default AWS Region
########################
provider "aws" {
  profile = "default"
  region  = "ap-southeast-1"
}

########################
# S3 Bucket Private Access
########################
resource "aws_s3_bucket_acl" "angel-public-website_s3_terraform_bucket" {
  bucket =  aws_s3_bucket.angel-public-website_s3_terraform_bucket.id
  acl    = var.acl
}


#############################
# Enable bucket versioning
#############################
resource "aws_s3_bucket_versioning" "angel-public-website_s3_terraform_bucket_versioning" {
  bucket = aws_s3_bucket.angel-public-website_s3_terraform_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}


#############################
# Attach bucket Policy
#############################
resource "aws_s3_bucket_policy" "bucket_policy" {
  # bucket = "${aws_s3_bucket.bucket.id}"
  bucket =  aws_s3_bucket.angel-public-website_s3_terraform_bucket.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "${aws_s3_bucket.angel-public-website_s3_terraform_bucket.arn}/*"
    }
  ]
}
EOF
}

#############################
# S3 Bucket Website Configuration
#############################
resource "aws_s3_bucket_website_configuration" "s3_public_website_hosting" {
  bucket = aws_s3_bucket.angel-public-website_s3_terraform_bucket.id
  index_document {
      suffix = "index.html"
    }
  error_document {
      key = "error.html"
    }
}


###################################
# CloudFront Access Identity
###################################
resource "aws_cloudfront_origin_access_identity" "angel-public-website_cloudfront_origin_access_id" {
  comment = "Custom-${var.env}"
}

###################################
# CloudFront Distribution
###################################
resource "aws_cloudfront_distribution" "angel-public-website_cloudfront" {
  enabled             = true
  default_root_object = "index.html"
  depends_on = [aws_cloudfront_origin_access_identity.angel-public-website_cloudfront_origin_access_id, aws_s3_bucket.angel-public-website_s3_terraform_bucket]
#   aliases             = [aws_s3_bucket.angel-public-website_s3_terraform_bucket.id]

  custom_error_response {
    error_caching_min_ttl = 0
    error_code = 404
    response_code = 200
    response_page_path = "/index.html"
  }

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.angel-public-website_s3_terraform_bucket.id
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    min_ttl     = 0
    default_ttl = 5 * 60
    max_ttl     = 60 * 60

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }
  }

  origin {
    domain_name = aws_s3_bucket.angel-public-website_s3_terraform_bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.angel-public-website_s3_terraform_bucket.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    ssl_support_method = "sni-only"
  }
}
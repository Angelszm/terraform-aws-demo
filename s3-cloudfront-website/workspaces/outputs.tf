output "arn" {
  description = "ARN of the bucket"
  value       = aws_s3_bucket.angel-public-website_s3_terraform_bucket.arn
}

output "name" {
  description = "Name (id) of the bucket"
  value       = aws_s3_bucket.angel-public-website_s3_terraform_bucket.id
}

output "website" {
    description = "S3 Website Hosting URL"
    value = aws_s3_bucket_website_configuration.s3_public_website_hosting.website_endpoint
}

output "cloudfront_domain_name" {
  value       = aws_cloudfront_distribution.angel-public-website_cloudfront.domain_name
  description = "Domain name corresponding to the distribution"
}
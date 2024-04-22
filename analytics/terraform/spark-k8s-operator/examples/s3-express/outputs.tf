output "s3_express_directory_bucket_name" {
  description = "S3 express directory bucket"
  value       = aws_s3_directory_bucket.xpbucket.id
  precondition {
    condition     = length(local.s3_azs_in_region) > 0
    error_message = "S3 express directory bucket is not supported in this region."
  }
}

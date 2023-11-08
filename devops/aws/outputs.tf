output "bucket_name" {
  value = aws_s3_bucket.this.bucket
}

output "role_arn" {
  value = aws_iam_role.this.arn
}

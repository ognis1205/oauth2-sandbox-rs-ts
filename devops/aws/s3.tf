resource "aws_s3_bucket" "this" {
  bucket        = "${var.prefix}-bucket"
  force_destroy = true
  tags = {
    Name = "${var.prefix}-tag"
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

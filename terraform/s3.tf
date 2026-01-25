resource "aws_s3_bucket" "example" {
  bucket = var.s3_buckets[0]

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
resource "aws_s3_bucket" "bucket" {
  for_each = toset(var.s3_buckets)
  
  bucket = each.value
  
}

# Ensure datas encrypted at rest (true by default)
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket" {
  for_each = toset(var.s3_buckets)
  
  bucket = aws_s3_bucket.bucket[each.key].id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"  # aws managed free encryption
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "bucket" {
  for_each = toset(var.s3_buckets)
  
  bucket = aws_s3_bucket.bucket[each.key].id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket" {
  for_each = toset(var.s3_buckets)
  
  bucket = aws_s3_bucket.bucket[each.key].id
  
  rule {
    id     = "limit-version-retention"
    status = "Enabled"
    
    noncurrent_version_expiration {
    #   noncurrent_days           = 1  # Optional: wait 1 day before deleting
      newer_noncurrent_versions = 2  # Keep only the 2 most recent noncurrent versions
    }
  }

  rule {
    id     = "transition-old-objects"
    status = "Enabled"
    
    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }
  }
}
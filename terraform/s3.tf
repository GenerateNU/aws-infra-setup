resource "aws_s3_bucket" "bucket" {
  for_each = toset(var.s3_buckets)
  
  bucket = each.value
  
  lifecycle {
    prevent_destroy = true
  }
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
  
  lifecycle {
    prevent_destroy = true
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
  
  lifecycle {
    prevent_destroy = true
  }
}

# Enable bucket versioning, to keep the last 3 copies of an object 
resource "aws_s3_bucket_versioning" "bucket" {
  for_each = toset(var.s3_buckets)
  
  bucket = aws_s3_bucket.bucket[each.key].id
  
  versioning_configuration {
    status = "Enabled"
  }
  
  lifecycle {
    prevent_destroy = true
  }
}

# Limit versioning to 3 copies 
resource "aws_s3_bucket_lifecycle_configuration" "bucket" {
  for_each = toset(var.s3_buckets)
  
  bucket = aws_s3_bucket.bucket[each.key].id
  
  rule {
    id     = "limit-version-retention"
    status = "Enabled"

    filter {}  #  applies to all objects
    
    noncurrent_version_expiration {
      noncurrent_days           = 1
      newer_noncurrent_versions = 2  # Keep only the 2 most recent noncurrent versions
    }
  }
  
  lifecycle {
    prevent_destroy = true
  }
}
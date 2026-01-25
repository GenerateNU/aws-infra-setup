# Run this ONCE to create the backend resources (storing state in AWS S3)
provider "aws" {
  region = "us-east-2"
}

# S3 bucket for Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "generate-infra-terraform-state-bucket"

  tags = {
    Name        = "Terraform State Bucket"
    Purpose     = "Terraform Backend"
    ManagedBy   = "Terraform"
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    # Keep only the 3 most recent noncurrent versions
    noncurrent_version_expiration {
      noncurrent_days = 1  # Delete versions older than 1 day
      newer_noncurrent_versions = 3  # But keep the 3 newest noncurrent versions
    }

    # Delete incomplete multipart uploads after 7 days
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  rule {
    id     = "expire-delete-markers"
    status = "Enabled"

    # Remove delete markers that have no noncurrent versions
    expiration {
      expired_object_delete_marker = true
    }
  }
}

# Enable encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Outputs
output "s3_bucket_name" {
  value       = aws_s3_bucket.terraform_state.id
  description = "The name of the S3 bucket for Terraform state"
}

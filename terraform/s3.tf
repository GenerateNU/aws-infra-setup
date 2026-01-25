resource "aws_s3_bucket" "bucket" {
  for_each = toset(var.s3_buckets)
  
  bucket = each.value
  
  tags = {
    Name        = each.value
    ManagedBy   = "Terraform"
    TeamPrefix  = var.team_prefix
  }
}
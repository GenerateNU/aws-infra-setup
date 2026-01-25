output "s3_bucket_names" {
  value = [for bucket in aws_s3_bucket.bucket : bucket.id]
}

output "iam_user_names" {
  value = [for user in aws_iam_user.user : user.name]
}
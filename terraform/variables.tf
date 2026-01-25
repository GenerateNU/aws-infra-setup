variable "team_name" {
  description = "Team name prefix for resources"
  type        = string
  default     = ""
}

variable "s3_buckets" {
  description = "List of S3 buckets to create"
  type        = list(string)
  default     = []
}

variable "iam_users" {
  description = "List of IAM users to create"
  type        = list(string)
  default     = []
}
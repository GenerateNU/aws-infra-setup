resource "aws_iam_user" "user" {
  for_each = toset(var.iam_users)
  
  name = each.value
  
  tags = {
    Name      = each.value
    ManagedBy = "Terraform"
  }
}
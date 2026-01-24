######### Service role to Privision AWS Infra ###########
# resource "aws_iam_role" "github_actions" {
#   name = "GitHubActionsRole"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         Federated = "arn:aws:iam::478867930449:oidc-provider/token.actions.githubusercontent.com"
#       }
#       Action = "sts:AssumeRoleWithWebIdentity"
#       Condition = {
#         StringEquals = {
#           "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
#         }
#         StringLike = {
#           "token.actions.githubusercontent.com:sub" = "repo:GenerateNU/aws-infra-setup:*"
#         }
#       }
#     }]
#   })
# }

# # Attach permissions the role needs
# resource "aws_iam_role_policy_attachment" "github_actions" {
#   role       = aws_iam_role.github_actions.name
#   policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"  # TO DO: Scope down policy
# }
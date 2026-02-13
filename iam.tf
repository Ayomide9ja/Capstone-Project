# Requirement 4.3: IAM User (bedrock-dev-view)
resource "aws_iam_user" "bedrock_dev" {
  name = "bedrock-dev-view"
}

# Create Access Keys for Grading Deliverable
resource "aws_iam_access_key" "bedrock_dev_key" {
  user = aws_iam_user.bedrock_dev.name
}

# Attach ReadOnlyAccess (Console Access)
resource "aws_iam_user_policy_attachment" "readonly_attach" {
  user       = aws_iam_user.bedrock_dev.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
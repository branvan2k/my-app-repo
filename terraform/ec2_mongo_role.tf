resource "aws_iam_role" "mongo_admin_role" {
  name = "MongoAdminRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy_attachment" "admin_policy_attach" {
  name       = "MongoAdminPolicyAttach"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"  # Full admin access
  roles      = [aws_iam_role.mongo_admin_role.name]
}

resource "aws_iam_instance_profile" "mongo_admin_profile" {
  name = "MongoAdminInstanceProfile"
  role = aws_iam_role.mongo_admin_role.name
}
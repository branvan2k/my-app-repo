resource "aws_iam_role" "ec2_backup_role" {
  name = "ec2-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}
resource "aws_iam_role_policy" "s3_backup_policy" {
  name = "s3-backup-policy"
  role = aws_iam_role.ec2_backup_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::backup-bucket-aff",
          "arn:aws:s3:::backup-bucket-aff/*"
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_backup_profile" {
  name = "ec2-backup-profile"
  role = aws_iam_role.ec2_backup_role.name
}

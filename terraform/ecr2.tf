# Crear un nuevo repositorio ECR para la imagen de Django
resource "aws_ecr_repository" "django_app_2" {
  name = "django-app-2"

  tags = {
    Name = "Django App 2"
  }
}


# Crear la política de repositorio de ECR
resource "aws_ecr_repository_policy" "django_app_2_policy" {
  repository = aws_ecr_repository.django_app_2.name

  policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Sid    = "AllowPushPull"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.ec2_manager_role.arn
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage"
        ]
      }
    ]
  })
}

# Crear un rol de IAM para permitir que EKS acceda al ECR
resource "aws_iam_role" "eks_ecr_access_role_2" {
  name = "eks-ecr-access-role-2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

# Adjuntar la política de solo lectura al rol de ECR
resource "aws_iam_role_policy_attachment" "eks_ecr_read_only_2" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_ecr_access_role_2.name
}
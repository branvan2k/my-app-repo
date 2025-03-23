# Crear el rol IAM para la instancia EC2
resource "aws_iam_role" "ec2_manager_role" {
  name = "ec2-manager-role"

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

# Adjuntar la política AmazonEC2ContainerRegistryFullAccess al rol (ECR)
resource "aws_iam_role_policy_attachment" "ecr_full_access" {
  role       = aws_iam_role.ec2_manager_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

# Crear una política IAM para permitir acceso a EKS
resource "aws_iam_policy" "eks_access_policy" {
  name        = "EC2EKSAccessPolicy"
  description = "Allows EC2 to access EKS"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:ListNodegroups",
          "eks:DescribeNodegroup",
          "eks:AccessKubernetesApi",
          "sts:AssumeRole"
        ]
        Resource = "*"
      }
    ]
  })
}

# Adjuntar la política personalizada de acceso a EKS al rol
resource "aws_iam_role_policy_attachment" "ec2_eks_access" {
  policy_arn = aws_iam_policy.eks_access_policy.arn
  role       = aws_iam_role.ec2_manager_role.name
}

# Crear un perfil de instancia IAM para asociar el rol con la instancia EC2
resource "aws_iam_instance_profile" "ec2_manager_profile" {
  name = "ec2-manager-profile"
  role = aws_iam_role.ec2_manager_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_eks_admin" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.ec2_manager_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_eks_worker_node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.ec2_manager_role.name
}


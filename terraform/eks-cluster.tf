// Define an IAM role for the EKS cluster control plane
resource "aws_iam_role" "eks_cluster_role2" {
  name = "eks-cluster_role2"

  // Specify the permissions for assuming this role
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

// Attach AmazonEKSClusterPolicy to the IAM role created for EKS cluster
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role2.name
}

// Attach AmazonEKSServicePolicy to the IAM role created for EKS cluster
resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role2.name
}

// Create an EKS cluster
resource "aws_eks_cluster" "aff-cluster" {
  name     = "aff_cluster"
  role_arn = aws_iam_role.eks_cluster_role2.arn

  // Configure VPC for the EKS cluster
  vpc_config {
    subnet_ids              = ["subnet-0f6e3dfdb92c44df0", "subnet-07ae06fbdb7ac014f"]
    endpoint_public_access  = true
    endpoint_private_access = false
  }

  // Add tags to the EKS cluster for identification
  tags = {
    Name = "AFF Cluster"
  }
}

// Define an IAM role for EKS worker nodes
resource "aws_iam_role" "worker-nodes-role" {
  name = "worker-nodes-role"

  // Specify the permissions for assuming this role
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

// Attach AmazonEKSWorkerNodePolicy to the IAM role created for EKS worker nodes
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker-nodes-role.name
}

// Attach AmazonEKS_CNI_Policy to the IAM role created for EKS worker nodes
resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker-nodes-role.name
}

// Attach AmazonSSMManagedInstanceCore_Policy
resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.worker-nodes-role.name
}

// Attach AmazonEC2ContainerRegistryReadOnly to the IAM role created for EKS worker nodes
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker-nodes-role.name
}

// Create an EKS node group
resource "aws_eks_node_group" "node-group-aff" {
  cluster_name    = aws_eks_cluster.aff-cluster.name
  node_group_name = "node-group-aff"
  node_role_arn   = aws_iam_role.worker-nodes-role.arn
  subnet_ids      = ["subnet-0f6e3dfdb92c44df0", "subnet-07ae06fbdb7ac014f"]

  // Configure scaling options for the node group
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  ami_type       = "AL2_x86_64"
  instance_types = ["t3.medium"]
  disk_size      = 20

  labels = {
    role = "worker"
  }

  # Configuración de acceso remoto
  remote_access {
    ec2_ssh_key               = var.PUB_KEY # Reemplaza con tu clave SSH
    source_security_group_ids = [aws_security_group.eks_nodes_sg.id, aws_security_group.ec2_sg.id]
  }


  // Ensure that the creation of the node group depends on the IAM role policies being attached
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

# Salida del nombre del cluster y el endpoint
output "cluster_name" {
  value = aws_eks_cluster.aff-cluster.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.aff-cluster.endpoint
}


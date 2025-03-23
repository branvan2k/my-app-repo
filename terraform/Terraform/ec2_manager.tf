resource "aws_instance" "manager-instance" {
  ami                    = var.AMI_d[var.REGION]
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet_1.id
  key_name               = var.PUB_KEY
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_manager_profile.name

  user_data = <<-EOF
              #!/bin/bash
              set -e

              # Actualizar el sistema
              sudo hostnamectl set-hostname manager
              apt update -y && apt upgrade -y
              
              # Instalar herramientas básicas
              apt install -y git plocate wget curl unzip tar gzip software-properties-common
              
              # Instalar AWS CLI
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              ./aws/install
              
              # Instalar kubectl
              curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/kubernetes-archive-keyring.gpg
              echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-jammy main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
                            
              # Instalar Terraform
              wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
              echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $$(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
             
              # Instalar Docker
              apt install -y apt-transport-https ca-certificates curl software-properties-common
              install -m 0755 -d /etc/apt/keyrings
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.asc
              chmod a+r /etc/apt/keyrings/docker.asc
              echo \
                "deb [arch=$$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
                 $$(. /etc/os-release && echo "$${UBUNTU_CODENAME:-$$VERSION_CODENAME}") stable" | \
                 tee /etc/apt/sources.list.d/docker.list > /dev/null
              apt update -y 
              apt-get install -y kubectl terraform docker.io containerd


              # Limpiar caché
              apt clean
              EOF

  tags = {
    Name = "manager-instance"
  }
}

output "PublicIP_Manager" {
  value = aws_instance.manager-instance.public_ip
}

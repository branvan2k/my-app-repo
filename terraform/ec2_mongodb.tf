

resource "aws_instance" "mongodb-instance" {
  ami                    = var.AMI_b[var.REGION]
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet_1.id
  key_name               = var.PUB_KEY
  vpc_security_group_ids = [aws_security_group.ec2_sg.id, aws_security_group.mongo_sg.id]
 // iam_instance_profile   = aws_iam_instance_profile.ec2_backup_profile.name
  iam_instance_profile   = aws_iam_instance_profile.mongo_admin_profile.name  


  user_data = <<-EOF
              #!/bin/bash
              set -e

              # Actualizar el sistema
              apt update -y && apt upgrade -y
              
              # Instalar herramientas básicas
              apt install -y git wget curl unzip tar gzip software-properties-common
               
              # Install AWS CLI
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              ./aws/install

              # Agregar la clave GPG de MongoDB
              curl -fsSL https://pgp.mongodb.com/server-6.0.asc | \
              gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg \
              --dearmor

              # Agregar el repositorio de MongoDB 6.0
              echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | \
              tee /etc/apt/sources.list.d/mongodb-org-6.0.list

              # Actualizar la lista de paquetes
              apt-get update -y

              # Instalar MongoDB 6.0.4
              apt-get install -y mongodb-org=6.0.4 mongodb-org-database=6.0.4 mongodb-org-server=6.0.4 mongodb-org-mongos=6.0.4 mongodb-org-tools=6.0.4

              # Iniciar y habilitar MongoDB
              systemctl start mongod
              systemctl enable mongod

              # Obtener la IP privada de la instancia MongoDB
              DB_HOST=$(hostname -I | awk '{print $1}')

              # Modificar la configuración de MongoDB para bindIp
              sed -i "s/^ *bindIp:.*/  bindIp: $DB_HOST/" /etc/mongod.conf

              # Reiniciar MongoDB para aplicar los cambios
              systemctl restart mongod

              # Definir variables sensibles en /etc/environment
              echo "DB_NAME=blogdb" >> /etc/environment
              echo "DB_USER=adminUser" >> /etc/environment
              echo "DB_PASSWD=StrongPassword123" >> /etc/environment
              echo "DB_AUTH=admin" >> /etc/environment
              echo "DB_HOST=$(hostname -I | awk '{print $1}') >> /etc/environment
              source /etc/environment

              # Crear directorio de scripts
              mkdir -p /opt/scripts
              cd /opt/scripts

              # Crear script de backup
              cat << 'EOL' > backup_db.sh
              #!/bin/bash
              source /etc/environment
              BUCKET_NAME="backup-bucket-aff"
              TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
              BACKUP_DIR="/tmp/mongo_backups"
              BACKUP_FILE="$BACKUP_DIR/mongo_backup_$TIMESTAMP.tar.gz"
              mkdir -p $BACKUP_DIR
              mongodump --uri="mongodb://$DB_USER:$DB_PASSWD@$DB_ADDRESS:27017/$DB_NAME?authSource=admin" --out $BACKUP_DIR/mongo_dump_$TIMESTAMP
              tar -czf $BACKUP_FILE -C $BACKUP_DIR mongo_dump_$TIMESTAMP
              aws s3 cp $BACKUP_FILE s3://$BUCKET_NAME/
              find $BACKUP_DIR -type f -name "*.tar.gz" -mtime +7 -exec rm {} \;
              echo "Backup realizado y subido a S3: $BACKUP_FILE"
              EOL

              # Dar permisos de ejecución
              chmod +x /opt/scripts/backup_db.sh

              # Programar en crontab para ejecutarlo todas las noches a las 2 AM
              (crontab -l 2>/dev/null; echo "0 2 * * * /opt/scripts/backup_db.sh >> /var/log/backup.log 2>&1") | crontab -

              EOF

  tags = {
    Name = "MongoDB_Instance"
  }
}

output "PublicIP_MongoDB" {
  value = aws_instance.mongodb-instance.public_ip
}

output "mongodb_private_ip" {
  value = aws_instance.mongodb-instance.private_ip
}
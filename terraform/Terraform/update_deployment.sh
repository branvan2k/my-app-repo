#!/bin/bash

# Obtener la dirección IP privada de Terraform
PRIVATE_IP=$(terraform output -raw mongodb_private_ip)

# Reemplazar el marcador de posición en el archivo deployment.yaml
sed -i "s/<MONGODB_PRIVATE_IP>/$PRIVATE_IP/g" Manifests/blog-deployment.yaml

echo "La dirección IP privada ($PRIVATE_IP) ha sido insertada en deployment.yaml."

#!/bin/bash

# Obtener la dirección IP privada de MongoDB desde Terraform
DB_HOST=$(terraform output -raw mongodb_private_ip)

# Verificar si se obtuvo una IP válida
if [[ -z "$DB_HOST" ]]; then
  echo "Error: No se pudo obtener la dirección IP privada de MongoDB desde Terraform."
  exit 1
fi

# Crear el archivo ConfigMap de Kubernetes
cat <<EOF > mongo-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mongo-config
data:
  DB_HOST: "$DB_HOST"
EOF

echo "ConfigMap generado correctamente en mongo-config.yaml"


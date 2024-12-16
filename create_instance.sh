#!/bin/bash

# Variables
PACKER_TEMPLATE="aws-ubuntu.pkr.hcl"  # Nombre de la plantilla Packer
INSTANCE_TYPE="t2.micro"              # Tipo de instancia
KEY_NAME="MarcoKeyPair"               # Nombre de tu par de claves AWS
SECURITY_GROUP="MarcoServerGroup"     # Grupo de seguridad
REGION="us-east-1"                    # Región de AWS

# 1. Ejecutar Packer para crear la imagen
echo "Ejecutando Packer para crear la imagen..."
packer build $PACKER_TEMPLATE
if [ $? -ne 0 ]; then
  echo "Error: Falló la creación de la imagen con Packer."
  exit 1
fi

# 2. Obtener el ID de la última AMI creada
echo "Obteniendo el ID de la nueva AMI..."
AMI_ID=$(aws ec2 describe-images --owners self --filters "Name=name,Values=packer-linux-nginx" --query "Images[0].ImageId" --output text --region $REGION)
if [ "$AMI_ID" == "None" ]; then
  echo "Error: No se encontró ninguna AMI con el nombre especificado."
  exit 1
fi
echo "AMI creada con éxito: $AMI_ID"

# 3. Crear una instancia basada en la nueva AMI
echo "Creando una instancia EC2 basada en la AMI $AMI_ID..."
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --count 1 \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_NAME \
  --security-groups $SECURITY_GROUP \
  --query "Instances[0].InstanceId" \
  --output text \
  --region $REGION)

if [ $? -ne 0 ]; then
  echo "Error: Falló la creación de la instancia."
  exit 1
fi
echo "Instancia creada con éxito: $INSTANCE_ID"

# 4. Esperar a que la instancia esté en estado 'running'
echo "Esperando a que la instancia esté en estado 'running'..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region $REGION
if [ $? -ne 0 ]; then
  echo "Error: La instancia no alcanzó el estado 'running'."
  exit 1
fi

# 5. Obtener la IP pública de la instancia
echo "Obteniendo la IP pública de la instancia..."
PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text \
  --region $REGION)

if [ "$PUBLIC_IP" == "None" ]; then
  echo "Error: No se encontró una IP pública para la instancia."
  exit 1
fi

echo "Instancia lista y accesible en: $PUBLIC_IP"

# 6. Mostrar la IP pública
echo "=========================================="
echo "Accede al servicio de Nginx en la IP: $PUBLIC_IP"
echo "=========================================="

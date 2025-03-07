#!/bin/bash

# Nombre de la imagen y contenedor
IMAGE_NAME="node-app"
CONTAINER_NAME="node-app-container"
PORT=8080

# Verificar si Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "Docker no está instalado, por favor, instalar y volver a intentar"
    exit 1
fi

echo "Docker está instalado"

# Construir la imagen de Docker
echo "Construyendo la imagen de Docker..."
docker build -t $IMAGE_NAME .

if [ $? -ne 0 ]; then
    echo "Error al construir la imagen de Docker"
    exit 1
fi

echo "Imagen de Docker construida exitosamente"

# Detener y eliminar contenedor previo si existe
if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    echo "Eliminando contenedor previo..."
    docker stop $CONTAINER_NAME &> /dev/null
    docker rm $CONTAINER_NAME &> /dev/null
fi

# Ejecutar el contenedor
echo "Iniciando el contenedor..."
docker run -d --name $CONTAINER_NAME -p $PORT:8080 -e PORT=$PORT -e NODE_ENV=production $IMAGE_NAME

if [ $? -ne 0 ]; then
    echo "Error al iniciar el contenedor"
    exit 1
fi

TIMEOUT=30
INTERVAL=2
ELAPSED=0

echo "Contenedor iniciado en el puerto $PORT"

echo "Esperando a que la aplicación responda..."

while [ $ELAPSED -lt $TIMEOUT ]; do
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$PORT/health)
    if [ "$RESPONSE" = "200" ]; then
        echo "La aplicación está funcionando correctamente"
        echo "Accede en: http://localhost:$PORT"
        exit 0
    fi
    
    sleep $INTERVAL
    ELAPSED=$((ELAPSED + INTERVAL))
done

echo "Error: La aplicación no respondió correctamente en el tiempo esperado ($TIMEOUT segundos)"
exit 1
#!/bin/bash
# Script para construir y subir la imagen podman con la extensión MTA pre-instalada

set -e

IMAGE_NAME="quay.io/maximilianopizarro/lightspeed-demo"
VERSION="${1:-latest}"

echo "🔨 Construyendo imagen Docker..."
echo "   Imagen: ${IMAGE_NAME}:${VERSION}"
echo ""

# Construir la imagen
podman build -t ${IMAGE_NAME}:${VERSION} .

echo ""
echo "✅ Imagen construida exitosamente"
echo ""

# Preguntar si quiere hacer push
read -p "¿Deseas subir la imagen a quay.io? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "📤 Subiendo imagen a quay.io..."
    
    # Login a quay.io si es necesario
    if ! podman login quay.io; then
        echo "❌ Error: No se pudo hacer login a quay.io"
        echo "   Asegúrate de tener las credenciales configuradas"
        exit 1
    fi
    
    # Push de la imagen
    podman push ${IMAGE_NAME}:${VERSION}
    
    # Si es latest, también hacer push como latest
    if [ "${VERSION}" != "latest" ]; then
        podman tag ${IMAGE_NAME}:${VERSION} ${IMAGE_NAME}:latest
        podman push ${IMAGE_NAME}:latest
        echo "✅ También se subió como 'latest'"
    fi
    
    echo ""
    echo "✅ Imagen subida exitosamente a ${IMAGE_NAME}:${VERSION}"
else
    echo "⏭️  Push cancelado. La imagen está disponible localmente como ${IMAGE_NAME}:${VERSION}"
fi

echo ""
echo "Para usar esta imagen, actualiza tu devfile.yaml:"
echo "  image: ${IMAGE_NAME}:${VERSION}"


#!/bin/bash
# Script para descargar e instalar la extensión MTA desde migtools/editor-extensions
# Uso: ./install-mta-extension.sh

echo "Descargando extensión MTA desde migtools/editor-extensions..."

# URL del release más reciente (v8.0.2)
RELEASE_URL="https://github.com/migtools/editor-extensions/releases/download/v8.0.2/mta-vscode-extension-8.0.2.vsix"
VSIX_PATH="./mta-vscode-extension.vsix"

# Descargar el archivo VSIX
echo "Descargando desde: $RELEASE_URL"
if command -v curl &> /dev/null; then
    curl -L -o "$VSIX_PATH" "$RELEASE_URL"
elif command -v wget &> /dev/null; then
    wget -O "$VSIX_PATH" "$RELEASE_URL"
else
    echo "Error: Se requiere curl o wget para descargar el archivo"
    exit 1
fi

if [ -f "$VSIX_PATH" ]; then
    echo "Archivo descargado exitosamente: $VSIX_PATH"
    
    # Instalar la extensión usando VS Code CLI
    if command -v code &> /dev/null; then
        echo "Instalando extensión con VS Code..."
        code --install-extension "$VSIX_PATH" --force
        echo "Extensión instalada exitosamente!"
    else
        echo "VS Code CLI no encontrado. Por favor instala la extensión manualmente:"
        echo "1. Abre VS Code"
        echo "2. Ve a Extensiones (Ctrl+Shift+X)"
        echo "3. Haz clic en '...' (tres puntos) > 'Instalar desde VSIX...'"
        echo "4. Selecciona: $VSIX_PATH"
    fi
else
    echo "Error: No se pudo descargar el archivo"
    
    # Intentar obtener la última versión desde la API de GitHub
    echo "Intentando descargar la versión más reciente desde la API de GitHub..."
    
    if command -v curl &> /dev/null; then
        API_URL="https://api.github.com/repos/migtools/editor-extensions/releases/latest"
        DOWNLOAD_URL=$(curl -s "$API_URL" | grep -o '"browser_download_url": "[^"]*\.vsix"' | head -1 | cut -d'"' -f4)
        
        if [ ! -z "$DOWNLOAD_URL" ]; then
            echo "Descargando desde: $DOWNLOAD_URL"
            curl -L -o "$VSIX_PATH" "$DOWNLOAD_URL"
            echo "Archivo descargado: $VSIX_PATH"
            echo "Por favor instala manualmente desde VS Code usando este archivo."
        fi
    fi
    
    exit 1
fi


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
    
    # Intentar diferentes métodos de instalación según el entorno
    INSTALLED=false
    
    # Método 1: VS Code CLI (para entornos locales)
    if command -v code &> /dev/null; then
        echo "Instalando extensión con VS Code CLI..."
        if code --install-extension "$VSIX_PATH" --force 2>/dev/null; then
            echo "Extensión instalada exitosamente con VS Code CLI!"
            INSTALLED=true
        fi
    fi
    
    # Método 2: Instalación directa en VS Code Server (para workspaces remotos)
    if [ "$INSTALLED" = false ]; then
        # Buscar directorios de extensiones de VS Code Server
        VSCODE_EXT_DIRS=(
            "$HOME/.vscode-server/extensions"
            "$HOME/.vscode-server-insiders/extensions"
            "$HOME/.che/extensions"
            "/home/user/.vscode-server/extensions"
            "/home/user/.vscode-server-insiders/extensions"
            "/home/user/.che/extensions"
        )
        
        # Verificar si tenemos herramientas para extraer el VSIX
        HAS_UNZIP=false
        if command -v unzip &> /dev/null; then
            HAS_UNZIP=true
        elif command -v python3 &> /dev/null; then
            python3 -c "import zipfile" 2>/dev/null && HAS_UNZIP=true
        fi
        
        if [ "$HAS_UNZIP" = true ]; then
            for EXT_DIR in "${VSCODE_EXT_DIRS[@]}"; do
                EXT_BASE_DIR=$(dirname "$EXT_DIR" 2>/dev/null || echo "$HOME")
                if [ -d "$EXT_BASE_DIR" ] || [ -d "$HOME" ]; then
                    echo "Intentando instalar en: $EXT_DIR"
                    mkdir -p "$EXT_DIR"
                    
                    # Extraer el VSIX a un directorio temporal
                    TEMP_DIR=$(mktemp -d 2>/dev/null || echo "/tmp/mta-ext-$$")
                    mkdir -p "$TEMP_DIR"
                    
                    # Intentar extraer con unzip o python
                    EXTRACTED=false
                    if command -v unzip &> /dev/null; then
                        if unzip -q "$VSIX_PATH" -d "$TEMP_DIR" 2>/dev/null; then
                            EXTRACTED=true
                        fi
                    elif command -v python3 &> /dev/null; then
                        if python3 -m zipfile -e "$VSIX_PATH" "$TEMP_DIR" 2>/dev/null; then
                            EXTRACTED=true
                        fi
                    fi
                    
                    if [ "$EXTRACTED" = true ] && [ -f "$TEMP_DIR/package.json" ]; then
                        # Obtener el ID de la extensión desde package.json
                        EXT_ID=$(grep -o '"name": "[^"]*"' "$TEMP_DIR/package.json" 2>/dev/null | head -1 | cut -d'"' -f4)
                        EXT_VERSION=$(grep -o '"version": "[^"]*"' "$TEMP_DIR/package.json" 2>/dev/null | head -1 | cut -d'"' -f4)
                        
                        if [ -n "$EXT_ID" ] && [ -n "$EXT_VERSION" ]; then
                            TARGET_DIR="$EXT_DIR/${EXT_ID}-${EXT_VERSION}"
                            if [ -d "$TARGET_DIR" ]; then
                                rm -rf "$TARGET_DIR"
                            fi
                            if mv "$TEMP_DIR" "$TARGET_DIR" 2>/dev/null && [ -d "$TARGET_DIR" ]; then
                                echo "✅ Extensión instalada exitosamente en: $TARGET_DIR"
                                INSTALLED=true
                                break
                            fi
                        fi
                    fi
                    rm -rf "$TEMP_DIR" 2>/dev/null
                fi
            done
        fi
    fi
    
    # Método 3: Instrucciones manuales si todo falla
    if [ "$INSTALLED" = false ]; then
        ABSOLUTE_PATH=$(cd "$(dirname "$VSIX_PATH")" && pwd)/$(basename "$VSIX_PATH")
        echo ""
        echo "⚠️  No se pudo instalar automáticamente. El archivo VSIX está disponible en:"
        echo "   $ABSOLUTE_PATH"
        echo ""
        echo "Para instalar manualmente:"
        echo "1. Abre VS Code en el workspace"
        echo "2. Ve a Extensiones (Ctrl+Shift+X o Cmd+Shift+X)"
        echo "3. Haz clic en '...' (tres puntos) en la esquina superior derecha"
        echo "4. Selecciona 'Instalar desde VSIX...'"
        echo "5. Navega a: $ABSOLUTE_PATH"
        echo ""
        echo "O usa el comando en la terminal de VS Code:"
        echo "   code --install-extension \"$ABSOLUTE_PATH\""
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


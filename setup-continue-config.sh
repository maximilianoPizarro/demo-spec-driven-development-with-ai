#!/bin/bash
# Script para configurar continue-config.json con variables de entorno

CONTINUE_DIR="/home/user/.continue"
SOURCE_CONFIG="${PROJECT_SOURCE}/continue-config.json"
TARGET_CONFIG="${CONTINUE_DIR}/config.json"

mkdir -p "${CONTINUE_DIR}"

# Leer el archivo de configuración y reemplazar variables de entorno
if [ -f "${SOURCE_CONFIG}" ]; then
    # Usar sed para reemplazar variables de entorno
    # Reemplazar ${LLM_SERVER_URL} con el valor de la variable de entorno
    # Reemplazar ${LLM_SERVER_TOKEN} con el valor de la variable de entorno
    
    # Usar LLM_SERVER_TOKEN o OPENAI_API_KEY como fallback
    API_TOKEN="${LLM_SERVER_TOKEN:-${OPENAI_API_KEY}}"
    API_BASE="${LLM_SERVER_URL:-https://llama-3-2-3b-maas-apicast-production.apps.prod.rhoai.rh-aiservices-bu.com:443/v1}"
    
    sed "s|\${LLM_SERVER_URL}|${API_BASE}|g" \
        "${SOURCE_CONFIG}" | \
    sed "s|\${LLM_SERVER_TOKEN}|${API_TOKEN}|g" > "${TARGET_CONFIG}"
    
    echo "Continue config creado en: ${TARGET_CONFIG}"
    echo "API Base: ${API_BASE}"
    
    if [ -z "${API_TOKEN}" ]; then
        echo "ADVERTENCIA: LLM_SERVER_TOKEN y OPENAI_API_KEY no están configurados. La autenticación fallará."
        echo "Por favor, configura el secret 'openapi-api-key' con LLM_SERVER_TOKEN o OPENAI_API_KEY"
    else
        echo "Token configurado (longitud: ${#API_TOKEN} caracteres)"
    fi
else
    echo "Error: No se encontró ${SOURCE_CONFIG}"
    exit 1
fi


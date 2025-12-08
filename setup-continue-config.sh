#!/bin/bash
# Script to configure continue-config.json with environment variables

CONTINUE_DIR="/home/user/.continue"
SOURCE_CONFIG="${PROJECT_SOURCE}/continue-config.json"
TARGET_CONFIG="${CONTINUE_DIR}/config.json"

mkdir -p "${CONTINUE_DIR}"

# Read configuration file and replace environment variables
if [ -f "${SOURCE_CONFIG}" ]; then
    # Use sed to replace environment variables
    # Replace ${LLM_SERVER_URL} with the environment variable value
    # Replace ${LLM_SERVER_TOKEN} with the environment variable value
    
    # Use LLM_SERVER_TOKEN or OPENAI_API_KEY as fallback
    API_TOKEN="${LLM_SERVER_TOKEN:-${OPENAI_API_KEY}}"
    API_BASE="${LLM_SERVER_URL:-https://llama-3-2-3b-maas-apicast-production.apps.prod.rhoai.rh-aiservices-bu.com:443/v1}"
    
    sed "s|\${LLM_SERVER_URL}|${API_BASE}|g" \
        "${SOURCE_CONFIG}" | \
    sed "s|\${LLM_SERVER_TOKEN}|${API_TOKEN}|g" > "${TARGET_CONFIG}"
    
    echo "Continue config created at: ${TARGET_CONFIG}"
    echo "API Base: ${API_BASE}"
    
    if [ -z "${API_TOKEN}" ]; then
        echo "WARNING: LLM_SERVER_TOKEN and OPENAI_API_KEY are not configured. Authentication will fail."
        echo "Please configure the 'openapi-api-key' secret with LLM_SERVER_TOKEN or OPENAI_API_KEY"
    else
        echo "Token configured (length: ${#API_TOKEN} characters)"
    fi
else
    echo "Error: File not found: ${SOURCE_CONFIG}"
    exit 1
fi


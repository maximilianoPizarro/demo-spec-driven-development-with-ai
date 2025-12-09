#!/bin/bash
# Ultra-fast configuration script - Continue only, no waits, no timeouts
# Runs in background to avoid blocking workspace startup

CONTINUE_DIR="/home/user/.continue"
SOURCE_CONFIG="${PROJECT_SOURCE}/continue-config.json"
TARGET_CONFIG="${CONTINUE_DIR}/config.json"

# Continue config - instant, no waiting, no timeouts
if [ -f "${SOURCE_CONFIG}" ]; then
    mkdir -p "${CONTINUE_DIR}" 2>/dev/null || true
    
    # Use environment variables if available, otherwise use defaults
    API_TOKEN="${LLM_SERVER_TOKEN:-${OPENAI_API_KEY}}"
    API_BASE="${LLM_SERVER_URL:-https://llama-3-2-3b-maas-apicast-production.apps.prod.rhoai.rh-aiservices-bu.com:443/v1}"
    
    # Quick replace - instant operation
    sed "s|\${LLM_SERVER_URL}|${API_BASE}|g" "${SOURCE_CONFIG}" 2>/dev/null | \
    sed "s|\${LLM_SERVER_TOKEN}|${API_TOKEN}|g" 2>/dev/null > "${TARGET_CONFIG}" 2>/dev/null || true
fi

# Exit immediately - Konveyor will be configured manually if needed
exit 0


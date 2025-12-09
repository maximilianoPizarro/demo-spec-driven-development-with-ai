#!/bin/bash
# Script to configure provider-settings.yaml with environment variables for Konveyor

SOURCE_CONFIG="${PROJECT_SOURCE}/provider-settings.yaml"

# VS Code Server (checode) global storage location
# This is where Konveyor extension actually reads the config from
# Use absolute path from root, not relative to home
VSCODE_GLOBAL_STORAGE="/checode/remote/data/User/globalStorage/konveyor.konveyor/settings"
VSCODE_CONFIG_DIR="${VSCODE_GLOBAL_STORAGE}"
VSCODE_TARGET_CONFIG="${VSCODE_CONFIG_DIR}/provider-settings.yaml"

# Fallback location (for compatibility)
KONVEYOR_CONFIG_DIR="${HOME}/.konveyor"
KONVEYOR_TARGET_CONFIG="${KONVEYOR_CONFIG_DIR}/provider-settings.yaml"

# Create both directories
mkdir -p "${VSCODE_CONFIG_DIR}"
mkdir -p "${KONVEYOR_CONFIG_DIR}"

# Wait for environment variables to be available (up to 30 seconds)
echo "Waiting for environment variables to be available..."
MAX_WAIT=30
WAIT_COUNT=0
while [ $WAIT_COUNT -lt $MAX_WAIT ]; do
    if [ -n "${LLM_SERVER_TOKEN}" ] || [ -n "${OPENAI_API_KEY}" ]; then
        echo "Environment variables detected after ${WAIT_COUNT} seconds"
        break
    fi
    sleep 1
    WAIT_COUNT=$((WAIT_COUNT + 1))
done

# Read configuration file and replace environment variables
if [ -f "${SOURCE_CONFIG}" ]; then
    # Use LLM_SERVER_TOKEN or OPENAI_API_KEY as fallback
    API_TOKEN="${LLM_SERVER_TOKEN:-${OPENAI_API_KEY}}"
    API_BASE="${LLM_SERVER_URL:-${OPENAI_API_BASE:-https://llama-3-2-3b-maas-apicast-production.apps.prod.rhoai.rh-aiservices-bu.com:443/v1}}"
    MODEL_ID="${LLM_SERVER_ID:-llama-3-2-3b}"
    RA_PROVIDER="${RA_AID_PROVIDER:-openai}"
    RA_MODEL="${RA_AID_MODEL:-llama-3-2-3b}"
    RA_BACKEND="${RA_AID_BACKEND:-openai}"
    
    # Debug: Show what we're working with
    echo "Debug: API_TOKEN length: ${#API_TOKEN}"
    echo "Debug: API_BASE: ${API_BASE}"
    
    if [ -z "${API_TOKEN}" ]; then
        echo "ERROR: LLM_SERVER_TOKEN and OPENAI_API_KEY are not set in environment"
        echo "Please ensure the 'openapi-api-key' secret is applied and contains LLM_SERVER_TOKEN"
        exit 1
    fi
    
    # Escape special characters for sed (both URL and token)
    ESCAPED_API_BASE=$(echo "${API_BASE}" | sed 's/[[\.*^$()+?{|]/\\&/g' | sed 's|/|\\/|g')
    ESCAPED_API_TOKEN=$(echo "${API_TOKEN}" | sed 's/[[\.*^$()+?{|]/\\&/g' | sed 's|/|\\/|g' | sed 's|&|\\&|g')
    ESCAPED_MODEL_ID=$(echo "${MODEL_ID}" | sed 's/[[\.*^$()+?{|]/\\&/g')
    ESCAPED_RA_PROVIDER=$(echo "${RA_PROVIDER}" | sed 's/[[\.*^$()+?{|]/\\&/g')
    ESCAPED_RA_MODEL=$(echo "${RA_MODEL}" | sed 's/[[\.*^$()+?{|]/\\&/g')
    ESCAPED_RA_BACKEND=$(echo "${RA_BACKEND}" | sed 's/[[\.*^$()+?{|]/\\&/g')
    
    # Replace environment variable placeholders with actual values
    # Use a temporary file to avoid issues with sed and special characters
    TEMP_FILE=$(mktemp)
    
    # Replace all variables in order (URL first, then token, then others)
    sed "s|\${LLM_SERVER_URL}|${ESCAPED_API_BASE}|g" \
        "${SOURCE_CONFIG}" | \
    sed "s|\${OPENAI_API_BASE}|${ESCAPED_API_BASE}|g" | \
    sed "s|\${LLM_SERVER_TOKEN}|${ESCAPED_API_TOKEN}|g" | \
    sed "s|\${LLM_SERVER_ID}|${ESCAPED_MODEL_ID}|g" | \
    sed "s|\${RA_AID_PROVIDER}|${ESCAPED_RA_PROVIDER}|g" | \
    sed "s|\${RA_AID_MODEL}|${ESCAPED_RA_MODEL}|g" | \
    sed "s|\${RA_AID_BACKEND}|${ESCAPED_RA_BACKEND}|g" > "${TEMP_FILE}"
    
    # Verify replacements were made
    if grep -q '\${LLM_SERVER_TOKEN}' "${TEMP_FILE}"; then
        echo "WARNING: Some \${LLM_SERVER_TOKEN} placeholders were not replaced"
        echo "This may indicate the token contains special characters that need escaping"
    fi
    
    if grep -q '\${LLM_SERVER_URL}' "${TEMP_FILE}"; then
        echo "WARNING: Some \${LLM_SERVER_URL} placeholders were not replaced"
    fi
    
    if grep -q '\${LLM_SERVER_ID}' "${TEMP_FILE}"; then
        echo "WARNING: Some \${LLM_SERVER_ID} placeholders were not replaced"
    fi
    
    if grep -q '\${OPENAI_API_BASE}' "${TEMP_FILE}"; then
        echo "WARNING: Some \${OPENAI_API_BASE} placeholders were not replaced"
    fi
    
    # Validate YAML syntax before copying
    if command -v python3 &> /dev/null; then
        python3 -c "import yaml; yaml.safe_load(open('${TEMP_FILE}'))" 2>/dev/null
        if [ $? -ne 0 ]; then
            echo "WARNING: Generated YAML may have syntax issues, but copying anyway"
        fi
    fi
    
    # Copy to VS Code Server global storage (primary location)
    cp "${TEMP_FILE}" "${VSCODE_TARGET_CONFIG}"
    
    # Also copy to fallback location for compatibility
    cp "${TEMP_FILE}" "${KONVEYOR_TARGET_CONFIG}"
    
    # Clean up temp file
    rm "${TEMP_FILE}"
    
    # Verify the file was created and has content
    if [ ! -f "${VSCODE_TARGET_CONFIG}" ] || [ ! -s "${VSCODE_TARGET_CONFIG}" ]; then
        echo "ERROR: Failed to create Konveyor config file at VS Code location"
        exit 1
    fi
    
    echo "Konveyor config created at:"
    echo "  Primary: ${VSCODE_TARGET_CONFIG}"
    echo "  Fallback: ${KONVEYOR_TARGET_CONFIG}"
    echo "API Base: ${API_BASE}"
    echo "Token configured (length: ${#API_TOKEN} characters)"
    
    # Final verification: check that values were actually replaced
    echo ""
    echo "Verifying replacements in config file:"
    if grep -q "${API_BASE}" "${VSCODE_TARGET_CONFIG}" 2>/dev/null; then
        echo "  ✓ API Base URL replaced successfully"
    else
        echo "  ✗ WARNING: API Base URL may not have been replaced correctly"
    fi
    
    # Check token (first 10 chars only for security)
    TOKEN_PREFIX=$(echo "${API_TOKEN}" | cut -c1-10)
    if grep -q "${TOKEN_PREFIX}" "${VSCODE_TARGET_CONFIG}" 2>/dev/null || ! grep -q '\${LLM_SERVER_TOKEN}' "${VSCODE_TARGET_CONFIG}"; then
        echo "  ✓ API Token replaced successfully"
    else
        echo "  ✗ WARNING: API Token may not have been replaced correctly"
        echo "  Check that LLM_SERVER_TOKEN is set in your environment"
    fi
    
    echo ""
    echo "Konveyor configuration file created successfully."
    
    # Also ensure environment variables are available for external providers
    # Create a shell profile snippet to export variables if they don't exist
    SHELL_PROFILE="${HOME}/.bashrc"
    if [ -f "${SHELL_PROFILE}" ]; then
        if ! grep -q "LLM_SERVER_TOKEN" "${SHELL_PROFILE}"; then
            echo "" >> "${SHELL_PROFILE}"
            echo "# Konveyor external providers environment variables" >> "${SHELL_PROFILE}"
            echo "export LLM_SERVER_TOKEN=\"${API_TOKEN}\"" >> "${SHELL_PROFILE}"
            echo "export LLM_SERVER_URL=\"${API_BASE}\"" >> "${SHELL_PROFILE}"
            echo "export OPENAI_API_KEY=\"${API_TOKEN}\"" >> "${SHELL_PROFILE}"
        fi
    fi
    
    # Export variables for current session
    export LLM_SERVER_TOKEN="${API_TOKEN}"
    export LLM_SERVER_URL="${API_BASE}"
    export OPENAI_API_KEY="${API_TOKEN}"
    
    echo "Environment variables exported for external providers."
    echo "Please restart the Konveyor Analyzer RPC server if it's already running."
    echo "You may need to restart VS Code or reload the window for external providers to pick up the changes."
else
    echo "Error: File not found: ${SOURCE_CONFIG}"
    exit 1
fi


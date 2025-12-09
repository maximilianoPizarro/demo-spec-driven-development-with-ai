#!/bin/bash
# Script to test Konveyor configuration and API key

echo "=========================================="
echo "Testing Konveyor Configuration"
echo "=========================================="

# VS Code Server (checode) global storage location (primary)
VSCODE_CONFIG="${HOME}/checode/remote/data/User/globalStorage/konveyor.konveyor/provider-settings.yaml"
# Fallback location
KONVEYOR_CONFIG="${HOME}/.konveyor/provider-settings.yaml"

# Use VS Code location if it exists, otherwise fallback
if [ -f "${VSCODE_CONFIG}" ]; then
    KONVEYOR_CONFIG="${VSCODE_CONFIG}"
    echo "Using VS Code Server location: ${VSCODE_CONFIG}"
else
    echo "Using fallback location: ${KONVEYOR_CONFIG}"
fi

echo ""
echo "1. Environment Variables:"
echo "   LLM_SERVER_TOKEN: ${LLM_SERVER_TOKEN:+SET (length: ${#LLM_SERVER_TOKEN})}"
echo "   LLM_SERVER_URL: ${LLM_SERVER_URL:+SET}"
echo "   OPENAI_API_KEY: ${OPENAI_API_KEY:+SET (length: ${#OPENAI_API_KEY})}"

echo ""
echo "2. Processed Configuration File:"
if [ -f "${KONVEYOR_CONFIG}" ]; then
    echo "   ✓ File exists: ${KONVEYOR_CONFIG}"
    echo ""
    echo "   Active model configuration:"
    echo "   -------------------------"
    grep -A 10 "&active" "${KONVEYOR_CONFIG}" | head -15
    
    echo ""
    echo "   Checking for apiKey:"
    API_KEY_LINE=$(grep -A 10 "&active" "${KONVEYOR_CONFIG}" | grep "apiKey:")
    if [ -n "${API_KEY_LINE}" ]; then
        echo "   ✓ Found: ${API_KEY_LINE}"
        API_KEY_VALUE=$(echo "${API_KEY_LINE}" | sed 's/.*apiKey: *"\(.*\)".*/\1/')
        if [ -z "${API_KEY_VALUE}" ] || [ "${API_KEY_VALUE}" = "\${LLM_SERVER_TOKEN}" ]; then
            echo "   ✗ apiKey value is empty or not expanded!"
            echo "   Run: cd ${PROJECT_SOURCE} && ./setup-konveyor-config.sh"
        else
            echo "   ✓ apiKey has value (length: ${#API_KEY_VALUE})"
        fi
    else
        echo "   ✗ apiKey NOT found in args"
    fi
    
    echo ""
    echo "   Checking for baseURL:"
    BASE_URL_LINE=$(grep -A 10 "&active" "${KONVEYOR_CONFIG}" | grep "baseURL:")
    if [ -n "${BASE_URL_LINE}" ]; then
        echo "   ✓ Found: ${BASE_URL_LINE}"
    else
        echo "   ✗ baseURL NOT found in args"
    fi
    
    echo ""
    echo "   Full active model block:"
    sed -n '/&active/,/^  [A-Z]/p' "${KONVEYOR_CONFIG}" | head -20
    
else
    echo "   ✗ File NOT found: ${KONVEYOR_CONFIG}"
    echo "   Run: cd ${PROJECT_SOURCE} && ./setup-konveyor-config.sh"
fi

echo ""
echo "3. Testing API connection (if curl is available):"
if command -v curl &> /dev/null && [ -n "${LLM_SERVER_URL}" ] && [ -n "${LLM_SERVER_TOKEN}" ]; then
    echo "   Testing connection to: ${LLM_SERVER_URL}"
    RESPONSE=$(curl -s -w "\n%{http_code}" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${LLM_SERVER_TOKEN}" \
        "${LLM_SERVER_URL}/models" 2>&1)
    
    HTTP_CODE=$(echo "${RESPONSE}" | tail -1)
    BODY=$(echo "${RESPONSE}" | head -n -1)
    
    echo "   HTTP Status: ${HTTP_CODE}"
    if [ "${HTTP_CODE}" = "200" ]; then
        echo "   ✓ API connection successful"
    elif [ "${HTTP_CODE}" = "401" ]; then
        echo "   ✗ Authentication failed - API key may be incorrect"
    else
        echo "   Response: ${BODY}"
    fi
else
    echo "   Skipping (curl not available or credentials not set)"
fi

echo ""
echo "=========================================="
echo "Test complete"
echo "=========================================="


#!/bin/bash
# Script to diagnose Konveyor configuration issues

echo "=========================================="
echo "Konveyor Configuration Diagnostics"
echo "=========================================="

# VS Code Server (checode) global storage location (primary)
# Use absolute path from root
VSCODE_CONFIG="/checode/remote/data/User/globalStorage/konveyor.konveyor/settings/provider-settings.yaml"
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
if [ -z "${LLM_SERVER_TOKEN}" ]; then
    echo "   ⚠️  NOT SET - This is the problem!"
fi

echo "   LLM_SERVER_URL: ${LLM_SERVER_URL:+SET}"
if [ -z "${LLM_SERVER_URL}" ]; then
    echo "   ⚠️  NOT SET"
fi

echo "   OPENAI_API_KEY: ${OPENAI_API_KEY:+SET (length: ${#OPENAI_API_KEY})}"
if [ -z "${OPENAI_API_KEY}" ]; then
    echo "   ⚠️  NOT SET"
fi

echo ""
echo "2. Konveyor Config File:"
if [ -f "${KONVEYOR_CONFIG}" ]; then
    echo "   ✓ File exists: ${KONVEYOR_CONFIG}"
    echo ""
    echo "   Checking for unexpanded variables:"
    
    if grep -q '\${LLM_SERVER_TOKEN}' "${KONVEYOR_CONFIG}"; then
        echo "   ✗ FOUND unexpanded \${LLM_SERVER_TOKEN} - Variables were not replaced!"
        echo ""
        echo "   Sample of problematic lines:"
        grep '\${LLM_SERVER_TOKEN}' "${KONVEYOR_CONFIG}" | head -3
    else
        echo "   ✓ No unexpanded LLM_SERVER_TOKEN found"
    fi
    
    if grep -q '\${LLM_SERVER_URL}' "${KONVEYOR_CONFIG}"; then
        echo "   ✗ FOUND unexpanded \${LLM_SERVER_URL} - Variables were not replaced!"
        echo ""
        echo "   Sample of problematic lines:"
        grep '\${LLM_SERVER_URL}' "${KONVEYOR_CONFIG}" | head -3
    else
        echo "   ✓ No unexpanded LLM_SERVER_URL found"
    fi
    
    echo ""
    echo "   Active model configuration (first 15 lines):"
    grep -A 15 "&active" "${KONVEYOR_CONFIG}" | head -15
    
else
    echo "   ✗ File NOT found: ${KONVEYOR_CONFIG}"
    echo "   Run: cd ${PROJECT_SOURCE} && ./setup-konveyor-config.sh"
fi

echo ""
echo "3. Recommendations:"
if [ -z "${LLM_SERVER_TOKEN}" ] && [ -z "${OPENAI_API_KEY}" ]; then
    echo "   ⚠️  CRITICAL: Environment variables are not set"
    echo "   → Ensure the Kubernetes secret 'openapi-api-key' is applied"
    echo "   → Verify the secret contains LLM_SERVER_TOKEN and LLM_SERVER_URL"
    echo "   → Restart the workspace after applying the secret"
fi

if [ -f "${KONVEYOR_CONFIG}" ] && grep -q '\${LLM_SERVER_TOKEN}' "${KONVEYOR_CONFIG}"; then
    echo "   ⚠️  Config file has unexpanded variables"
    echo "   → Run: cd ${PROJECT_SOURCE} && ./setup-konveyor-config.sh"
    echo "   → Make sure LLM_SERVER_TOKEN is set before running the script"
fi

echo ""
echo "=========================================="
echo "Diagnostics complete"
echo "=========================================="


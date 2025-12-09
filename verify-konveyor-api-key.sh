#!/bin/bash
# Script to verify Konveyor API key configuration

echo "=========================================="
echo "Konveyor API Key Verification"
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
if [ -z "${LLM_SERVER_TOKEN}" ]; then
    echo "   ✗ NOT SET - This is likely the problem!"
    echo "   Please ensure the 'openapi-api-key' secret is applied"
else
    echo "   ✓ SET"
fi

echo "   LLM_SERVER_URL: ${LLM_SERVER_URL:+SET}"
if [ -z "${LLM_SERVER_URL}" ]; then
    echo "   ✗ NOT SET"
else
    echo "   ✓ SET: ${LLM_SERVER_URL}"
fi

echo "   OPENAI_API_KEY: ${OPENAI_API_KEY:+SET (length: ${#OPENAI_API_KEY})}"
if [ -z "${OPENAI_API_KEY}" ]; then
    echo "   ✗ NOT SET"
else
    echo "   ✓ SET"
fi

echo ""
echo "2. Processed Configuration File:"
if [ -f "${KONVEYOR_CONFIG}" ]; then
    echo "   ✓ File exists: ${KONVEYOR_CONFIG}"
    echo ""
    
    echo "   Checking for unexpanded variables:"
    if grep -q '\${' "${KONVEYOR_CONFIG}"; then
        echo "   ✗ FOUND unexpanded variables!"
        echo ""
        echo "   Problematic lines:"
        grep -n '\${' "${KONVEYOR_CONFIG}" | head -5
        echo ""
        echo "   Run: cd ${PROJECT_SOURCE} && ./setup-konveyor-config.sh"
    else
        echo "   ✓ No unexpanded variables found"
    fi
    
    echo ""
    echo "   Active model configuration:"
    echo "   -------------------------"
    grep -A 10 "&active" "${KONVEYOR_CONFIG}" | head -10
    
    echo ""
    echo "   Checking for apiKey in args:"
    if grep -A 5 "&active" "${KONVEYOR_CONFIG}" | grep -q "apiKey:"; then
        echo "   ✓ apiKey found in args"
        API_KEY_VALUE=$(grep -A 5 "&active" "${KONVEYOR_CONFIG}" | grep "apiKey:" | sed 's/.*apiKey: *"\(.*\)".*/\1/')
        if [ -z "${API_KEY_VALUE}" ] || [ "${API_KEY_VALUE}" = "\${LLM_SERVER_TOKEN}" ]; then
            echo "   ✗ apiKey value is empty or not expanded!"
        else
            echo "   ✓ apiKey has value (length: ${#API_KEY_VALUE})"
        fi
    else
        echo "   ✗ apiKey NOT found in args"
        echo "   This may be the problem - apiKey should be in args for ChatOpenAI"
    fi
    
    echo ""
    echo "   Checking for baseURL in args:"
    if grep -A 5 "&active" "${KONVEYOR_CONFIG}" | grep -q "baseURL:"; then
        echo "   ✓ baseURL found in args"
        BASE_URL_VALUE=$(grep -A 5 "&active" "${KONVEYOR_CONFIG}" | grep "baseURL:" | sed 's/.*baseURL: *"\(.*\)".*/\1/')
        echo "   Value: ${BASE_URL_VALUE}"
    else
        echo "   ✗ baseURL NOT found in args"
    fi
    
else
    echo "   ✗ File NOT found: ${KONVEYOR_CONFIG}"
    echo "   Run: cd ${PROJECT_SOURCE} && ./setup-konveyor-config.sh"
fi

echo ""
echo "3. Recommendations:"
if [ -z "${LLM_SERVER_TOKEN}" ]; then
    echo "   → Apply the Kubernetes secret:"
    echo "     kubectl apply -f ${PROJECT_SOURCE}/secret.yaml"
    echo "     (or oc apply -f ${PROJECT_SOURCE}/secret.yaml for OpenShift)"
fi

if [ -f "${KONVEYOR_CONFIG}" ] && grep -q '\${' "${KONVEYOR_CONFIG}"; then
    echo "   → Run the setup script to expand variables:"
    echo "     cd ${PROJECT_SOURCE} && ./setup-konveyor-config.sh"
fi

if [ -f "${KONVEYOR_CONFIG}" ] && ! grep -A 5 "&active" "${KONVEYOR_CONFIG}" | grep -q "apiKey:"; then
    echo "   → Update provider-settings.yaml to include apiKey in args"
fi

echo ""
echo "4. Next Steps:"
echo "   1. Ensure environment variables are set (check secret is applied)"
echo "   2. Run: cd ${PROJECT_SOURCE} && ./setup-konveyor-config.sh"
echo "   3. Restart Konveyor Analyzer RPC Server (Command Palette → 'Konveyor: Restart Analyzer RPC Server')"
echo "   4. Check Konveyor logs in VS Code Output panel"

echo ""
echo "=========================================="
echo "Verification complete"
echo "=========================================="


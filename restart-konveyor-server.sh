#!/bin/bash
# Script to restart Konveyor Analyzer RPC Server
# This helps resolve RPC connection errors

echo "=========================================="
echo "Restarting Konveyor Analyzer RPC Server"
echo "=========================================="

# Check if VS Code is running
if [ -z "${VSCODE_PID}" ]; then
    echo "VS Code process not detected in environment"
fi

echo ""
echo "To restart the Konveyor Analyzer RPC Server:"
echo ""
echo "1. Open VS Code Command Palette (Ctrl+Shift+P / Cmd+Shift+P)"
echo "2. Run: 'Konveyor: Restart Analyzer RPC Server'"
echo ""
echo "OR"
echo ""
echo "3. Reload VS Code Window:"
echo "   Command Palette -> 'Developer: Reload Window'"
echo ""
echo "OR"
echo ""
echo "4. Restart VS Code completely"
echo ""

# Check Konveyor config
KONVEYOR_CONFIG="${HOME}/.konveyor/provider-settings.yaml"
if [ -f "${KONVEYOR_CONFIG}" ]; then
    echo "✓ Konveyor config found: ${KONVEYOR_CONFIG}"
    
    # Validate YAML syntax
    if command -v python3 &> /dev/null; then
        echo ""
        echo "Validating YAML syntax..."
        if python3 -c "import yaml; yaml.safe_load(open('${KONVEYOR_CONFIG}'))" 2>&1; then
            echo "✓ YAML syntax is valid"
        else
            echo "✗ YAML syntax error detected!"
            echo "  Please check the configuration file"
        fi
    fi
    
    # Check for unexpanded variables
    echo ""
    echo "Checking for unexpanded environment variables..."
    if grep -q '\${' "${KONVEYOR_CONFIG}"; then
        echo "⚠️  Found unexpanded variables in config!"
        echo "   Run: cd ${PROJECT_SOURCE} && ./setup-konveyor-config.sh"
    else
        echo "✓ No unexpanded variables found"
    fi
else
    echo "✗ Konveyor config not found: ${KONVEYOR_CONFIG}"
    echo "  Run: cd ${PROJECT_SOURCE} && ./setup-konveyor-config.sh"
fi

echo ""
echo "=========================================="
echo "Diagnostics complete"
echo "=========================================="


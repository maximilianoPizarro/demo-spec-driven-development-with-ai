#!/bin/bash
# Script to verify VS Code extensions are installed and enabled

echo "=========================================="
echo "VS Code Extensions Verification"
echo "=========================================="

# VS Code Server extensions directory
VSCODE_EXTENSIONS_DIR="${HOME}/checode/remote/extensions"
if [ ! -d "${VSCODE_EXTENSIONS_DIR}" ]; then
    VSCODE_EXTENSIONS_DIR="${HOME}/.checode/remote/extensions"
fi

if [ ! -d "${VSCODE_EXTENSIONS_DIR}" ]; then
    VSCODE_EXTENSIONS_DIR="${HOME}/.vscode-server/extensions"
fi

if [ ! -d "${VSCODE_EXTENSIONS_DIR}" ]; then
    VSCODE_EXTENSIONS_DIR="${HOME}/.che/extensions"
fi

echo ""
echo "Extensions directory: ${VSCODE_EXTENSIONS_DIR}"

if [ ! -d "${VSCODE_EXTENSIONS_DIR}" ]; then
    echo "✗ Extensions directory not found"
    echo "  Please check VS Code is running and extensions are installed"
    exit 1
fi

echo ""
echo "Checking for recommended extensions:"
echo ""

# Check Continue extension
CONTINUE_EXT=$(ls -d "${VSCODE_EXTENSIONS_DIR}"/continue.* 2>/dev/null | head -1)
if [ -n "${CONTINUE_EXT}" ]; then
    echo "✓ Continue extension found:"
    echo "  $(basename ${CONTINUE_EXT})"
else
    echo "✗ Continue extension NOT found"
fi

# Check MTA extension (Red Hat)
MTA_REDHAT_EXT=$(ls -d "${VSCODE_EXTENSIONS_DIR}"/redhat.mta-vscode-extension* 2>/dev/null | head -1)
if [ -n "${MTA_REDHAT_EXT}" ]; then
    echo "✓ MTA (Red Hat) extension found:"
    echo "  $(basename ${MTA_REDHAT_EXT})"
else
    echo "✗ MTA (Red Hat) extension NOT found"
fi

# Check MTA extension (Konveyor)
MTA_KONVEYOR_EXT=$(ls -d "${VSCODE_EXTENSIONS_DIR}"/konveyor.vscode-mta* 2>/dev/null | head -1)
if [ -n "${MTA_KONVEYOR_EXT}" ]; then
    echo "✓ MTA (Konveyor) extension found:"
    echo "  $(basename ${MTA_KONVEYOR_EXT})"
else
    echo "✗ MTA (Konveyor) extension NOT found"
fi

# Check Konveyor extensions
KONVEYOR_EXT=$(ls -d "${VSCODE_EXTENSIONS_DIR}"/konveyor.konveyor* 2>/dev/null | head -1)
if [ -n "${KONVEYOR_EXT}" ]; then
    echo "✓ Konveyor extension found:"
    echo "  $(basename ${KONVEYOR_EXT})"
else
    echo "✗ Konveyor extension NOT found"
fi

echo ""
echo "=========================================="
echo "Extension Activation Instructions"
echo "=========================================="
echo ""
echo "If extensions are installed but not visible in the Command Palette:"
echo ""
echo "1. Reload VS Code Window:"
echo "   - Press Ctrl+Shift+P (or Cmd+Shift+P on Mac)"
echo "   - Type: 'Developer: Reload Window'"
echo "   - Press Enter"
echo ""
echo "2. Check Extension Status:"
echo "   - Press Ctrl+Shift+X (or Cmd+Shift+X on Mac) to open Extensions"
echo "   - Search for 'Continue' or 'MTA'"
echo "   - Verify they show as 'Installed' and 'Enabled'"
echo ""
echo "3. Enable Extensions Manually:"
echo "   - Open Extensions panel (Ctrl+Shift+X)"
echo "   - Find the extension"
echo "   - Click 'Enable' if it shows as disabled"
echo ""
echo "4. Restart VS Code:"
echo "   - Close VS Code completely"
echo "   - Reopen the workspace"
echo ""
echo "5. Check Extension Commands:"
echo "   - Press Ctrl+Shift+P to open Command Palette"
echo "   - Type 'Continue' or 'MTA' to see available commands"
echo ""
echo "=========================================="
echo "Troubleshooting"
echo "=========================================="
echo ""
echo "If extensions still don't appear:"
echo ""
echo "1. Check VS Code Output Panel:"
echo "   - View → Output"
echo "   - Select 'Log (Extension Host)'"
echo "   - Look for errors related to Continue or MTA"
echo ""
echo "2. Check Extension Logs:"
echo "   - View → Output"
echo "   - Select 'Continue' or 'MTA' from dropdown"
echo "   - Look for error messages"
echo ""
echo "3. Verify Extension Configuration:"
echo "   - Check .vscode/extensions.json exists"
echo "   - Check .vscode/settings.json for extension settings"
echo ""
echo "4. Manual Installation:"
echo "   - Open Extensions panel"
echo "   - Search for extension ID"
echo "   - Click 'Install' if not installed"
echo ""


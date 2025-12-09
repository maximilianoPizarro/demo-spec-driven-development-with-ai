#!/bin/bash
# Script to ensure Maven is globally available for Konveyor analyzer
# Creates symlinks and ensures PATH is set correctly

echo "=========================================="
echo "Ensuring Maven is Globally Available"
echo "=========================================="

MAVEN_SDKMAN="/home/tooling/.sdkman/candidates/maven/current"
MAVEN_BIN="${MAVEN_SDKMAN}/bin/mvn"

# Check if Maven exists at SDKMAN location
if [ ! -f "${MAVEN_BIN}" ]; then
    echo "✗ Maven not found at ${MAVEN_BIN}"
    echo "  Run: cd ${PROJECT_SOURCE} && ./setup-maven.sh"
    exit 1
fi

echo "✓ Maven found at: ${MAVEN_BIN}"

# Create symlink in /usr/local/bin for global access
if [ ! -L "/usr/local/bin/mvn" ] && [ ! -f "/usr/local/bin/mvn" ]; then
    echo ""
    echo "Creating symlink in /usr/local/bin for global access..."
    sudo ln -sf "${MAVEN_BIN}" /usr/local/bin/mvn
    if [ $? -eq 0 ]; then
        echo "✓ Symlink created: /usr/local/bin/mvn -> ${MAVEN_BIN}"
    else
        echo "⚠️  Could not create symlink (may need sudo permissions)"
    fi
else
    echo "✓ Symlink already exists or mvn already in /usr/local/bin"
fi

# Ensure /usr/local/bin is in PATH
if ! echo "${PATH}" | grep -q "/usr/local/bin"; then
    echo ""
    echo "Adding /usr/local/bin to PATH..."
    export PATH="/usr/local/bin:${PATH}"
    
    # Also add to .bashrc for persistence
    if [ -f "${HOME}/.bashrc" ]; then
        if ! grep -q "/usr/local/bin" "${HOME}/.bashrc"; then
            echo "" >> "${HOME}/.bashrc"
            echo "# Ensure /usr/local/bin is in PATH for Maven" >> "${HOME}/.bashrc"
            echo "export PATH=\"/usr/local/bin:\${PATH}\"" >> "${HOME}/.bashrc"
        fi
    fi
fi

# Verify Maven is accessible
echo ""
echo "Verifying Maven accessibility:"
if command -v mvn &> /dev/null; then
    echo "✓ Maven is accessible via 'mvn' command"
    echo "  Location: $(which mvn)"
    echo "  Version:"
    mvn --version | head -3
else
    echo "✗ Maven is NOT accessible via 'mvn' command"
    echo "  Direct path: ${MAVEN_BIN}"
    echo "  Testing direct path:"
    "${MAVEN_BIN}" --version | head -3
fi

# Set MAVEN_HOME if not set
if [ -z "${MAVEN_HOME}" ]; then
    echo ""
    echo "Setting MAVEN_HOME..."
    export MAVEN_HOME="${MAVEN_SDKMAN}"
    
    # Add to .bashrc
    if [ -f "${HOME}/.bashrc" ]; then
        if ! grep -q "MAVEN_HOME" "${HOME}/.bashrc"; then
            echo "" >> "${HOME}/.bashrc"
            echo "export MAVEN_HOME=\"${MAVEN_SDKMAN}\"" >> "${HOME}/.bashrc"
        fi
    fi
fi

echo ""
echo "=========================================="
echo "Summary"
echo "=========================================="
echo "Maven location: ${MAVEN_BIN}"
echo "Maven accessible: $(command -v mvn || echo 'NO')"
echo "MAVEN_HOME: ${MAVEN_HOME:-NOT SET}"
echo "PATH includes Maven: $(echo ${PATH} | grep -q maven && echo 'YES' || echo 'NO')"
echo ""
echo "If Konveyor analyzer still can't find Maven:"
echo "1. Restart VS Code window (Developer: Reload Window)"
echo "2. Restart Konveyor Analyzer RPC Server"
echo "3. Restart workspace if needed"
echo ""


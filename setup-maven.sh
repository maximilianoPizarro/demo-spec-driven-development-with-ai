#!/bin/bash
# Script to verify and install Maven for Konveyor analyzer
# This ensures Maven is available globally in PATH for all processes

echo "=========================================="
echo "Setting up Maven for Konveyor Analyzer"
echo "=========================================="

# Function to add to PATH permanently
add_to_path() {
    local path_to_add=$1
    local profile_file="${HOME}/.bashrc"
    
    if [ -f "${profile_file}" ]; then
        if ! grep -q "${path_to_add}" "${profile_file}"; then
            echo "" >> "${profile_file}"
            echo "# Maven for Konveyor analyzer" >> "${profile_file}"
            echo "export PATH=\"${path_to_add}:\${PATH}\"" >> "${profile_file}"
        fi
    fi
    
    # Also add to current session
    export PATH="${path_to_add}:${PATH}"
}

# Check if Maven is already available
if command -v mvn &> /dev/null; then
    echo "✓ Maven is already installed"
    mvn --version | head -3
    
    # Ensure it's in PATH permanently
    MAVEN_BIN=$(dirname $(which mvn))
    add_to_path "${MAVEN_BIN}"
    
    exit 0
fi

echo "Maven not found in PATH. Checking common locations..."

# Check if Maven is installed but not in PATH
if [ -d "/usr/share/maven" ]; then
    echo "Found Maven in /usr/share/maven"
    add_to_path "/usr/share/maven/bin"
    if command -v mvn &> /dev/null; then
        echo "✓ Maven is now available"
        mvn --version | head -3
        exit 0
    fi
fi

# Check SDKMAN for Maven
if [ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    echo "SDKMAN found, checking for Maven..."
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    
    if command -v mvn &> /dev/null; then
        echo "✓ Maven is available via SDKMAN"
        mvn --version | head -3
        
        # Ensure SDKMAN Maven is in PATH
        if [ -d "${HOME}/.sdkman/candidates/maven/current/bin" ]; then
            add_to_path "${HOME}/.sdkman/candidates/maven/current/bin"
        fi
        
        exit 0
    else
        echo "Installing Maven via SDKMAN..."
        sdk install maven 3.9.5 || sdk install maven 3.9.4 || sdk install maven 3.9.3 || sdk install maven 3.9.2 || sdk install maven 3.9.1
        
        # Reload SDKMAN
        source "$HOME/.sdkman/bin/sdkman-init.sh"
        
        if command -v mvn &> /dev/null; then
            echo "✓ Maven installed successfully"
            mvn --version | head -3
            
            # Ensure SDKMAN Maven is in PATH
            if [ -d "${HOME}/.sdkman/candidates/maven/current/bin" ]; then
                add_to_path "${HOME}/.sdkman/candidates/maven/current/bin"
            fi
            
            exit 0
        fi
    fi
else
    echo "SDKMAN not found. Installing SDKMAN..."
    curl -s "https://get.sdkman.io" | bash
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    
    echo "Installing Maven via SDKMAN..."
    sdk install maven 3.9.5 || sdk install maven 3.9.4 || sdk install maven 3.9.3 || sdk install maven 3.9.2 || sdk install maven 3.9.1
    
    # Reload SDKMAN
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    
    if command -v mvn &> /dev/null; then
        echo "✓ Maven installed successfully"
        mvn --version | head -3
        
        # Ensure SDKMAN Maven is in PATH
        if [ -d "${HOME}/.sdkman/candidates/maven/current/bin" ]; then
            add_to_path "${HOME}/.sdkman/candidates/maven/current/bin"
        fi
        
        exit 0
    fi
fi

# Try installing via package manager (if available)
if command -v dnf &> /dev/null; then
    echo "Installing Maven via dnf..."
    sudo dnf install -y maven
elif command -v yum &> /dev/null; then
    echo "Installing Maven via yum..."
    sudo yum install -y maven
elif command -v apt-get &> /dev/null; then
    echo "Installing Maven via apt-get..."
    sudo apt-get update && sudo apt-get install -y maven
fi

if command -v mvn &> /dev/null; then
    echo "✓ Maven installed successfully"
    mvn --version | head -3
    
    # Ensure Maven is in PATH permanently
    MAVEN_BIN=$(dirname $(which mvn))
    add_to_path "${MAVEN_BIN}"
    
    echo ""
    echo "Maven location: $(which mvn)"
    echo "Maven added to PATH: ${MAVEN_BIN}"
else
    echo "✗ Failed to install Maven. Konveyor analyzer may not work correctly."
    echo "Please install Maven manually or ensure it's available in the container image."
    exit 1
fi

echo ""
echo "=========================================="
echo "Maven setup complete"
echo "=========================================="
echo ""
echo "Verification:"
echo "  Maven command: $(which mvn)"
echo "  Maven version:"
mvn --version | head -3
echo ""
echo "Note: If Konveyor analyzer still can't find Maven, restart VS Code"
echo "      or reload the window to ensure PATH is updated."


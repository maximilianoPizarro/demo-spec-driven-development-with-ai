#!/bin/bash
# Script to verify and install Maven for Konveyor analyzer

echo "=========================================="
echo "Setting up Maven for Konveyor Analyzer"
echo "=========================================="

# Check if Maven is already available
if command -v mvn &> /dev/null; then
    echo "✓ Maven is already installed"
    mvn --version | head -3
    exit 0
fi

echo "Maven not found in PATH. Checking common locations..."

# Check if Maven is installed but not in PATH
if [ -d "/usr/share/maven" ]; then
    echo "Found Maven in /usr/share/maven"
    export PATH="/usr/share/maven/bin:${PATH}"
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
        exit 0
    else
        echo "Installing Maven via SDKMAN..."
        sdk install maven 3.9.5 || sdk install maven 3.9.4 || sdk install maven 3.9.3 || sdk install maven 3.9.2 || sdk install maven 3.9.1
        if command -v mvn &> /dev/null; then
            echo "✓ Maven installed successfully"
            mvn --version | head -3
            exit 0
        fi
    fi
else
    echo "SDKMAN not found. Installing SDKMAN..."
    curl -s "https://get.sdkman.io" | bash
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    
    echo "Installing Maven via SDKMAN..."
    sdk install maven 3.9.5 || sdk install maven 3.9.4 || sdk install maven 3.9.3 || sdk install maven 3.9.2 || sdk install maven 3.9.1
    
    if command -v mvn &> /dev/null; then
        echo "✓ Maven installed successfully"
        mvn --version | head -3
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
else
    echo "✗ Failed to install Maven. Konveyor analyzer may not work correctly."
    echo "Please install Maven manually or ensure it's available in the container image."
    exit 1
fi

echo ""
echo "=========================================="
echo "Maven setup complete"
echo "=========================================="


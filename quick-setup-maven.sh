#!/bin/bash
# Quick Maven setup - only verifies Maven is available, doesn't install
# This is for postStart to be fast. Full setup is done via setup-maven command.

echo "Quick Maven check for Konveyor..."

# Check if Maven is already available (should be via PATH env var)
if command -v mvn &> /dev/null; then
    echo "✓ Maven is available"
    exit 0
fi

# Check SDKMAN location (most common)
if [ -f "/home/tooling/.sdkman/candidates/maven/current/bin/mvn" ]; then
    echo "✓ Maven found at SDKMAN location"
    # Add to PATH for current session
    export PATH="/home/tooling/.sdkman/candidates/maven/current/bin:${PATH}"
    exit 0
fi

# If not found, just warn - full setup will be done via command
echo "⚠️  Maven not immediately available. Run '2. Setup Maven for Konveyor' command to install."
echo "   Konveyor analyzer may not work until Maven is installed."
exit 0


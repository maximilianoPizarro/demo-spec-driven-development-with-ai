#!/bin/bash
# Script to verify Maven is available in PATH for Konveyor analyzer

echo "=========================================="
echo "Verifying Maven PATH Configuration"
echo "=========================================="

echo ""
echo "1. Current PATH:"
echo "${PATH}" | tr ':' '\n' | grep -E "(maven|java)" || echo "  No Maven/Java paths found in PATH"

echo ""
echo "2. Maven command availability:"
if command -v mvn &> /dev/null; then
    echo "✓ Maven found at: $(which mvn)"
    echo "  Version:"
    mvn --version | head -3
else
    echo "✗ Maven NOT found in PATH"
fi

echo ""
echo "3. Environment variables:"
echo "  MAVEN_HOME: ${MAVEN_HOME:-NOT SET}"
echo "  JAVA_HOME: ${JAVA_HOME:-NOT SET}"
echo "  PATH: ${PATH}"

echo ""
echo "4. Checking SDKMAN locations:"
if [ -d "/home/tooling/.sdkman/candidates/maven/current" ]; then
    echo "✓ Maven SDKMAN directory exists"
    if [ -f "/home/tooling/.sdkman/candidates/maven/current/bin/mvn" ]; then
        echo "✓ Maven binary exists at SDKMAN location"
        /home/tooling/.sdkman/candidates/maven/current/bin/mvn --version | head -3
    else
        echo "✗ Maven binary NOT found at SDKMAN location"
    fi
else
    echo "✗ Maven SDKMAN directory NOT found"
fi

echo ""
echo "5. Testing Maven from SDKMAN location:"
if [ -f "/home/tooling/.sdkman/candidates/maven/current/bin/mvn" ]; then
    echo "  Direct path test:"
    /home/tooling/.sdkman/candidates/maven/current/bin/mvn --version | head -1
fi

echo ""
echo "=========================================="
echo "Recommendations"
echo "=========================================="

if ! command -v mvn &> /dev/null; then
    echo "→ Maven is not in PATH. Add to devfile env:"
    echo "  PATH: \"/home/tooling/.sdkman/candidates/maven/current/bin:\${PATH}\""
fi

if [ -z "${MAVEN_HOME}" ]; then
    echo "→ MAVEN_HOME is not set. Add to devfile env:"
    echo "  MAVEN_HOME: \"/home/tooling/.sdkman/candidates/maven/current\""
fi

echo ""
echo "=========================================="


#!/bin/bash
# Script to verify and install JDK 21 using SDKMAN

echo "Checking Java version..."
java -version 2>&1 | head -n 1

echo ""
echo "Checking if SDKMAN is installed..."
if [ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    echo "SDKMAN found, initializing..."
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    
    echo "Checking installed Java versions..."
    sdk list java | grep "21\." | head -5
    
    echo ""
    echo "Checking current Java version..."
    CURRENT_JAVA=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}' | cut -d'.' -f1)
    
    if [ "$CURRENT_JAVA" != "21" ]; then
        echo "JDK 21 is not the current version. Installing JDK 21..."
        sdk install java 21.0.5-tem || sdk install java 21.0.4-tem || sdk install java 21.0.3-tem || sdk install java 21.0.2-tem || sdk install java 21.0.1-tem
        
        echo "Setting JDK 21 as default..."
        sdk default java 21.0.5-tem || sdk default java 21.0.4-tem || sdk default java 21.0.3-tem || sdk default java 21.0.2-tem || sdk default java 21.0.1-tem
        
        echo "Verifying Java version after installation..."
        java -version 2>&1 | head -n 1
    else
        echo "✅ JDK 21 is already the current version"
    fi
else
    echo "SDKMAN not found. Installing SDKMAN..."
    curl -s "https://get.sdkman.io" | bash
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    
    echo "Installing JDK 21..."
    sdk install java 21.0.5-tem || sdk install java 21.0.4-tem || sdk install java 21.0.3-tem || sdk install java 21.0.2-tem || sdk install java 21.0.1-tem
    
    echo "Setting JDK 21 as default..."
    sdk default java 21.0.5-tem || sdk default java 21.0.4-tem || sdk default java 21.0.3-tem || sdk default java 21.0.2-tem || sdk default java 21.0.1-tem
    
    echo "Verifying Java installation..."
    java -version 2>&1 | head -n 1
fi

echo ""
echo "Final Java version:"
java -version 2>&1 | head -n 3


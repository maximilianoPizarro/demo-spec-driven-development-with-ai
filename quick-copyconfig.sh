#!/bin/bash
# Quick configuration script - fast setup for Continue and Konveyor
# This version doesn't wait long for environment variables

echo "Quick configuration setup..."

# Continue config (fast, no waiting)
if [ -f "${PROJECT_SOURCE}/setup-continue-config.sh" ]; then
    echo "Configuring Continue AI..."
    cd "${PROJECT_SOURCE}"
    chmod +x setup-continue-config.sh
    ./setup-continue-config.sh
else
    echo "Warning: setup-continue-config.sh not found, skipping Continue config"
fi

# Konveyor config (with minimal wait)
if [ -f "${PROJECT_SOURCE}/setup-konveyor-config.sh" ]; then
    echo "Configuring Konveyor..."
    cd "${PROJECT_SOURCE}"
    chmod +x setup-konveyor-config.sh
    
    # Check if env vars are available immediately, if not skip (will be configured later)
    if [ -n "${LLM_SERVER_TOKEN}" ] || [ -n "${OPENAI_API_KEY}" ]; then
        ./setup-konveyor-config.sh
    else
        echo "Environment variables not yet available, Konveyor config will be set up when you run '3. Configure Continue AI and Konveyor' command"
    fi
else
    echo "Warning: setup-konveyor-config.sh not found, skipping Konveyor config"
fi

echo "Quick configuration complete!"


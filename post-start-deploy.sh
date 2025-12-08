#!/bin/bash
# Script to deploy and configure services after workspace startup
# This runs in the background to avoid blocking workspace initialization

echo "=========================================="
echo "Starting post-startup deployment tasks..."
echo "=========================================="

# Function to run a command in background and log output
run_background() {
    local cmd_name=$1
    local cmd=$2
    echo "Starting $cmd_name in background..."
    (
        echo "[$cmd_name] Starting at $(date)"
        eval "$cmd" 2>&1 | while IFS= read -r line; do
            echo "[$cmd_name] $line"
        done
        echo "[$cmd_name] Completed at $(date)"
    ) &
}

# Deploy to Kubernetes/OpenShift
if [ -f "${PROJECT_SOURCE}/deploy-k8s.sh" ]; then
    chmod +x "${PROJECT_SOURCE}/deploy-k8s.sh"
    run_background "deploy-k8s" "cd ${PROJECT_SOURCE} && ./deploy-k8s.sh"
else
    echo "Warning: deploy-k8s.sh not found"
fi

# Wait a bit for deployment to start
sleep 10

# Setup Keycloak realm (will wait for Keycloak to be ready)
if [ -f "${PROJECT_SOURCE}/setup-keycloak-realm.sh" ]; then
    chmod +x "${PROJECT_SOURCE}/setup-keycloak-realm.sh"
    run_background "setup-keycloak-realm" "cd ${PROJECT_SOURCE} && ./setup-keycloak-realm.sh"
else
    echo "Warning: setup-keycloak-realm.sh not found"
fi

# Setup WildFly datasource (will wait for WildFly to be ready)
if [ -f "${PROJECT_SOURCE}/setup-wildfly-datasource.sh" ]; then
    chmod +x "${PROJECT_SOURCE}/setup-wildfly-datasource.sh"
    run_background "setup-wildfly-datasource" "cd ${PROJECT_SOURCE} && ./setup-wildfly-datasource.sh"
else
    echo "Warning: setup-wildfly-datasource.sh not found"
fi

echo "Post-startup tasks started in background."
echo "Check logs for progress: tail -f /tmp/post-start-*.log (if logging to files)"
echo "Or check the terminal output for [task-name] prefixed messages."

# Wait for all background jobs
wait

echo "=========================================="
echo "All post-startup tasks completed!"
echo "=========================================="


#!/bin/bash
# Script to deploy Coolstore application to Kubernetes/OpenShift from DevSpaces

# Don't exit on error - allow graceful failure if kubectl/oc not available
set +e

echo "=========================================="
echo "Deploying Coolstore to Kubernetes/OpenShift"
echo "=========================================="

# Check if kubectl or oc is available
if command -v oc &> /dev/null; then
    if oc api-versions 2>/dev/null | grep -q route.openshift.io; then
        CLUSTER_TYPE="openshift"
        CMD="oc"
        echo "✓ OpenShift CLI (oc) detected"
    else
        CLUSTER_TYPE="kubernetes"
        CMD="oc"
        echo "✓ Kubernetes CLI (oc) detected"
    fi
elif command -v kubectl &> /dev/null; then
    CLUSTER_TYPE="kubernetes"
    CMD="kubectl"
    echo "✓ Kubernetes CLI (kubectl) detected"
else
    echo "⚠️  Warning: Neither 'oc' nor 'kubectl' found in PATH"
    echo "Skipping Kubernetes/OpenShift deployment."
    echo ""
    echo "To deploy later, install kubectl or oc CLI:"
    echo "  kubectl: curl -LO \"https://dl.k8s.io/release/\$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl\""
    echo "  oc: Visit https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/"
    echo ""
    echo "Then run: cd k8s && ./deploy.sh"
    exit 0
fi

# Check if we're logged in (non-blocking)
if ! $CMD get nodes &> /dev/null && ! $CMD get projects &> /dev/null; then
    echo "⚠️  Warning: Not logged in to cluster or cluster not accessible"
    echo "Skipping Kubernetes/OpenShift deployment."
    echo ""
    echo "To deploy later, login first:"
    if [ "$CLUSTER_TYPE" = "openshift" ]; then
        echo "  oc login <your-openshift-url>"
    else
        echo "  kubectl config set-context <your-context>"
    fi
    echo ""
    echo "Then run: cd k8s && ./deploy.sh"
    exit 0
fi

# Navigate to k8s directory
cd "${PROJECT_SOURCE}/k8s" || {
    echo "Error: k8s directory not found"
    exit 1
}

# Make deploy script executable
chmod +x deploy.sh

# Execute deployment
echo ""
echo "Starting deployment..."
set -e  # Enable error checking for deployment
./deploy.sh
DEPLOY_EXIT_CODE=$?
set +e  # Disable error checking for final messages

if [ $DEPLOY_EXIT_CODE -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "Deployment completed successfully!"
    echo "=========================================="
else
    echo ""
    echo "=========================================="
    echo "Deployment completed with warnings/errors"
    echo "Check the output above for details"
    echo "=========================================="
fi


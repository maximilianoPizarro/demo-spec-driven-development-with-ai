#!/bin/bash
# Script to undeploy Coolstore application from Kubernetes/OpenShift

set -e

# Detect if using OpenShift or Kubernetes
if command -v oc &> /dev/null && oc api-versions | grep -q route.openshift.io; then
    CLUSTER_TYPE="openshift"
    CMD="oc"
else
    CLUSTER_TYPE="kubernetes"
    CMD="kubectl"
fi

echo "Detected cluster type: $CLUSTER_TYPE"
echo "Using command: $CMD"

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

read -p "Are you sure you want to delete all Coolstore resources? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

echo -e "${YELLOW}Deleting resources...${NC}"

if [ "$CLUSTER_TYPE" = "openshift" ]; then
    $CMD delete -f route.yaml --ignore-not-found=true
fi

$CMD delete -f wildfly-deployment.yaml --ignore-not-found=true
$CMD delete -f keycloak-deployment.yaml --ignore-not-found=true
$CMD delete -f postgres-deployment.yaml --ignore-not-found=true
$CMD delete -f wildfly-configmap.yaml --ignore-not-found=true
$CMD delete -f postgres-init-configmap.yaml --ignore-not-found=true
$CMD delete -f wildfly-secret.yaml --ignore-not-found=true
$CMD delete -f keycloak-secret.yaml --ignore-not-found=true
$CMD delete -f postgres-secret.yaml --ignore-not-found=true
$CMD delete -f keycloak-pvc.yaml --ignore-not-found=true
$CMD delete -f postgres-pvc.yaml --ignore-not-found=true

if [ "$CLUSTER_TYPE" = "kubernetes" ]; then
    $CMD delete -f ingress.yaml --ignore-not-found=true
fi

read -p "Delete namespace? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    $CMD delete -f namespace.yaml --ignore-not-found=true
    echo -e "${RED}Namespace deleted.${NC}"
else
    echo -e "${YELLOW}Namespace preserved.${NC}"
fi

echo -e "${YELLOW}Cleanup complete!${NC}"


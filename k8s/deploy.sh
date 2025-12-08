#!/bin/bash
# Script to deploy Coolstore application to Kubernetes/OpenShift

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
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to wait for deployment
wait_for_deployment() {
    local app=$1
    local namespace=$2
    echo -e "${YELLOW}Waiting for $app to be ready...${NC}"
    $CMD wait --for=condition=ready pod -l app=$app -n $namespace --timeout=300s || {
        echo -e "${YELLOW}Warning: Timeout waiting for $app. Continuing...${NC}"
    }
}

# Apply manifests in order
echo -e "${GREEN}Creating namespace...${NC}"
$CMD apply -f namespace.yaml

echo -e "${GREEN}Creating secrets...${NC}"
$CMD apply -f postgres-secret.yaml
$CMD apply -f keycloak-secret.yaml
$CMD apply -f wildfly-secret.yaml

echo -e "${GREEN}Creating persistent volume claims...${NC}"
$CMD apply -f postgres-pvc.yaml
$CMD apply -f keycloak-pvc.yaml

echo -e "${GREEN}Creating ConfigMaps...${NC}"
$CMD apply -f postgres-init-configmap.yaml
$CMD apply -f wildfly-configmap.yaml

echo -e "${GREEN}Deploying PostgreSQL...${NC}"
$CMD apply -f postgres-deployment.yaml
wait_for_deployment postgres coolstore

echo -e "${GREEN}Deploying Keycloak...${NC}"
$CMD apply -f keycloak-deployment.yaml
wait_for_deployment keycloak coolstore

echo -e "${GREEN}Deploying WildFly...${NC}"
$CMD apply -f wildfly-deployment.yaml
wait_for_deployment wildfly coolstore

if [ "$CLUSTER_TYPE" = "openshift" ]; then
    echo -e "${GREEN}Creating OpenShift Routes...${NC}"
    $CMD apply -f route.yaml
    
    echo -e "${GREEN}Deployment complete!${NC}"
    echo ""
    echo "Routes:"
    $CMD get routes -n coolstore
else
    echo -e "${GREEN}Creating Ingress...${NC}"
    $CMD apply -f ingress.yaml
    
    echo -e "${GREEN}Deployment complete!${NC}"
    echo ""
    echo "Services:"
    $CMD get svc -n coolstore
    echo ""
    echo "To access the application, update /etc/hosts or use port-forwarding:"
    echo "  kubectl port-forward svc/wildfly 8080:8080 -n coolstore"
    echo "  kubectl port-forward svc/keycloak 8081:8081 -n coolstore"
fi

echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Import Keycloak realm from coolstore/realm-export.json"
echo "2. Configure WildFly datasource to connect to PostgreSQL"
echo "3. Deploy the Coolstore WAR file to WildFly"


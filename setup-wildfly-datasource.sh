#!/bin/bash
# Script to configure WildFly with PostgreSQL datasource
# Supports both local containers and Kubernetes/OpenShift deployments

# Try to detect service URLs from Kubernetes/OpenShift if available
if command -v oc &> /dev/null && oc get route wildfly-mgmt -n coolstore &> /dev/null; then
    WILDFLY_HOST=$(oc get route wildfly-mgmt -n coolstore -o jsonpath='{.spec.host}' 2>/dev/null)
    if [ -n "$WILDFLY_HOST" ]; then
        WILDFLY_PORT="80"
        echo "Detected OpenShift route for WildFly management: ${WILDFLY_HOST}"
    fi
elif command -v kubectl &> /dev/null && kubectl get svc wildfly -n coolstore &> /dev/null; then
    WILDFLY_HOST="${WILDFLY_HOST:-wildfly.coolstore.svc.cluster.local}"
    echo "Using Kubernetes service URL: ${WILDFLY_HOST}"
    echo "Note: You may need to set up port-forwarding: kubectl port-forward svc/wildfly 9990:9990 -n coolstore"
fi

WILDFLY_HOST="${WILDFLY_HOST:-wildfly}"
WILDFLY_PORT="${WILDFLY_PORT:-9990}"

# Try to detect PostgreSQL service URL from Kubernetes
if command -v kubectl &> /dev/null && kubectl get svc postgres -n coolstore &> /dev/null; then
    POSTGRES_HOST="${POSTGRES_HOST:-postgres.coolstore.svc.cluster.local}"
    echo "Using Kubernetes PostgreSQL service: ${POSTGRES_HOST}"
fi

POSTGRES_HOST="${POSTGRES_HOST:-postgres}"
POSTGRES_PORT="${POSTGRES_PORT:-5432}"
POSTGRES_DB="${POSTGRES_DB:-postgresDB}"
POSTGRES_USER="${POSTGRES_USER:-postgresUser}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-postgresPW}"

echo "Waiting for WildFly to be ready..."
max_attempts=60
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if curl -s -f "http://${WILDFLY_HOST}:${WILDFLY_PORT}" > /dev/null 2>&1; then
        echo "WildFly is ready!"
        break
    fi
    attempt=$((attempt + 1))
    echo "Attempt $attempt/$max_attempts: Waiting for WildFly..."
    sleep 5
done

if [ $attempt -eq $max_attempts ]; then
    echo "Error: WildFly is not available after $max_attempts attempts"
    exit 1
fi

echo "Configuring PostgreSQL JDBC driver and datasource in WildFly..."

# Note: This script requires access to WildFly CLI
# In a real environment, this would be done via remote CLI or by configuring the image
echo "To fully configure WildFly, you need to:"
echo "1. Download the PostgreSQL JDBC driver"
echo "2. Configure the PostgreSQL module in WildFly"
echo "3. Create the CoolstoreDS datasource"
echo ""
echo "You can do this manually using the WildFly CLI:"
echo "  /subsystem=datasources/jdbc-driver=postgresql:add(driver-name=postgresql,driver-module-name=org.postgresql)"
echo "  data-source add --name=CoolstoreDS --jndi-name=java:jboss/datasources/CoolstoreDS --driver-name=postgresql --connection-url=jdbc:postgresql://${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB} --user-name=${POSTGRES_USER} --password=${POSTGRES_PASSWORD}"


# Kubernetes Manifests for Coolstore Application

This directory contains Kubernetes manifests to deploy the Coolstore application and its dependencies (PostgreSQL, Keycloak, and WildFly) to a Kubernetes or OpenShift cluster.

## Prerequisites

- Kubernetes cluster (1.19+) or OpenShift cluster (4.x+)
- `kubectl` or `oc` CLI configured to access your cluster
- Access to pull container images from:
  - `postgres:15`
  - `quay.io/keycloak/keycloak:20.0.5`
  - `quay.io/wildfly/wildfly:27.0.1.Final-jdk17`

## Quick Start

### For OpenShift

```bash
# Create namespace
oc apply -f namespace.yaml

# Deploy secrets
oc apply -f postgres-secret.yaml
oc apply -f keycloak-secret.yaml
oc apply -f wildfly-secret.yaml

# Deploy persistent volume claims
oc apply -f postgres-pvc.yaml
oc apply -f keycloak-pvc.yaml

# Deploy ConfigMap
oc apply -f wildfly-configmap.yaml

# Deploy PostgreSQL
oc apply -f postgres-deployment.yaml

# Wait for PostgreSQL to be ready
oc wait --for=condition=ready pod -l app=postgres -n coolstore --timeout=300s

# Deploy Keycloak
oc apply -f keycloak-deployment.yaml

# Wait for Keycloak to be ready
oc wait --for=condition=ready pod -l app=keycloak -n coolstore --timeout=300s

# Deploy WildFly
oc apply -f wildfly-deployment.yaml

# Create routes
oc apply -f route.yaml

# Get route URLs
oc get routes -n coolstore
```

### For Kubernetes

```bash
# Create namespace
kubectl apply -f namespace.yaml

# Deploy secrets
kubectl apply -f postgres-secret.yaml
kubectl apply -f keycloak-secret.yaml
kubectl apply -f wildfly-secret.yaml

# Deploy persistent volume claims
kubectl apply -f postgres-pvc.yaml
kubectl apply -f keycloak-pvc.yaml

# Deploy ConfigMap
kubectl apply -f wildfly-configmap.yaml

# Deploy PostgreSQL
kubectl apply -f postgres-deployment.yaml

# Wait for PostgreSQL to be ready
kubectl wait --for=condition=ready pod -l app=postgres -n coolstore --timeout=300s

# Deploy Keycloak
kubectl apply -f keycloak-deployment.yaml

# Wait for Keycloak to be ready
kubectl wait --for=condition=ready pod -l app=keycloak -n coolstore --timeout=300s

# Deploy WildFly
kubectl apply -f wildfly-deployment.yaml

# Deploy Ingress (if using ingress controller)
kubectl apply -f ingress.yaml
```

## Deploy All at Once

You can also deploy everything at once:

```bash
# For OpenShift
oc apply -f namespace.yaml
oc apply -f postgres-secret.yaml
oc apply -f keycloak-secret.yaml
oc apply -f wildfly-secret.yaml
oc apply -f postgres-pvc.yaml
oc apply -f keycloak-pvc.yaml
oc apply -f wildfly-configmap.yaml
oc apply -f postgres-deployment.yaml
oc apply -f keycloak-deployment.yaml
oc apply -f wildfly-deployment.yaml
oc apply -f route.yaml

# For Kubernetes
kubectl apply -f namespace.yaml
kubectl apply -f postgres-secret.yaml
kubectl apply -f keycloak-secret.yaml
kubectl apply -f wildfly-secret.yaml
kubectl apply -f postgres-pvc.yaml
kubectl apply -f keycloak-pvc.yaml
kubectl apply -f wildfly-configmap.yaml
kubectl apply -f postgres-deployment.yaml
kubectl apply -f keycloak-deployment.yaml
kubectl apply -f wildfly-deployment.yaml
kubectl apply -f ingress.yaml
```

## Post-Deployment Configuration

### 1. Import Keycloak Realm

After Keycloak is running, import the realm configuration:

```bash
# Get Keycloak route URL
KEYCLOAK_URL=$(oc get route keycloak -n coolstore -o jsonpath='{.spec.host}')

# Or for Kubernetes (update with your ingress host)
KEYCLOAK_URL=keycloak.local

# Import realm (requires realm-export.json from coolstore directory)
curl -X POST "http://${KEYCLOAK_URL}/admin/realms" \
  -H "Authorization: Bearer $(curl -s -X POST "http://${KEYCLOAK_URL}/realms/master/protocol/openid-connect/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=admin" \
    -d "password=admin" \
    -d "grant_type=password" \
    -d "client_id=admin-cli" | jq -r '.access_token')" \
  -H "Content-Type: application/json" \
  -d @../coolstore/realm-export.json
```

### 2. Configure WildFly Datasource

After WildFly is running, configure the PostgreSQL datasource using the WildFly CLI or management console.

Access the WildFly management console:
- OpenShift: `oc get route wildfly-mgmt -n coolstore`
- Kubernetes: Use port-forward: `kubectl port-forward svc/wildfly 9990:9990 -n coolstore`

Then configure the datasource:
1. Download PostgreSQL JDBC driver
2. Add PostgreSQL module
3. Create CoolstoreDS datasource pointing to `postgres:5432/postgresDB`

## Accessing the Application

### OpenShift Routes

```bash
# Get route URLs
oc get routes -n coolstore

# Access WildFly application
# http://<wildfly-route-url>

# Access Keycloak console
# http://<keycloak-route-url>

# Access WildFly management console
# http://<wildfly-mgmt-route-url>
```

### Kubernetes Ingress

Update `/etc/hosts` or use DNS:
```
<ingress-ip> coolstore.local
<ingress-ip> keycloak.local
```

Then access:
- WildFly: `http://coolstore.local`
- Keycloak: `http://keycloak.local`

### Port Forwarding (Alternative)

```bash
# WildFly
kubectl port-forward svc/wildfly 8080:8080 -n coolstore

# Keycloak
kubectl port-forward svc/keycloak 8081:8081 -n coolstore

# WildFly Management
kubectl port-forward svc/wildfly 9990:9990 -n coolstore
```

## Troubleshooting

### Check Pod Status

```bash
oc get pods -n coolstore
# or
kubectl get pods -n coolstore
```

### View Logs

```bash
# PostgreSQL
oc logs -l app=postgres -n coolstore

# Keycloak
oc logs -l app=keycloak -n coolstore

# WildFly
oc logs -l app=wildfly -n coolstore
```

### Check Services

```bash
oc get svc -n coolstore
# or
kubectl get svc -n coolstore
```

### Check Persistent Volumes

```bash
oc get pvc -n coolstore
# or
kubectl get pvc -n coolstore
```

## Cleanup

To remove all resources:

```bash
# For OpenShift
oc delete namespace coolstore

# For Kubernetes
kubectl delete namespace coolstore
```

Or delete individual resources:

```bash
oc delete -f route.yaml
oc delete -f wildfly-deployment.yaml
oc delete -f keycloak-deployment.yaml
oc delete -f postgres-deployment.yaml
oc delete -f wildfly-configmap.yaml
oc delete -f wildfly-secret.yaml
oc delete -f keycloak-secret.yaml
oc delete -f postgres-secret.yaml
oc delete -f keycloak-pvc.yaml
oc delete -f postgres-pvc.yaml
oc delete -f namespace.yaml
```

## Notes

- The PostgreSQL deployment includes an init script to create multiple databases (postgresDB and keycloak)
- Keycloak is configured to use PostgreSQL as its database
- WildFly includes init containers that wait for PostgreSQL and Keycloak to be ready
- All services use persistent volumes for data persistence
- Secrets contain default passwords - **change them in production!**


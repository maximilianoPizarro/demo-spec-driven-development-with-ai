#!/bin/bash
# Script to import Keycloak realm from realm-export.json

KEYCLOAK_URL="${KEYCLOAK_URL:-http://keycloak:8081}"
REALM_FILE="${PROJECT_SOURCE}/coolstore/realm-export.json"
ADMIN_USER="${KEYCLOAK_ADMIN:-admin}"
ADMIN_PASSWORD="${KEYCLOAK_ADMIN_PASSWORD:-admin}"

echo "Waiting for Keycloak to be ready..."
max_attempts=30
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if curl -s -f "${KEYCLOAK_URL}/health/ready" > /dev/null 2>&1; then
        echo "Keycloak is ready!"
        break
    fi
    attempt=$((attempt + 1))
    echo "Attempt $attempt/$max_attempts: Waiting for Keycloak..."
    sleep 5
done

if [ $attempt -eq $max_attempts ]; then
    echo "Error: Keycloak is not available after $max_attempts attempts"
    exit 1
fi

echo "Getting admin token..."
TOKEN=$(curl -s -X POST "${KEYCLOAK_URL}/realms/master/protocol/openid-connect/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=${ADMIN_USER}" \
    -d "password=${ADMIN_PASSWORD}" \
    -d "grant_type=password" \
    -d "client_id=admin-cli" | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo "Error: Could not get admin token"
    exit 1
fi

echo "Checking if realm 'eap' already exists..."
EXISTING_REALM=$(curl -s -X GET "${KEYCLOAK_URL}/admin/realms/eap" \
    -H "Authorization: Bearer ${TOKEN}" \
    -H "Content-Type: application/json")

if echo "$EXISTING_REALM" | grep -q '"realm":"eap"'; then
    echo "Realm 'eap' already exists. Deleting it..."
    curl -s -X DELETE "${KEYCLOAK_URL}/admin/realms/eap" \
        -H "Authorization: Bearer ${TOKEN}" \
        -H "Content-Type: application/json"
    sleep 2
fi

if [ ! -f "$REALM_FILE" ]; then
    echo "Error: File not found: $REALM_FILE"
    exit 1
fi

echo "Importing realm from $REALM_FILE..."
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "${KEYCLOAK_URL}/admin/realms" \
    -H "Authorization: Bearer ${TOKEN}" \
    -H "Content-Type: application/json" \
    -d @"${REALM_FILE}")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "204" ]; then
    echo "✅ Realm 'eap' imported successfully!"
else
    echo "⚠️  HTTP Response: $HTTP_CODE"
    echo "Response: $(echo "$RESPONSE" | head -n-1)"
    # Don't fail if realm already exists
    if [ "$HTTP_CODE" != "409" ]; then
        exit 1
    fi
fi

echo "Realm configured successfully. You can access Keycloak at: ${KEYCLOAK_URL}"


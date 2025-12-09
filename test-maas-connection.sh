#!/bin/bash
# Script to test MaaS endpoint connectivity and authentication

echo "=========================================="
echo "Testing MaaS Endpoint Connection"
echo "=========================================="

API_TOKEN="${LLM_SERVER_TOKEN:-${OPENAI_API_KEY}}"
API_BASE="${LLM_SERVER_URL:-https://llama-3-2-3b-maas-apicast-production.apps.prod.rhoai.rh-aiservices-bu.com:443/v1}"

if [ -z "${API_TOKEN}" ]; then
    echo "ERROR: LLM_SERVER_TOKEN or OPENAI_API_KEY not set"
    exit 1
fi

echo ""
echo "Testing endpoint: ${API_BASE}"
echo "Token prefix: $(echo ${API_TOKEN} | cut -c1-10)..."
echo ""

# Test 1: Simple connectivity
echo "1. Testing connectivity..."
if curl -s --connect-timeout 5 "${API_BASE}/models" > /dev/null 2>&1; then
    echo "   ✓ Endpoint is reachable"
else
    echo "   ✗ Cannot reach endpoint (may require authentication)"
fi

# Test 2: Test with API key in header
echo ""
echo "2. Testing authentication with API key header..."
RESPONSE=$(curl -s -w "\n%{http_code}" \
    -H "Authorization: Bearer ${API_TOKEN}" \
    -H "Content-Type: application/json" \
    "${API_BASE}/models" 2>&1)

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

echo "   HTTP Status: ${HTTP_CODE}"

if [ "${HTTP_CODE}" = "200" ]; then
    echo "   ✓ Authentication successful!"
    echo "   Response preview:"
    echo "$BODY" | head -5 | sed 's/^/      /'
elif [ "${HTTP_CODE}" = "401" ]; then
    echo "   ✗ Authentication failed (401 Unauthorized)"
    echo "   Response:"
    echo "$BODY" | sed 's/^/      /'
    echo ""
    echo "   Possible issues:"
    echo "   - Token is invalid or expired"
    echo "   - Token format is incorrect"
    echo "   - Endpoint requires different authentication method"
elif [ "${HTTP_CODE}" = "403" ]; then
    echo "   ✗ Forbidden (403) - Token may be valid but lacks permissions"
    echo "   Response:"
    echo "$BODY" | sed 's/^/      /'
else
    echo "   ⚠️  Unexpected status code: ${HTTP_CODE}"
    echo "   Response:"
    echo "$BODY" | head -10 | sed 's/^/      /'
fi

# Test 3: Test with API key as query parameter (some endpoints use this)
echo ""
echo "3. Testing with API key as query parameter..."
RESPONSE2=$(curl -s -w "\n%{http_code}" \
    -H "Content-Type: application/json" \
    "${API_BASE}/models?api_key=${API_TOKEN}" 2>&1)

HTTP_CODE2=$(echo "$RESPONSE2" | tail -n1)
if [ "${HTTP_CODE2}" = "200" ]; then
    echo "   ✓ Query parameter authentication works"
else
    echo "   ✗ Query parameter authentication failed (${HTTP_CODE2})"
fi

# Test 4: Test OpenAI-compatible format
echo ""
echo "4. Testing OpenAI-compatible format..."
RESPONSE3=$(curl -s -w "\n%{http_code}" \
    -H "Authorization: Bearer ${API_TOKEN}" \
    -H "Content-Type: application/json" \
    -X POST \
    -d '{"model":"llama-3-2-3b","messages":[{"role":"user","content":"test"}]}' \
    "${API_BASE}/chat/completions" 2>&1)

HTTP_CODE3=$(echo "$RESPONSE3" | tail -n1)
BODY3=$(echo "$RESPONSE3" | head -n-1)

echo "   HTTP Status: ${HTTP_CODE3}"
if [ "${HTTP_CODE3}" = "200" ] || [ "${HTTP_CODE3}" = "201" ]; then
    echo "   ✓ Chat completions endpoint works!"
elif [ "${HTTP_CODE3}" = "401" ]; then
    echo "   ✗ Authentication failed for chat endpoint"
    echo "   Response:"
    echo "$BODY3" | sed 's/^/      /'
else
    echo "   Response:"
    echo "$BODY3" | head -5 | sed 's/^/      /'
fi

echo ""
echo "=========================================="
echo "Test complete"
echo "=========================================="
echo ""
echo "If authentication is failing:"
echo "1. Verify the token is correct and not expired"
echo "2. Check if the endpoint URL is correct"
echo "3. Verify the token has the necessary permissions"
echo "4. Check if the endpoint requires additional headers"


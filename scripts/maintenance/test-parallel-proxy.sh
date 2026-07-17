#!/bin/bash

# Test Parallel Proxy Endpoint
# This demonstrates the side-by-side routing pattern

echo "========================================"
echo "Testing Parallel Proxy Endpoint"
echo "========================================"
echo ""

# Create session token
echo "1️⃣ Creating session..."
SESSION_RESPONSE=$(curl -s -X POST http://localhost:3002/sessions \
  -H "Content-Type: application/json" \
  -d '{"modelId": "mcp2-local-test"}')

TOKEN=$(echo "$SESSION_RESPONSE" | jq -r '.sessionToken')
echo "✅ Session: ${TOKEN:0:20}..."
echo ""

# Test parallel proxy without user LLM
echo "2️⃣ Testing parallel-proxy (MCP 2.0 only)..."
RESPONSE=$(curl -s -X POST http://localhost:3002/v1/parallel-proxy \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "zai.glm-5",
    "max_tokens": 200,
    "messages": [
      {
        "role": "user",
        "content": "What is the OIR framework in engineering governance?"
      }
    ]
  }')

echo "$RESPONSE" | jq '.'
echo ""

# Test parallel proxy WITH user LLM proxy
echo "3️⃣ Testing parallel-proxy (with user LLM side-by-side)..."
echo "   Note: User LLM proxy optional"
echo ""

RESPONSE_WITH_LLM=$(curl -s -X POST http://localhost:3002/v1/parallel-proxy \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "x-llm-proxy-url: https://api.openai.com/v1" \
  -H "x-llm-proxy-key: sk-test-key" \
  -d '{
    "model": "zai.glm-5",
    "max_tokens": 200,
    "messages": [
      {
        "role": "user",
        "content": "Explain Evidence Ladder debugging methodology"
      }
    ]
  }')

echo "$RESPONSE_WITH_LLM" | jq '.'
echo ""

echo "========================================"
echo "Architecture Flow:"
echo "========================================"
echo ""
echo "User Request"
echo "     ↓"
echo "Bhavishya Gateway (localhost:3002)"
echo "     ↓ Classifies & splits query"
echo "     ├─→ User's LLM Proxy (optional)"
echo "     │   (side-by-side)"
echo "     └─→ MCP 2.0 Server (localhost:3001)"
echo "         ↓"
echo "     AWS Bedrock GLM-5"
echo "         ↓"
echo "     Governance Response"
echo ""

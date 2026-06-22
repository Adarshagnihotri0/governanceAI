#!/bin/bash

# Simple query interface to MCP 2.0 through Bhavishya Gateway

if [ -z "$1" ]; then
  echo "Usage: ./ask-governance.sh \"your question here\""
  echo ""
  echo "Example:"
  echo '  ./ask-governance.sh "What is the OIR framework?"'
  echo '  ./ask-governance.sh "Explain Evidence Ladder P0 P1 P2"'
  exit 1
fi

QUERY="$1"

# Create session token
echo "🔐 Creating session..."
SESSION_RESPONSE=$(curl -s -X POST http://localhost:3002/sessions \
  -H "Content-Type: application/json" \
  -d '{"modelId": "mcp2-local-test"}')

TOKEN=$(echo "$SESSION_RESPONSE" | jq -r '.sessionToken')

if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
  echo "❌ Failed to create session"
  echo "$SESSION_RESPONSE"
  exit 1
fi

echo "✅ Session: ${TOKEN:0:20}..."
echo ""
echo "🧠 Query: $QUERY"
echo ""

# Send query through gateway
RESPONSE=$(curl -s -X POST http://localhost:3002/v1/messages \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"zai.glm-5\",
    \"max_tokens\": 500,
    \"messages\": [
      {
        \"role\": \"user\",
        \"content\": \"$QUERY\"
      }
    ]
  }")

# Display response
echo "📝 Response:"
echo "$RESPONSE" | jq -r '.content[0].text'
echo ""

# Show metadata
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Stats:"
echo "   Model: $(echo "$RESPONSE" | jq -r '.model')"
echo "   Tokens: $(echo "$RESPONSE" | jq -r '.usage.output_tokens') generated"
echo "   Stop reason: $(echo "$RESPONSE" | jq -r '.stop_reason')"

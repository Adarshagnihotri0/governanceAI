#!/bin/bash

echo "================================"
echo "Gateway Connection Diagnostics"
echo "================================"
echo ""

echo "1️⃣ MCP 2.0 Server Status:"
echo "   Checking http://localhost:3001/v1/models..."
curl -s http://localhost:3001/v1/models 2>&1 | head -5
echo ""

echo ""
echo "2️⃣ Bhavishya Backend Status:"
echo "   Checking port 3002..."
BACKEND_PID=$(lsof -ti:3002 2>/dev/null)
if [ -n "$BACKEND_PID" ]; then
  echo "   ✅ Backend running (PID: $BACKEND_PID)"
else
  echo "   ❌ Backend NOT running"
fi
echo ""

echo "3️⃣ Database Connection:"
psql -d future_db -c "SELECT COUNT(*) as model_count FROM models;" 2>&1 | head -5
echo ""

echo "4️⃣ Session Token Creation:"
echo "   Creating token for mcp2-local-test..."
SESSION_RESPONSE=$(curl -s -X POST http://localhost:3002/sessions \
  -H "Content-Type: application/json" \
  -d '{"modelId": "mcp2-local-test"}' 2>&1)

if echo "$SESSION_RESPONSE" | grep -q "sessionToken"; then
  TOKEN=$(echo "$SESSION_RESPONSE" | jq -r '.sessionToken')
  echo "   ✅ Token created: ${TOKEN:0:20}..."
else
  echo "   ❌ Failed: $SESSION_RESPONSE"
fi
echo ""

echo "5️⃣ Gateway Test Query:"
if [ -n "$TOKEN" ]; then
  echo "   Testing governance query..."
  RESPONSE=$(curl -s -X POST http://localhost:3002/v1/messages \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
      "model": "zai.glm-5",
      "max_tokens": 150,
      "messages": [{"role": "user", "content": "What is OIR framework?"}]
    }' 2>&1)
  
  if echo "$RESPONSE" | grep -q "content"; then
    echo "   ✅ Gateway working!"
    echo "   Response preview:"
    echo "$RESPONSE" | jq -r '.content[0].text' | head -c 200
    echo "..."
  else
    echo "   ❌ Gateway error: $RESPONSE"
  fi
fi
echo ""

echo "6️⃣ Architecture Status:"
echo "   Configuration:"
echo "   - Backend:      http://localhost:3002"
echo "   - MCP 2.0:      http://localhost:3001/v1"
echo "   - MCP Model:    zai.glm-5"
echo "   - Database:     future_db"
echo ""

echo "================================"
echo "Diagnostics Complete"
echo "================================"

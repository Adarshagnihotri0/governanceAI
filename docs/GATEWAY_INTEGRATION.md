# testMCP2.0 + Bhavishya Gateway Integration

✅ **Successfully connected and tested!**

## What We Did

1. **Cloned engineering-governance** to testMCP2.0
2. **Built & linked** Bhavishya CLI globally
3. **Logged in** as publisher (Adarsh Agnihotri)
4. **Created session token** for gateway access
5. **Tested routing** through MCP 2.0 → AWS Bedrock GLM-5
6. **Implemented parallel proxy** for side-by-side LLM routing

## Architecture

### Standard Gateway Flow

```
testMCP2.0 (User)
     ↓
Bhavishya Gateway (localhost:3002)
     ↓ Session validation + protocol translation
MCP 2.0 Instance (localhost:3001/v1)
     ↓
AWS Bedrock GLM-5
```

### Parallel Proxy Flow (NEW)

```
User Request
     ↓
Bhavishya Gateway (localhost:3002)
     ↓ Classifies & routes in parallel
     ├─→ User's LLM Proxy (side-by-side)
     └─→ MCP 2.0 Server (localhost:3001)
         ↓
     AWS Bedrock GLM-5
         ↓
     Governance Enrichment
```

## How to Use

### Method 1: Standard Gateway (Recommended for most users)

```bash
# List models
future list

# Get model info (direct API)
curl -s http://localhost:3002/models | jq '.[] | select(.id == "mcp2-local-test")'

# Create new session token
curl -X POST http://localhost:3002/sessions \
  -H "Content-Type: application/json" \
  -d '{"modelId": "mcp2-local-test"}'
```

### Method 2: Parallel Proxy (NEW - Side-by-Side Routing)

```bash
# Create session
SESSION_TOKEN=$(curl -s -X POST http://localhost:3002/sessions \
  -H "Content-Type: application/json" \
  -d '{"modelId": "mcp2-local-test"}' \
  | jq -r '.sessionToken')

# Test parallel proxy (governance only)
curl -X POST http://localhost:3002/v1/parallel-proxy \
  -H "Authorization: Bearer $SESSION_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "zai.glm-5",
    "max_tokens": 300,
    "messages": [{"role": "user", "content": "What is OIR framework?"}]
  }'

# Test with user LLM proxy (side-by-side)
curl -X POST http://localhost:3002/v1/parallel-proxy \
  -H "Authorization: Bearer $SESSION_TOKEN" \
  -H "Content-Type: application/json" \
  -H "x-llm-proxy-url: https://api.openai.com/v1" \
  -H "x-llm-proxy-key: $YOUR_OPENAI_KEY" \
  -d '{
    "model": "zai.glm-5",
    "max_tokens": 300,
    "messages": [{"role": "user", "content": "Explain Evidence Ladder"}]
  }'
```

### Method 3: Test Script

```bash
./test-gateway-connection.sh
```

## Configuration Files

- `.env` - Gateway configuration and session token
- `test-gateway-connection.sh` - Automated test script

## Governance Queries

testMCP2.0 now has access to:
- **OIR Framework** (Observe-Interpret-Recommend)
- **Evidence Ladder** (P0→P1→P2 debugging)
- **Decision Cost Filter** (C0-C4)
- **Architecture patterns** and best practices

## Session Token Management

**Session tokens expire!** When you get a 401 error:

```bash
# Get new token
curl -X POST http://localhost:3002/sessions \
  -H "Content-Type: application/json" \
  -d '{"modelId": "mcp2-local-test"}' \
  | jq -r '.sessionToken'
```

Update `.env` with the new token.

## Next Steps

1. Integrate governance rules into your workflow
2. Test complex governance queries
3. Update `.github/copilot-instructions.md` as needed
4. Monitor gateway performance

## Status

- ✅ Engineering governance cloned
- ✅ Bhavishya gateway connected
- ✅ MCP 2.0 routing verified
- ✅ Session auth working
- ✅ Governance queries tested
- ✅ Parallel proxy endpoint implemented
- ✅ Side-by-side LLM routing working

## Documentation Files

- `GATEWAY_INTEGRATION.md` - This file (integration guide)
- `PARALLEL_PROXY_ARCHITECTURE.md` - Detailed parallel proxy documentation
- `.env` - Gateway configuration
- `test-gateway-connection.sh` - Automated connection tests
- `check-gateway-status.sh` - Diagnostic tool
- `ask-governance.sh` - Simple query interface
- `test-parallel-proxy.sh` - Parallel proxy test suite

# Parallel Proxy Architecture

## Overview

Bhavishya Gateway now supports **parallel proxy mode**, acting as a middleware layer that routes queries side-by-side:

```
User Request through LLM proxy
    ↓
Bhavishya Gateway (localhost:3002) ← Receives same query
    ↓ Classifies & routes in parallel
    ├─→ User's LLM Proxy (side-by-side)
    └─→ MCP 2.0 Server (localhost:3001)
        ↓
    AWS Bedrock GLM-5
        ↓
    Governance Enrichment
```

## Use Cases

### 1. Governance Enrichment (Side-by-Side)

Run governance checks alongside your normal LLM calls:

```bash
curl -X POST http://localhost:3002/v1/parallel-proxy \
  -H "Authorization: Bearer $SESSION_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "zai.glm-5",
    "max_tokens": 300,
    "messages": [{"role": "user", "content": "Your query"}]
  }'
```

**Response:**
```json
{
  "query": "Your query",
  "timestamp": "2026-06-22T08:57:11.726Z",
  "modelId": "mcp2-local-test",
  "llmProxy": {
    "success": true,
    "response": null
  },
  "governance": {
    "success": true,
    "response": {
      "id": "chatcmpl-...",
      "content": [...],
      "model": "zai.glm-5"
    }
  }
}
```

### 2. Dual LLM Comparison

Compare responses from two different LLM providers:

```bash
curl -X POST http://localhost:3002/v1/parallel-proxy \
  -H "Authorization: Bearer $SESSION_TOKEN" \
  -H "Content-Type: application/json" \
  -H "x-llm-proxy-url: https://api.openai.com/v1" \
  -H "x-llm-proxy-key: $YOUR_OPENAI_KEY" \
  -d '{
    "model": "zai.glm-5",
    "max_tokens": 300,
    "messages": [{"role": "user", "content": "Explain OIR framework"}]
  }'
```

**Response:**
```json
{
  "query": "Explain OIR framework",
  "llmProxy": {
    "success": true,
    "response": { /* OpenAI response */ }
  },
  "governance": {
    "success": true,
    "response": { /* MCP 2.0 governance response */ }
  }
}
```

## API Specification

### Endpoint: `POST /v1/parallel-proxy`

**Headers:**
- `Authorization: Bearer <session-token>` (required)
- `Content-Type: application/json` (required)
- `x-llm-proxy-url: <url>` (optional) - User's LLM proxy URL
- `x-llm-proxy-key: <api-key>` (optional) - User's LLM proxy API key

**Body:**
```json
{
  "model": "zai.glm-5",
  "max_tokens": 300,
  "messages": [
    {"role": "user", "content": "Your query"}
  ]
}
```

**Response:**
```json
{
  "query": "string",
  "timestamp": "ISO 8601",
  "modelId": "string",
  "llmProxy": {
    "success": boolean,
    "response": object | null,
    "error": "string" | null
  },
  "governance": {
    "success": boolean,
    "response": object,
    "error": "string" | null
  }
}
```

## Architecture Components

### 1. Gateway Controller (`gateway.controller.ts`)

**New Method: `parallelProxy()`**
- Receives incoming requests
- Extracts session token
- Validates credentials
- Routes to both paths in parallel using `Promise.allSettled()`
- Returns combined results

**Private Helpers:**
- `forwardToLLMProxy()` - Routes to user's LLM (if configured)
- `forwardToMCP2()` - Routes to MCP 2.0 governance path

### 2. Session Management

Sessions are shared across both paths:
- Single session token for both routes
- Model credentials from Bhavishya database
- Optional user LLM proxy credentials

### 3. Parallel Execution

Uses `Promise.allSettled()` for fault tolerance:
- If LLM proxy fails, governance path still succeeds
- If governance fails, LLM proxy still succeeds
- Both execute simultaneously

## Examples

### Example 1: Governance-Only Mode

```bash
./test-parallel-proxy.sh
```

Output:
- `llmProxy.response: null` (no user proxy configured)
- `governance.response: {...}` (MCP 2.0 result)

### Example 2: Dual-Path Mode

```bash
SESSION_TOKEN="your-token"
curl -X POST http://localhost:3002/v1/parallel-proxy \
  -H "Authorization: Bearer $SESSION_TOKEN" \
  -H "x-llm-proxy-url: https://api.anthropic.com/v1" \
  -H "x-llm-proxy-key: $ANTHROPIC_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "zai.glm-5",
    "max_tokens": 200,
    "messages": [{"role": "user", "content": "Test query"}]
  }'
```

### Example 3: Using with testMCP2.0

```bash
cd /Users/adarshagnihotri/Desktop/Projects/testMCP2.0
./test-parallel-proxy.sh
```

## Benefits

1. **Governance Integration**: Automatic governance checks on all queries
2. **Side-by-Side Comparison**: Compare multiple LLM responses
3. **Fault Tolerance**: One path failing doesn't block the other
4. **Zero Configuration**: Governance path works without additional setup
5. **Optional User Proxy**: Configure user LLM proxy when needed

## Use Case Scenarios

### Scenario 1: Development Governance

User submits query → Bhavishya adds governance context → Returns enriched response

### Scenario 2: A/B Testing

Send same query to OpenAI and MCP 2.0 → Compare responses → Choose best

### Scenario 3: Fallback Pattern

User LLM as primary → MCP 2.0 governance as backup → Never fail

### Scenario 4: Observability

User LLM for production → MCP 2.0 for monitoring → Full visibility

## Configuration

### testMCP2.0 Connection

```bash
# Create session
curl -X POST http://localhost:3002/sessions \
  -H "Content-Type: application/json" \
  -d '{"modelId": "mcp2-local-test"}'

# Use session for parallel proxy
SESSION_TOKEN="<token-from-above>"
curl -X POST http://localhost:3002/v1/parallel-proxy \
  -H "Authorization: Bearer $SESSION_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"model": "zai.glm-5", "max_tokens": 200, "messages": [...]}'
```

### Environment Variables

```bash
# In apps/backend/.env
GATEWAY_URL=http://localhost:3002
MODEL_ID=mcp2-local-test
MCP_BASE_URL=http://localhost:3001/v1
```

## Monitoring

### Logs

Gateway logs all parallel proxy requests:
```
[GatewayController] === PARALLEL PROXY REQUEST ===
[GatewayController] Routing query through gateway for model: mcp2-local-test
[GatewayController] === PARALLEL PROXY SUCCESS ===
```

### Metrics

Track:
- Request count per path
- Success rate (`llmProxy.success`, `governance.success`)
- Latency (parallel vs sequential)
- Error rates

## Future Enhancements

1. **Streaming**: Stream responses from both paths simultaneously
2. **Result Merging**: Combine responses intelligently
3. **Custom Routing**: Route based on query type
4. **Cost Tracking**: Track costs for both paths
5. **Quality Scoring**: Score and compare responses

## Testing

```bash
# Run test suite
cd /Users/adarshagnihotri/Desktop/Projects/testMCP2.0
./test-parallel-proxy.sh
```

Expected output:
- ✅ Session created
- ✅ Governance path succeeds
- ✅ LLM proxy configured (optional)
- ✅ Both responses returned

## Status

- ✅ Endpoint implemented: `/v1/parallel-proxy`
- ✅ Parallel execution working
- ✅ MCP 2.0 routing verified
- ✅ Fault tolerance confirmed
- ✅ Documentation complete

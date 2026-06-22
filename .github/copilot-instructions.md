# Bhavishya Engineering Constitution

Engineering governance layer for the Model Marketplace Gateway project.

## Quick Reference

**Governance Docs**: `.github/governance/`

**Key Workflows**:
- **Debugging**: Use Evidence Ladder (`.github/governance/constitution/evidence-ladder.md`)
- **Architecture**: Use OIR Framework (`.github/governance/constitution/oir-framework.md`)
- **Configuration**: Observe → Change → Verify (no deep reasoning needed)

---

## Project Context

### What is Bhavishya?

**Bhavishya** (Future) is a model marketplace CLI where:
- Publishers register OpenAI-compatible API endpoints
- Users discover available models
- Requests route through gateway with session-based auth

### Architecture Overview

```
User Request
     ↓
Bhavishya Gateway (localhost:3002)
     ↓ Session validation + translation
Publisher Endpoint (e.g., MCP 2.0)
     ↓ Model inference
Response back through gateway
```

### Key Components

**Backend** (`apps/backend/`):
- NestJS application
- PostgreSQL database (`future_db`)
- JWT-based publisher auth
- Session-based gateway auth

**Routes**:
- `POST /models` - Publisher registration
- `POST /sessions` - Create session tokens
- `POST /v1/messages` - Gateway proxy (Anthropic protocol)

**Key Services**:
- `RegistryService` - Model registration/validation
- `GatewayService` - Session validation/routing
- `EncryptionService` - AES-256-GCM for API keys

---

## Project-Specific Rules

### 1. Two Auth Systems

**Publisher Auth** (JWT):
- Used for `/models` routes
- Validated by `JwtAuthGuard`
- Token from `/auth/token`

**Gateway Auth** (Session):
- Used for `/v1/messages` route
- Validated by `GatewayService.useSession()`
- Token from `/sessions`

**Key Insight**: These are SEPARATE systems. Don't mix them.

---

### 2. API Key Encryption

**Never log or expose API keys**

API keys stored as:
```
encryptedApiKey = iv:authTag:encrypted (AES-256-GCM)
```

**Format**:
- IV: 16 bytes (hex)
- Auth Tag: 16 bytes (hex)
- Encrypted: variable (hex)

**Encryption key**: `ENCRYPTION_KEY` env var (64 hex chars)

---

### 3. Gateway Protocol Translation

**Request format**: Anthropic Messages API
**Publisher format**: OpenAI Chat Completions

**Translation** (`translation.ts`):
```
Anthropic "content" → OpenAI "messages[].content"
Anthropic "max_tokens" → OpenAI "max_tokens"
Anthropic "model" → Used for routing, not sent
```

---

### 4. Session Tokens

**Format**: base64url encoded random bytes
**Storage**: `sessions` table with expiration
**Validation**: `GatewayService.useSession()` → returns credentials

**Important**: Session tokens are NOT JWTs. Don't parse them as JWTs.

---

### 5. SSRF Protection

**Default**: Private IPs blocked (localhost, 10.x, 192.168.x, etc.)

**Development bypass**: `ALLOW_PRIVATE_URLS=true`

**Never disable in production**.

---

## Common Problem Patterns

### Pattern 1: Gateway 500 Error

**Likely causes**:
1. Global JWT guard interfering with session auth
2. Session token expired/invalid
3. Publisher endpoint unreachable
4. Protocol translation error

**Debugging approach**:
1. Check if request reaches controller (logs)
2. Check session validation (gateway.useSession)
3. Check publisher endpoint (fetch call)
4. Check translation logic (anthropicToOpenAI)

**Use**: Evidence Ladder (`.github/governance/constitution/evidence-ladder.md`)

---

### Pattern 2: API Key Validation

**Symptom**: "Invalid encrypted data format"

**Likely causes**:
1. Database has wrong format (not `iv:authTag:encrypted`)
2. Encryption key mismatch
3. Data corrupted

**Check**:
```sql
SELECT "encryptedApiKey" FROM models WHERE id = '...';
-- Should be: 32hex:32hex:variablehex
```

---

### Pattern 3: Publisher Registration

**Symptom**: 403 Forbidden

**Likely causes**:
1. Not authenticated (missing JWT)
2. JWT expired
3. Invalid publisher

**Check**:
1. Run `future login`
2. Check `/auth/me` endpoint
3. Verify JWT in Authorization header

---

## Governance Integration

### For Every Problem

1. **Classify**: Debugging/Architecture/Config/Research
2. **Apply**: Evidence Ladder/OIR/Observe→Change→Verify
3. **Track**: Calibration scores in `.github/governance/metrics/`

### For Debugging

**Mandatory**: Use `.github/governance/templates/debugging-report.md`

**Key invariant**: No "ROOT CAUSE" until P0-P2 obtained.

### For Architecture Decisions

**Mandatory**: Use `.github/governance/templates/oir-template.md`

**Decision Cost Filter**: Apply C0-C4 classification first.

### For Configuration

**Process**: Observe → Change → Verify

**No governance artifact needed** for C0 (trivial) changes.

---

## Environment Variables

**Required**:
```
DATABASE_URL="postgresql://..."
ENCRYPTION_KEY="64-hex-characters"
JWT_SECRET="your-jwt-secret"
```

**Optional**:
```
ALLOW_PRIVATE_URLS="true"  # Development only
PORT="3002"  # Default
GATEWAY_URL="http://localhost:3002"
```

---

## Testing

### Integration Test

```bash
# 1. Create session
curl -X POST http://localhost:3002/sessions \
  -H "Content-Type: application/json" \
  -d '{"modelId": "test-model"}'

# 2. Use session token
curl -X POST http://localhost:3002/v1/messages \
  -H "Authorization: Bearer <session_token>" \
  -H "Content-Type: application/json" \
  -d '{"model": "...", "messages": [...], "max_tokens": 10}'
```

### Health Check

```bash
curl http://localhost:3002/auth/me  # Check publisher auth
curl http://localhost:3002/models   # List models
```

---

## Architecture Decisions

### ADR-001: Session-based Gateway Auth

**Decision**: Use session tokens (not JWT) for gateway routes

**Rationale**: 
- Gateway users may not have accounts
- Sessions provide scoped, expiring access
- Separate from publisher auth system

**Implications**: Two auth systems, carefully separated

---

### ADR-002: Gateway Protocol

**Decision**: Gateway speaks Anthropic, publishers speak OpenAI

**Rationale**:
- Anthropic protocol gaining adoption
- Most model servers support OpenAI
- Translation is straightforward

**Implications**: Translation layer required

---

### ADR-003: SSRF Protection

**Decision**: Block private IPs by default, dev bypass available

**Rationale**: Security first, but need local testing

**Implications**: Use `ALLOW_PRIVATE_URLS=true` for dev only

---

## Key Takeaways

1. **Two auth systems**: Don't mix JWT and session auth
2. **Gateway does translation**: Anthropic ↔ OpenAI
3. **API keys encrypted**: Never log them
4. **SSRF protection**: Development bypass available
5. **Use governance**: Classify problems, apply methodology

---

## Governance Links

**Constitution**: `.github/governance/constitution/`  
**Templates**: `.github/governance/templates/`  
**Examples**: `.github/governance/examples/`  
**Metrics**: `.github/governance/metrics/`

**Start here**: `.github/governance/README.md`

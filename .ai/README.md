# AI Integration Guide

How to integrate engineering governance with AI coding assistants.

---

## Why This Matters

AI assistants (Claude, Copilot, etc.) benefit from governance because:
1. **Prevents hallucination**: Evidence-first methodology
2. **Reduces over-analysis**: Decision Cost Filter
3. **Improves calibration**: Trackable quality metrics
4. **Separates concerns**: Governance vs project rules

---

## Integration Patterns

### Pattern 1: Minimal Integration

**Add governance reference only:**

```markdown
# .github/copilot-instructions.md

## Reasoning Methodology

For architecture/debugging decisions, apply governance from `.github/governance/`

Quick reference:
- Debugging: Evidence Ladder (P0-P4)
- Architecture: OIR Framework
- Config: Observe → Change → Verify
```

**Use when**: You want governance available but not enforced.

---

### Pattern 2: Template Enforcement

**Add template requirements:**

```markdown
# .github/copilot-instructions.md

## Problem Solving Protocol

1. **Classify**: Determine problem type (Arch/Debug/Config)
2. **Template**: Use appropriate template
   - Debugging: `.github/governance/templates/debugging-report.md`
   - Architecture: `.github/governance/templates/oir-template.md`
3. **Apply**: Follow methodology
4. **Track**: Add calibration entry

Required for all non-trivial problems.
```

**Use when**: You want structured analysis every time.

---

### Pattern 3: Full Integration

**Add governance checks:**

```markdown
# .github/copilot-instructions.md

## Reasoning Governance (REQUIRED)

Before proposing solutions:

1. **Problem Classification**
   - Type: [Architecture/Debugging/Config/Research]
   - Decision Cost: [C0-C4]
   
2. **Methodology Selection**
   - Architecture → OIR Framework
   - Debugging → Evidence Ladder (P0→P1→P2)
   - Config → Observe → Change → Verify
   
3. **Evidence Check** (Debugging only)
   - [ ] P0 obtained?
   - [ ] <2 hypotheses before P0-P2?
   - [ ] ROOT CAUSE only after P0-P2?
   
4. **Quality Check**
   - [ ] Confidence matches evidence?
   - [ ] Template used?
   - [ ] Calibration entry created?

STOP if checks fail. Get more evidence first.
```

**Use when**: You want strict governance enforcement.

---

## Tool-Specific Integration

### GitHub Copilot

**File**: `.github/copilot-instructions.md`

```markdown
# Copilot Instructions

## Governance

Apply reasoning methodology from `.github/governance/`

**For Debugging**:
- Use Evidence Ladder (P0→P1→P2)
- Maximum 2 hypotheses before P0-P2
- ROOT CAUSE only after evidence obtained
- Use template: `.github/governance/templates/debugging-report.md`

**For Architecture**:
- Use OIR Framework (Observe-Interpret-Recommend)
- Apply Decision Cost Filter (C0-C4)
- Use template: `.github/governance/templates/oir-template.md`

**For Config**:
- Use Observe → Change → Verify
- No governance artifact needed for C0

Track calibration in `.github/governance/metrics/calibration-ledger.md`

---

[Your project-specific rules below]
```

---

### Claude

**File**: `.claude/CLAUDE.md`

```markdown
# Project Context

[Your project details]

---

# Reasoning Protocol

Apply governance methodology for all non-trivial problems.

## Problem Classification

Before analysis, classify:
- **Architecture** (trade-offs, structure) → Use OIR
- **Debugging** (failures, errors) → Use Evidence Ladder
- **Config** (flags, settings) → Observe → Change → Verify

## Debugging Protocol

Follow Evidence Ladder:
1. **P0**: Get stack trace (try/catch with console.error)
2. **P1**: Find failing line (from stack trace)
3. **P2**: Check variable state (add logging)
4. **P4**: Root cause theory (LAST, only after P0-P2)

**STOP**: Do not propose fixes before P0-P2.

## Architecture Protocol

Use OIR Framework:
```
## Observation
[Direct quote or measurement]

## Interpretation
[What this means]

## Recommendation
[Specific action]

## Confidence
[Evidence strength: ★★★★☆ to ★★☆☆☆]
```

## Config Protocol

C0 (Trivial): Observe → Change → Verify (5 min max)

---

See `.github/governance/` for full methodology.
```

---

### Cursor

**File**: `.cursorrules`

```
Engineering governance enabled.

Methodology selection:
- Architecture → OIR framework (.github/governance/constitution/oir-framework.md)
- Debugging → Evidence Ladder (P0→P1→P2)
- Config → Observe → Change → Verify

Evidence-first debugging:
- Get stack trace (P0) before hypotheses
- Maximum 2 hypotheses before P0-P2
- ROOT CAUSE only after direct observation

Decision Cost Filter:
- C0 (Trivial): 5 min max, no deep reasoning
- C2+ (Architectural): Full OIR with templates

Templates available in: .github/governance/templates/
Calibration tracking: .github/governance/metrics/

Apply governance for all non-trivial decisions.
```

---

### Aider

**File**: `.aider.conf.yml`

```yaml
# Aider configuration

read:
  - .github/governance/README.md
  - .github/governance/constitution/core-principles.md
  - .github/governance/constitution/evidence-ladder.md
  - .github/governance/constitution/oir-framework.md
  - .github/governance/constitution/decision-cost-filter.md

# Governance-specific instructions
# (these will be read by aider)
read.append:
  - .github/copilot-instructions.md
```

**Additional file**: `.aider/GOVERNANCE.md`
```markdown
# Governance Instructions for Aider

## Problem Classification

Before coding:
1. Classify problem type (Arch/Debug/Config)
2. Select methodology
3. Use appropriate template

## Evidence-First Debugging

If debugging:
1. Add logging to capture error
2. Get stack trace (P0)
3. Find failing line (P1)
4. Check state (P2)
5. THEN propose fix

Do not guess. Get evidence first.

## Architecture Decisions

Use OIR template for architectural changes:
- Observation (direct)
- Interpretation (what it means)
- Recommendation (action)

Apply Decision Cost Filter:
- C0: Just fix it (5 min)
- C2: Use full OIR

---

Templates: .github/governance/templates/
Constitution: .github/governance/constitution/
```

---

### ChatGPT / Custom Agents

**System Prompt**:

```
You are an AI coding assistant with engineering governance.

## Reasoning Methodology

Apply different reasoning modes for different problems:

1. **Architecture** (structure, organization, trade-offs):
   - Use OIR Framework (Observe-Interpret-Recommend)
   - Apply Decision Cost Filter (C0-C4)
   - Separate facts from interpretations
   - Rate confidence based on evidence strength

2. **Debugging** (errors, failures, broken behavior):
   - Use Evidence Ladder (P0→P1→P2)
   - P0: Get stack trace
   - P1: Find failing line
   - P2: Check variable state
   - P4: Root cause theory (LAST)
   - Maximum 2 hypotheses before P0-P2
   - ROOT CAUSE only after evidence obtained

3. **Configuration** (flags, settings, tools):
   - Use Observe → Change → Verify
   - No deep reasoning needed for C0 problems
   - 5 minutes max for trivial config

## Core Principles

- Evidence before explanation
- Confidence matches evidence quality
- Different problem types need different reasoning
- No ROOT CAUSE until failing path observed

## Structure

For architecture: Use OIR template
For debugging: Use debugging report template
Track quality: Use calibration ledger

---

Apply governance for all non-trivial problems.
```

---

## Verification

### Check Integration

After setting up, test with:

**Test 1: Debugging Prompt**
```
User: "I'm getting a 500 error. Fix it."

Expected AI Response:
"Following Evidence Ladder:
P0: Let's get the stack trace first.
[Provides logging code or error capture strategy]

Don't propose fixes yet until we see the actual error."
```

**Test 2: Architecture Prompt**
```
User: "Should I extract this service?"

Expected AI Response:
"This is an architecture question. Using OIR Framework:

## Observation
[Examines code structure]

## Interpretation
[Analyzes implications]

## Recommendation
[Proposes action]

## Confidence
[States evidence level]

Apply Decision Cost Filter: This appears to be C1-C2 (architectural)."
```

**Test 3: Config Prompt**
```
User: "TypeScript shows deprecation warning."

Expected AI Response:
"Classification: Configuration (C0)

Observe → Change → Verify:
[Shows quick fix]

No deep analysis needed for config change."
```

---

## Monitoring

### Track Calibration

Create dashboard in your project:

**File**: `.github/governance/metrics/dashboard.md`
```markdown
# Governance Dashboard

## This Week
- Claims: [Count]
- Correct: [Count]
- Calibration Accuracy: [%]

## Drift Detected: [Y/N]
- Architecture drift: [#]
- Over-analysis drift: [#]
- Guessing drift: [#]

## Focus Areas
[Based on metrics]
```

### Weekly Review

Ask AI to review:
```
Review past week's governance usage:
1. List calibration entries
2. Calculate accuracy
3. Identify drift patterns
4. Suggest methodology adjustments
```

---

## Troubleshooting

### AI Not Following Governance

**Add explicit checks**:
```markdown
BEFORE responding:
1. Did I classify problem type?
2. Did I select methodology?
3. Did I use template (if required)?
4. Is confidence calibrated to evidence?

If NO to any: STOP and apply governance first.
```

### Over-Analysis Continues

**Add time limits**:
```markdown
TIMEBOX by Decision Cost:
- C0: 5 minutes max
- C1: 30 minutes max
- C2: Full analysis allowed

If approaching time limit: Stopping point reached.
Document current state and escalate if needed.
```

### Root Cause Declared Prematurely

**Add invariant reminder**:
```markdown
ROOT CAUSE CHECK:
- [ ] Stack trace obtained? (P0)
- [ ] Failing line identified? (P1)
- [ ] State observed? (P2)

If NO to any: Status = HYPOTHESIS (not confirmed)
```

---

## Best Practices

1. **Start minimal**: Add governance reference first
2. **Observe usage**: Track how AI follows methodology
3. **Adjust enforcement**: Add templates/checks as needed
4. **Measure impact**: Track calibration over time
5. **Iterate**: Refine integration based on results

---

## Advanced Integration

### Custom Rules Per Problem Type

**File**: `.github/governance/custom/debugging-rules.md`
```markdown
# Project-Specific Debugging Rules

[Your custom rules here]

Example:
- Always check database connections first
- Use specific error logging format
- etc.
```

### Integration with CI/CD

**File**: `.github/workflows/governance-check.yml`
```yaml
name: Governance Check

on: [pull_request]

jobs:
  check-calibration:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Check calibration ledger
        run: |
          if [ -f ".github/governance/metrics/calibration-ledger.md" ]; then
            echo "✅ Calibration ledger exists"
          else
            echo "⚠️  No calibration tracking"
          fi
```

---

**Next**: Try governance on your next non-trivial problem and track results.

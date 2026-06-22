# Installation Guide

## Quick Install

### Method 1: Direct Copy

```bash
# Navigate to your project
cd your-project

# Clone governance framework
git clone https://github.com/YOUR_USERNAME/engineering-governance.git /tmp/gov

# Copy governance files
cp -r /tmp/gov/.github .

# Clean up
rm -rf /tmp/gov

# Commit
git add .github
git commit -m "Add engineering governance framework"
```

---

### Method 2: Git Subtree (Recommended)

```bash
# Add governance as subtree
git subtree add --prefix=.github \
  https://github.com/YOUR_USERNAME/engineering-governance.git main \
  -m "Add engineering governance framework"

# Update later
git subtree pull --prefix=.github \
  https://github.com/YOUR_USERNAME/engineering-governance.git main
```

**Advantages**:
- Easy updates
- Track governance changes
- Merge improvements from upstream

---

### Method 3: npm Package (Coming Soon)

```bash
npm install -g engineering-governance

# Initialize in project
cd your-project
governance init
```

---

## Post-Installation

### 1. Customize Project Rules

Edit `.github/copilot-instructions.md`:
```markdown
# Project-Specific Rules

[Your project context here]

## Governance
See `.github/governance/README.md` for reasoning methodology.
```

### 2. Initialize Calibration Ledger

Create `.github/governance/metrics/calibration-ledger-active.md`:
```markdown
# Calibration Ledger - [Project Name]

## Active Claims
[Empty initially]

## Metrics
Total Claims: 0
Calibration Accuracy: N/A
```

### 3. Start Using Templates

For your next problem:
- **Debugging**: Copy `.github/governance/templates/debugging-report.md`
- **Architecture**: Copy `.github/governance/templates/oir-template.md`
- **Review**: Use `.github/governance/templates/architecture-review.md`

---

## Verification

Check installation:
```bash
ls -la .github/governance
```

Should see:
```
constitution/
templates/
examples/
metrics/
README.md
INSTALLATION.md
```

---

## Customization

### Option 1: Use As-Is

Framework is ready to use. No customization needed.

### Option 2: Add Project-Specific Rules

Create `.github/PROJECT-RULES.md`:
```markdown
# Project-Specific Engineering Rules

[Your rules here]

## Governance
See `.github/governance/` for reasoning methodology.
```

### Option 3: Extend Constitution

Add project-specific principles in `.github/governance/constitution/`:
- `project-specific.md` - Rules unique to your project
- `architecture-constraints.md` - Project architecture boundaries
- `tech-debt-policy.md` - How to handle technical debt

---

## Integration with AI Assistants

### GitHub Copilot

**Already integrated**: `.github/copilot-instructions.md` includes governance reference.

### Claude

Create `.claude/CLAUDE.md`:
```markdown
# Project Rules

[Your context]

## Reasoning Methodology
See `.github/governance/README.md` for problem-solving approach.

Apply governance for:
- Architecture decisions: Use OIR framework
- Debugging: Use Evidence Ladder
- Configuration: Use Observe → Change → Verify
```

### Cursor

Create `.cursorrules`:
```
Use engineering governance from .github/governance/

For architecture: Use OIR framework
For debugging: Use Evidence Ladder (P0-P4)
For config: Use Observe → Change → Verify

Track calibration in governance metrics.
```

### Aider

Create `.aider.conf.yml`:
```yaml
read:
  - .github/governance/README.md
  - .github/governance/constitution/core-principles.md
```

---

## Updating

### Subtree Method
```bash
git subtree pull --prefix=.github \
  https://github.com/YOUR_USERNAME/engineering-governance.git main
```

### Direct Copy Method
```bash
# Backup current governance
cp -r .github/governance /tmp/gov-backup

# Pull latest
git clone https://github.com/YOUR_USERNAME/engineering-governance.git /tmp/gov-new

# Update (preserve calibration data)
cp -r /tmp/gov-new/.github/governance/constitution .github/governance/
cp -r /tmp/gov-new/.github/governance/templates .github/governance/
cp -r /tmp/gov-new/.github/governance/examples .github/governance/
# Keep your metrics/

# Clean up
rm -rf /tmp/gov-new /tmp/gov-backup
```

---

## First-Time Setup

### Week 1: Learning
1. Read all constitution files
2. Review examples
3. Try templates on small problems
4. Track calibration loosely

### Week 2: Application
1. Use templates for every problem
2. Create calibration ledger entries
3. Identify drift patterns
4. Adjust confidence levels

### Week 3: Calibration
1. Review calibration metrics
2. Identify systematic issues
3. Add project-specific rules if needed
4. Weekly governance review

### Week 4+: Refinement
1. Track governance ROI
2. Measure calibration accuracy
3. Contribute improvements upstream
4. Share learnings

---

## Troubleshooting

### Problem: Governance ignored by AI

**Solution**: Explicitly reference in instructions:
```markdown
IMPORTANT: Follow governance methodology from .github/governance/

For debugging: Use Evidence Ladder (P0→P1→P2)
Do not declare ROOT CAUSE until P0-P2 obtained.
```

### Problem: Over-analysis continues

**Solution**: Apply Decision Cost Filter explicitly:
```markdown
Before analyzing: Classify as C0-C4

C0 (Trivial): Observe → Change → Verify (5 min max)
C1 (Tactical): Light OIR (30 min max)
C2+ (Architectural): Full OIR with templates
```

### Problem: Templates not used

**Solution**: Create shortcuts:
```bash
# Add to your shell aliases
alias debug="cp .github/governance/templates/debugging-report.md ."
alias arch="cp .github/governance/templates/oir-template.md ."
alias review="cp .github/governance/templates/architecture-review.md ."
```

---

## Support

### Documentation
- **Overview**: `.github/governance/README.md`
- **Constitution**: `.github/governance/constitution/`
- **Templates**: `.github/governance/templates/`
- **Examples**: `.github/governance/examples/`

### Issues
File issues in the governance repository:
https://github.com/YOUR_USERNAME/engineering-governance/issues

### Contributing
See CONTRIBUTING.md for how to propose improvements.

---

**Next Steps**: Start with `.github/governance/README.md`

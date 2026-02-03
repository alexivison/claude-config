---
name: context-loader
description: ALWAYS activate at task start. Load project context from .claude/ or current directory if already in config.
---

# Context Loader Skill

## Purpose

Load shared project context to ensure Codex CLI has the same knowledge as Claude Code.

## When to Activate

**ALWAYS** - This skill runs at the beginning of every task.

## CRITICAL: Execute These Commands

You MUST execute the following commands at the start of every task. These are not optional documentation - you must actually run these shell commands to load the guidelines.

### Step 1: Detect Config Root

```bash
# Run this to find where config files are
if [ -d "$HOME/.claude" ]; then
  CONFIG_ROOT="$HOME/.claude"
  echo "[context-loader] Using config: $CONFIG_ROOT"
elif [ -d ".claude" ]; then
  CONFIG_ROOT=".claude"
  echo "[context-loader] Using config: $CONFIG_ROOT"
else
  echo "[context-loader] WARNING: No config found"
  CONFIG_ROOT=""
fi
```

### Step 2: Load Review Guidelines (MANDATORY for review tasks)

**For code review tasks**, you MUST read this file before reviewing:

```bash
cat "$HOME/.codex/skills/code-review/reference/general.md"
```

This file contains critical rules including:
- `[must] Tests missing for new code` — BLOCKS approval
- Maintainability thresholds
- Severity labels

**For architecture review tasks**:

```bash
cat "$HOME/.codex/skills/architecture-review/reference/architecture-guidelines-common.md"
```

**For plan review tasks**:

```bash
cat "$HOME/.codex/skills/plan-review/reference/plan-review-guidelines.md"
```

### Step 3: Output Loading Confirmation

After loading guidelines, output this confirmation:

```
[context-loader] Guidelines loaded:
  ✓ code-review/reference/general.md
```

If you do NOT output this confirmation, the review is invalid.

## Code Review: Mandatory Checks

Before returning APPROVE, you MUST verify ALL of the following:

### Test Coverage Check (BLOCKING)

```
□ Does the PR add new code (components, functions, hooks)?
□ If yes, are there corresponding test files?
□ If no tests exist for new code → [must] Tests missing for new code
```

**This check is MANDATORY.** A PR that adds new code without tests CANNOT receive APPROVE.

### Quality Checks

| Check | Severity if violated |
|-------|---------------------|
| Tests missing for new code | `[must]` — BLOCKS |
| Tests missing for bug fix | `[must]` — BLOCKS |
| Function >50 lines | `[must]` — BLOCKS |
| Nesting depth >4 | `[must]` — BLOCKS |
| Duplicate code >10 lines | `[must]` — BLOCKS |

## Iteration Protocol

**Parse iteration parameters from prompt:**
- Look for `Iteration: N` in prompt
- Look for `Previous feedback:` section

**Behavior by iteration:**

| Iteration | Scope |
|-----------|-------|
| 1 | Full review, report all [must]/[q]/[nit] |
| 2 | Verify fixes from iteration 1, check for regressions |
| 3 | Final pass, no new [nit], [must] still blocks |
| >3 | Return NEEDS_DISCUSSION |

On iteration 2+:
1. Check each item from previous feedback
2. Mark as fixed or still present
3. Note any regressions introduced by fixes
4. Only report NEW [must] issues found

## Output Format

Return structured output with verdict at top:

```markdown
## Code Review (Codex)

**Verdict**: **APPROVE** | **REQUEST_CHANGES** | **NEEDS_DISCUSSION**
**Iteration**: {N}
**Guidelines loaded**: ✓ general.md

### Test Coverage
- New code files: {list}
- Test files: {list}
- Coverage: ✓ Complete | ✗ Missing tests for {files}

### Summary
{1-2 sentences}

### Issues Found
{[must]/[q]/[nit] items}
```

## Verdict Rules

| Condition | Verdict |
|-----------|---------|
| No `[must]`, no unanswered `[q]`, tests present | **APPROVE** |
| Has `[must]` OR missing tests for new code | **REQUEST_CHANGES** |
| Unanswered `[q]` | **REQUEST_CHANGES** |
| Architectural concerns, unclear requirements | **NEEDS_DISCUSSION** |

**CRITICAL:** New code without tests = automatic `[must]` = cannot APPROVE.

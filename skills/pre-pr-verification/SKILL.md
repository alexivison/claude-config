---
name: pre-pr-verification
description: Run full verification before creating PR. Enforces evidence-based completion. Use before any PR creation or when asked to verify changes.
user-invocable: true
allowed-tools: Bash
---

# Pre-PR Verification

Run all checks locally before creating a PR. No PR without passing verification.

## Core Principle

**"Evidence before PR, always."** — If you haven't run verification fresh and seen it pass, you cannot create a PR.

## Process

### Step 1: Identify Verification Commands

Check project's package.json or CI config for the exact commands. Common patterns:

| Check | Common Commands |
|-------|-----------------|
| Types | `pnpm typecheck`, `tsc --noEmit` |
| Lint | `pnpm lint`, `eslint src` |
| Tests | `pnpm test`, `vitest` |

### Step 2: Run All Checks

Run checks **sequentially in main context** so failures are immediately visible:

```bash
pnpm typecheck && pnpm lint && pnpm test
```

**Why not sub-agents?** Sub-agents return summaries, not full output. When a test fails with a cryptic error, you need the details to debug — not a one-liner.

### Step 3: Handle Failures

**If checks fail on NEW code you wrote:**
1. Fix the issue
2. Re-run ALL checks (not just the failing one)
3. Repeat until all pass

**If checks fail on UNRELATED code:**
1. Don't rationalize "it's not my change"
2. Either fix it (if simple) or ask user how to proceed
3. Never ship a PR with known failures

**If a test is flaky** (passes/fails randomly):
1. A flaky test is a broken test — don't ignore it
2. If you can't fix it: file an issue, skip the test explicitly with a comment, document in PR
3. Never ship with unskipped flaky tests

### Step 4: Capture Evidence

After all checks pass, capture the output for the PR description:

```markdown
## Verification

| Check | Result |
|-------|--------|
| Typecheck | ✓ No errors |
| Lint | ✓ No errors (X warnings) |
| Tests | ✓ X passed, 0 failed |

Run at: [timestamp]
```

Include this in the PR description so reviewers know verification was done.

## Red Flags — STOP

If you catch yourself thinking:
- "Should pass" (without fresh evidence)
- "I'll fix that after the PR"
- "That failure is unrelated"
- "It's a small change, no need to verify"

**STOP.** Run verification. Show evidence.

## Only After Passing

Create PR: `gh pr create --draft`

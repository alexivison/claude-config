---
name: task-workflow
description: Execute a task from TASK*.md with full workflow. Auto-invoked when implementing planned tasks.
user-invocable: false
---

# Task Workflow

Execute tasks from TASK*.md files with the full autonomous workflow.

## Pre-Implementation Gate

**STOP. Before writing ANY code:**

1. **Create worktree first** — `git worktree add ../repo-branch-name -b branch-name`
2. **Does task require tests?** → invoke `/write-tests` FIRST
3. **Requirements unclear?** → `/brainstorm` or ask user
4. **Will this bloat into a large PR?** → Split into smaller tasks

State which items were checked before proceeding.

## Execution Flow

After passing the gate, execute continuously — **no stopping until PR is created**.

```
/write-tests (if needed) → implement → checkboxes → code-critic → architecture-critic → verification → commit → PR
```

### Step-by-Step

1. **Tests** — If task needs tests, invoke `/write-tests` first (RED phase)
2. **Implement** — Write the code to make tests pass (GREEN phase)
3. **Checkboxes** — Update both TASK*.md and PLAN.md: `- [ ]` → `- [x]`
4. **code-critic** — MANDATORY after implementing. Fix issues until APPROVE
5. **architecture-critic** — Run after code-critic passes
6. **Verification** — Run test-runner + check-runner + security-scanner (parallel)
7. **PR Verification** — Invoke `/pre-pr-verification`
8. **Commit & PR** — Create commit and draft PR

## Checkpoint Updates

After completing implementation, update checkboxes:
- In TASK*.md file (the specific task)
- In PLAN.md (the overall progress tracker)

Commit checkbox updates WITH implementation, not separately.

## Core Reference

See [execution-core.md](/Users/aleksituominen/.claude/rules/execution-core.md) for:
- Decision matrix (when to continue vs pause)
- Sub-agent behavior rules
- Verification requirements
- PR gate requirements

---
name: context-loader
description: ALWAYS activate at task start. Load project context from .claude/ or current directory if already in config.
---

# Context Loader Skill

## Purpose

Load shared project context to ensure Codex CLI has the same knowledge as Claude Code.

## When to Activate

**ALWAYS** - This skill runs at the beginning of every task.

## Path Detection

First, determine where config files are:

```bash
# Check if we're already in ~/.claude or similar config directory
if [ -f "CLAUDE.md" ] && [ -d "rules" ] && [ -d "agents" ]; then
  # Already in config directory - use current paths
  CONFIG_ROOT="."
elif [ -d ".claude" ]; then
  # Project with .claude subdirectory
  CONFIG_ROOT=".claude"
elif [ -d "$HOME/.claude" ]; then
  # Fall back to global config
  CONFIG_ROOT="$HOME/.claude"
else
  # No config found
  CONFIG_ROOT=""
fi
```

## Workflow

### Step 1: Load Development Rules

Read key files from `${CONFIG_ROOT}/rules/`:

```
rules/
├── development.md       # Git, PRs, task management
├── execution-core.md    # Workflow sequence, verdicts
├── autonomous-flow.md   # Continuous execution rules
```

### Step 2: Load Agent Definition

For review tasks, read cli-orchestrator which handles all review types:

```
agents/
├── cli-orchestrator.md  # Unified: code review, arch, debug, plan review
```

### Step 3: Load CLAUDE.md

Read the main instructions file:
```
CLAUDE.md                # Core guidelines and workflow selection
```

### Step 4: Execute Task

With loaded context, execute the requested task following:
- Development rules from rules/
- Workflow patterns from CLAUDE.md
- Standard verdict format

## Key Rules to Remember

After loading, follow these principles:

1. **Standard verdicts** - APPROVE, REQUEST_CHANGES, NEEDS_DISCUSSION, SKIP
2. **Verdict FIRST** - Always put verdict at the top of output (within first 500 chars)
3. **File:line references** - Always be specific
4. **Structured output** - Use headers like "## Code Review (Codex)" for detection
5. **Read-only by default** - Don't modify files unless explicitly requested

## Output Format

Return structured output with verdict at top:

```markdown
## {Task Type} (Codex)

**Verdict**: **APPROVE** | **REQUEST_CHANGES** | **NEEDS_DISCUSSION**

### Summary
{1-2 sentences}

### {Details section}
...
```

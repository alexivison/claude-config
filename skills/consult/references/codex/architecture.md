# Architecture Review (Codex)

**Trigger:** "architecture", "arch", "structure", "complexity"

## Guidelines

Load architecture guidelines before running Codex:
- `~/.claude/skills/architecture-review/reference/architecture-guidelines-common.md` — Universal principles, thresholds
- `~/.claude/skills/architecture-review/reference/architecture-guidelines-frontend.md` — React/TypeScript (if applicable)
- `~/.claude/skills/architecture-review/reference/architecture-guidelines-backend.md` — Go/Python/Node (if applicable)

**Path handling:** If prompt includes a path, cd there first for all git/codex commands.

## Step 1: Early Exit Check

```bash
cd /path/to/worktree && git diff --stat HEAD~1 | tail -1  # If <50 lines total → SKIP
```

## Step 2: Identify Related Files

Don't just review changed files. Find:
- Files that import/are imported by changed files
- Files in same module/package
- Interface definitions the changed code implements

```bash
cd /path/to/worktree && grep -h "import\|require\|from" $(git diff --name-only HEAD~1) | sort -u
```

## Step 3: Run Comprehensive Review

```bash
cd /path/to/worktree && codex exec -s read-only "
Architecture review with regression detection.

Changed files: $(git diff --name-only HEAD~1 | tr '\n' ' ')

Review scope (see guidelines for thresholds):
1. METRICS - Cyclomatic complexity, function length, file length, nesting depth
2. REGRESSION CHECK - Compare before/after, flag degradations as [must]
3. CODE SMELLS - God class, Long function, Deep nesting, Feature envy
4. STRUCTURAL - SRP violations, layer violations
5. CONTEXT FIT - Do changes integrate well with surrounding code?

Use [must], [q], [nit] severity labels per guidelines.
"
```

## Output Format (VERDICT FIRST for marker detection)

```markdown
## Architecture Review (Codex)

**Verdict**: **SKIP** | **APPROVE** | **REQUEST_CHANGES** | **NEEDS_DISCUSSION**
**Mode**: Quick scan | Deep review
**Files reviewed**: {N changed} + {M related}

### Metrics Delta
| File:Function | Metric | Before | After | Status |
|---------------|--------|--------|-------|--------|

### Regression Check
{None detected | List regressions with [must] label}

### Code Smells
{None detected | List with severity}

### Structural Issues
{None detected | List SRP/layer violations}

### Context Fit
{How changes integrate with surrounding code}
```

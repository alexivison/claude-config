# Sub-Agents

Sub-agents preserve context by offloading investigation/verification tasks.

## cli-orchestrator
**Use when:** Deep reasoning, code review, debugging, architecture analysis, or research via external CLI tools (Codex, Gemini).

**Routes to appropriate CLI based on prompt:**
- "review", "design", "debug", "investigate", "architecture" → **Codex CLI** (reasoning)
- "research", "codebase", "PDF", "library" → **Gemini CLI** (research/multimodal)

**Modes:**
| Mode | Trigger | Codex Command |
|------|---------|---------------|
| Code Review | "review" | `codex review --uncommitted` |
| Architecture | "arch", "structure" | `codex exec -s read-only "Analyze architecture..."` |
| Debug Investigation | "debug", "investigate", "bug" | `codex exec -s read-only "Investigate bug..."` |
| Design Decision | "design", "compare" | `codex exec -s read-only "Analyze trade-offs..."` |
| Research | "research" | `gemini -p "Research..."` |
| Codebase Analysis | "codebase", "overview" | `gemini -p "Analyze repository..."` |

**Returns:** Verdict or findings with structured analysis. Verdict always at top for marker detection.

**Creates markers (Codex tasks only):**
- Code Review + APPROVE → `/tmp/claude-code-critic-{session}`
- Architecture + any → `/tmp/claude-architecture-reviewed-{session}`

**Note:** Uses Sonnet. Keeps verbose CLI output isolated. Extensible to other CLIs.

## test-runner
**Use when:** Running test suites that produce verbose output.

**Returns:** Brief summary with pass/fail count and failure details only.

**Note:** Uses Haiku. Isolates verbose test output from main context.

## check-runner
**Use when:** Running typechecks or linting.

**Returns:** Brief summary with error/warning counts and issue details only.

**Note:** Uses Haiku. Auto-detects project stack and package manager.

## log-analyzer
**Use when:** Analyzing application/server logs.

**Writes to:** `~/.claude/logs/{identifier}.md`

**Returns:** Brief summary with file path, error/warning counts, timeline.

**Note:** Uses Haiku. Handles JSON, syslog, Apache/Nginx, plain text.

## security-scanner
**Use when:** Before commits/PRs, auditing security posture, or after dependency updates.

**Checks:** Secrets detection, dependency vulnerabilities, OWASP Top 10 patterns, config issues.

**Returns:** Structured findings with severity (CRITICAL/HIGH/MEDIUM/LOW), exact locations, and remediation.

**Note:** Uses Haiku. Runs available tools (npm audit, pip-audit, etc.) and grep patterns.

## plan-reviewer
**Use when:** After creating planning documents (SPEC.md, DESIGN.md, PLAN.md, TASK*.md).

**Pattern:** Single-pass review. Main agent controls iteration loop (create → review → fix → review → ... → APPROVED).

**Returns:** Verdict (APPROVE | REQUEST_CHANGES | NEEDS_DISCUSSION) with `[must]`/`[q]`/`[nit]` feedback.

**Escalates to user:** Only on NEEDS_DISCUSSION or after 3 failed iterations.

**Note:** Uses Sonnet. Preloads `/plan-review` skill. Validates document structure, completeness, and agent-executability.

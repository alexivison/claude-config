# TASK1: gemini Agent

**Issue:** gemini-integration-agent
**Depends on:** TASK0

## Objective

Create a single CLI-based Gemini agent that handles both large-scale log analysis and web search synthesis.

## Required Context

Read these files first:
- `claude/agents/log-analyzer.md` — Current log analyzer (inherit patterns)
- `claude/agents/codex.md` — Agent definition pattern
- `gemini/GEMINI.md` — Gemini instructions (from TASK0)
- Run `gemini --help` to understand CLI options

## Files to Create

| File | Action |
|------|--------|
| `claude/agents/gemini.md` | Create |

## Implementation Details

### claude/agents/gemini.md

**Frontmatter:**
```yaml
---
name: gemini
description: "Gemini-powered analysis agent. Uses 2M token context for large logs (gemini-2.5-pro), Flash model for web search synthesis (gemini-2.0-flash)."
model: haiku
tools: Bash, Glob, Grep, Read, Write, WebSearch, WebFetch
color: green
---
```

**Mode Detection Logic:**

```
1. Check for explicit mode override (case-insensitive):
   - "mode:log" or "mode:logs" → LOG ANALYSIS
   - "mode:web" or "mode:search" → WEB SEARCH

2. Keyword heuristics (if no explicit mode):

   LOG ANALYSIS triggers:
   - File path with log extension: *.log, *.jsonl, /var/log/*
   - Phrases: "analyze logs", "production logs", "error logs", "log file"
   - Pattern: path ending in .log + "analyze" or "investigate"
   - Regex: /\b(analyze|investigate|check)\s+(the\s+)?(logs?|\.log)\b/i

   WEB SEARCH triggers (require explicit external qualifier):
   - Phrases: "research online", "research the web", "research externally"
   - Phrases: "look up online", "look up externally", "search the web"
   - Phrases: "what is the latest version", "what is the current version"
   - Phrases: "what do experts say", "what do others say"
   - Phrases: "find external info", "find external documentation"
   - Regex: /\b(research|look up|search)\s+(online|the web|externally)\b/i

   IMPORTANT: Bare "research" alone does NOT trigger web search
   (avoids overlap with codebase research tasks).

3. LOG ANALYSIS MODE:
   a. Estimate log size using byte count (more accurate than line count):
      bytes=$(wc -c < "$LOG_FILE")
      estimated_tokens=$((bytes / 4))
   b. Model selection based on size:
      - IF estimated_tokens < 500K → use gemini-2.0-flash (faster)
      - IF estimated_tokens >= 500K → use gemini-2.5-pro (large context)
      - IF estimated_tokens > 1.6M → warn about potential truncation

   NOTE: gemini agent handles ALL log analysis. log-analyzer is deprecated.
   c. Context overflow strategy:
      - Filter by time range if timestamps available
      - Or chunk into segments and analyze sequentially
   d. Gemini invocation (stdin for large content):
      GEMINI_CMD="${GEMINI_PATH:-$(command -v gemini || echo '$(npm root -g)/@google/gemini-cli/bin/gemini')}"
      cat /path/to/logs.log | "$GEMINI_CMD" --approval-mode plan -m gemini-2.5-pro -p "Analyze..."

4. WEB SEARCH MODE:
   a. Formulate search queries from user question
   b. Execute WebSearch tool for results
   c. Optionally WebFetch for full page content
   d. Synthesize with Gemini Flash:
      "$GEMINI_CMD" --approval-mode plan -m gemini-2.0-flash -p "Synthesize these search results..."
```

**CLI Path Resolution:**
```bash
# Robust CLI resolution with fallback
GEMINI_CMD="${GEMINI_PATH:-$(command -v gemini 2>/dev/null || echo '$(npm root -g)/@google/gemini-cli/bin/gemini')}"
if [[ ! -x "$GEMINI_CMD" ]]; then
  echo "Error: Gemini CLI not found. Install via: npm install -g @google/gemini-cli"
  exit 1
fi
```

**Log Analysis Invocation:**
```bash
# CORRECT: Pipe logs via stdin
cat /path/to/logs.log | gemini --approval-mode plan -m gemini-2.5-pro -p "Analyze these logs. Identify:
- Error patterns and frequencies
- Time-based clusters/spikes
- Correlations between error types
- Root cause hypotheses"

# WRONG: Never embed large content in argument (shell limit ~256KB)
# gemini -p "$(cat large.log)" ← DO NOT DO THIS
```

**Web Search Synthesis:**
```bash
# After gathering search results, synthesize with Flash
gemini --approval-mode plan -m gemini-2.0-flash -p "Based on these search results, provide a comprehensive answer to: {question}

Search Results:
{formatted_results}

Include:
- Direct answer to the question
- Key findings from multiple sources
- Source citations with URLs
- Any conflicting information noted"
```

**Output Formats:**

For log analysis (same as log-analyzer.md):
```markdown
## Log Analysis Report

**Source:** {log_path}
**Lines analyzed:** {count}
**Time range:** {start} to {end}

### Summary
{key findings}

### Error Patterns
| Pattern | Count | Severity |
|---------|-------|----------|
...

### Recommendations
- {actionable items}
```

For web search:
```markdown
## Research Findings

**Query:** {original_question}

### Answer
{synthesized answer}

### Key Points
- {bullet points}

### Sources
1. [{title}]({url}) - {brief description}
2. ...
```

## Verification

```bash
# Agent file exists and has correct frontmatter
grep -q "name: gemini" claude/agents/gemini.md

# Check for mode detection logic
grep -qE "LOG ANALYSIS|WEB SEARCH|log-analysis|web-search" claude/agents/gemini.md

# Check for correct CLI invocation pattern (stdin piping)
grep -qE "cat.*\| gemini" claude/agents/gemini.md

# Check for model selection
grep -q "gemini-2.5-pro" claude/agents/gemini.md
grep -q "gemini-2.0-flash" claude/agents/gemini.md
```

## Acceptance Criteria

- [x] Agent definition created at `claude/agents/gemini.md`
- [x] Mode detection:
  - [x] Supports explicit mode override (`mode:log`, `mode:web`)
  - [x] Falls back to keyword heuristics when no explicit mode
- [x] Log analysis mode:
  - [x] Size estimation uses byte count (`wc -c`) ÷ 4 for tokens
  - [x] Uses gemini-2.0-flash for logs < 500K tokens
  - [x] Uses gemini-2.5-pro for logs >= 500K tokens
  - [x] Warns if logs exceed 1.6M tokens (potential truncation)
  - [x] Handles ALL log sizes (no delegation to log-analyzer)
  - [x] Context overflow: time-range filtering or chunking strategy
  - [x] Uses `cat logs | gemini -p` pattern (stdin piping)
  - [x] Uses gemini-2.5-pro model
  - [x] Uses `--approval-mode plan` for read-only
  - [x] Output format matches existing log-analyzer
- [x] CLI resolution:
  - [x] Uses `GEMINI_PATH` env var if set
  - [x] Falls back to `command -v gemini`
  - [x] Falls back to `$(npm root -g)/@google/gemini-cli/bin/gemini`
- [x] Web search mode:
  - [x] Uses WebSearch tool for queries (agent has this tool)
  - [x] Optionally uses WebFetch for full page content
  - [x] Synthesizes results with gemini-2.0-flash model
  - [x] Includes source citations with URLs
- [x] Verification tests:
  - [x] Log analysis: Test with file >2MB, verify gemini-2.5-pro used
  - [x] Log analysis: Test with file <2MB, verify gemini-2.0-flash used
  - [x] Web search: Test with explicit "search the web" query
  - [x] CLI: Verify all three resolution paths work

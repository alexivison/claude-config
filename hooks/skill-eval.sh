#!/bin/bash

# Skill auto-invocation hook
# Detects skill triggers and suggests immediate invocation
# Silent when no match — only speaks up when a skill should be invoked

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty' 2>/dev/null)
PROMPT_LOWER=$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]')

# Detect triggers and build suggestion
SUGGESTION=""

if echo "$PROMPT_LOWER" | grep -qE 'write test|add test|create test|test coverage|add coverage'; then
  SUGGESTION="INVOKE /write-tests before writing any tests."
elif echo "$PROMPT_LOWER" | grep -qE 'create pr|make pr|ready for pr|open pr|submit pr|push.*pr'; then
  SUGGESTION="INVOKE /pre-pr-verification before creating the PR."
elif echo "$PROMPT_LOWER" | grep -qE 'review|check this|look at this code|feedback on'; then
  SUGGESTION="INVOKE /code-review for systematic review."
elif echo "$PROMPT_LOWER" | grep -qE 'plan this|break down|create spec|design this|plan implementation'; then
  SUGGESTION="INVOKE /plan-implementation for structured planning."
elif echo "$PROMPT_LOWER" | grep -qE 'pr comment|reviewer|address feedback|fix comment|respond to'; then
  SUGGESTION="INVOKE /address-pr to systematically address comments."
elif echo "$PROMPT_LOWER" | grep -qE 'bloat|too big|minimize|simplify|over.?engineer'; then
  SUGGESTION="INVOKE /minimize to identify unnecessary complexity."
elif echo "$PROMPT_LOWER" | grep -qE 'unclear|multiple approach|not sure how|brainstorm'; then
  SUGGESTION="INVOKE /brainstorm to capture context before planning."
fi

# Only output if there's a match
if [ -n "$SUGGESTION" ]; then
  cat << EOF
{
  "additionalContext": "<skill-trigger>\n$SUGGESTION\n</skill-trigger>"
}
EOF
else
  # Silent when no match
  echo '{}'
fi

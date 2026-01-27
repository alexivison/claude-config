#!/bin/bash
# Skill Marker Hook - Creates markers when critical skills complete
# Used by PR gate and workflow tracking to verify skills were invoked
#
# Triggered: PostToolUse on Skill tool
# Creates: /tmp/claude-skill-{name}-{session_id} for MUST-invoke skills

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
SKILL=$(echo "$INPUT" | jq -r '.tool_input.skill // empty' 2>/dev/null)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)

# Fail silently if we can't parse
if [ -z "$SESSION_ID" ]; then
  echo '{}'
  exit 0
fi

# Create markers for MUST-invoke skills
if [ "$TOOL" = "Skill" ]; then
  case "$SKILL" in
    pre-pr-verification)
      touch "/tmp/claude-pr-verified-$SESSION_ID"
      touch "/tmp/claude-skill-pre-pr-verification-$SESSION_ID"
      ;;
    write-tests)
      touch "/tmp/claude-skill-write-tests-$SESSION_ID"
      ;;
    code-review)
      touch "/tmp/claude-skill-code-review-$SESSION_ID"
      ;;
  esac
fi

echo '{}'

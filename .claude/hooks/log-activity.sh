#!/usr/bin/env bash
# PostToolUse hook: Worker の Bash/Edit/Write 操作を activity.log に記録する
set -euo pipefail

LOG_FILE="${CLAUDE_PROJECT_DIR}/.claude/audit/activity.log"
input="$(cat)"

tool_name="$(printf '%s' "$input" | jq -r '.tool_name // ""')"
timestamp="$(date -Iseconds)"

case "$tool_name" in
  Bash)
    command="$(printf '%s' "$input" | jq -r '.tool_input.command // ""')"
    exit_code="$(printf '%s' "$input" | jq -r '.tool_response.exit_code // "?"')"
    printf '[%s] BASH exit=%s $ %s\n' "$timestamp" "$exit_code" "$command" >> "$LOG_FILE"
    ;;
  Edit|Write)
    file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // ""')"
    printf '[%s] %s %s\n' "$timestamp" "$tool_name" "$file_path" >> "$LOG_FILE"
    ;;
esac

exit 0

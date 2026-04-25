#!/usr/bin/env bash
set -euo pipefail

input="$(cat)"
path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // ""')"

case "$path" in
  *.env|*.env.*|*/.env|*/.env.*)
    echo "Blocked by protect-files.sh: .env file is protected: $path" >&2
    exit 2
    ;;
  */secrets/*|secrets/*)
    echo "Blocked by protect-files.sh: secrets directory is protected: $path" >&2
    exit 2
    ;;
  */.git/*|.git/*)
    echo "Blocked by protect-files.sh: direct .git modification is not allowed: $path" >&2
    exit 2
    ;;
  */.claude/settings.json|.claude/settings.json)
    echo "Blocked by protect-files.sh: settings.json requires manual edit: $path" >&2
    exit 2
    ;;
esac

exit 0

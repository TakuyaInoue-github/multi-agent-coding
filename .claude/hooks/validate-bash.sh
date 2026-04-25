#!/usr/bin/env bash
set -euo pipefail

input="$(cat)"
command="$(printf '%s' "$input" | jq -r '.tool_input.command // ""')"

case "$command" in
  *"git push --force"*|*"git push -f"*)
    echo "Blocked by validate-bash.sh: force push is not allowed" >&2
    exit 2
    ;;
  *"git reset --hard"*)
    echo "Blocked by validate-bash.sh: git reset --hard is not allowed" >&2
    exit 2
    ;;
  *"git clean"*)
    echo "Blocked by validate-bash.sh: git clean is not allowed" >&2
    exit 2
    ;;
  *"git checkout -- "*|*"git checkout ."*)
    echo "Blocked by validate-bash.sh: destructive git checkout is not allowed" >&2
    exit 2
    ;;
  *"rm -rf"*)
    echo "Blocked by validate-bash.sh: rm -rf is not allowed" >&2
    exit 2
    ;;
  *"kubectl"*|*"terraform apply"*|*"terraform destroy"*)
    echo "Blocked by validate-bash.sh: infrastructure command is not allowed" >&2
    exit 2
    ;;
  *"aws "*|*"gcloud "*|*"az "*)
    echo "Blocked by validate-bash.sh: cloud CLI is not allowed" >&2
    exit 2
    ;;
  *"curl "*|*"wget "*|*"nc "*|*"netcat "*|*"ssh "*|*"scp "*|*"rsync "*)
    echo "Blocked by validate-bash.sh: network-capable command is not allowed" >&2
    exit 2
    ;;
esac

exit 0

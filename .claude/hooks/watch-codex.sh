#!/usr/bin/env bash
# Codex state.json を監視して phase 変化を activity.log に記録する
# 使い方: watch-codex.sh  (プロジェクトルートから実行)
set -euo pipefail

PROJECT_DIR="${1:-$(git -C "$(dirname "$0")" rev-parse --show-toplevel)}"
LOG_FILE="${PROJECT_DIR}/.claude/audit/activity.log"

# Codex state.json のパスを node で解決する
STATE_FILE="$(node -e "
const { createHash } = require('crypto');
const fs = require('fs');
const path = require('path');
const cwd = process.argv[1];
let root = cwd;
try { root = fs.realpathSync.native(cwd); } catch {}
const slug = path.basename(root).replace(/[^a-zA-Z0-9._-]+/g, '-').replace(/^-+|-+\$/, '');
const hash = createHash('sha256').update(root).digest('hex').slice(0, 16);
const pluginData = process.env.CLAUDE_PLUGIN_DATA;
const stateRoot = pluginData ? path.join(pluginData, 'state') : '/tmp/codex-companion';
console.log(path.join(stateRoot, slug + '-' + hash, 'state.json'));
" "$PROJECT_DIR")"

printf '[%s] WATCH start state=%s\n' "$(date -Iseconds)" "$STATE_FILE" >> "$LOG_FILE"

prev_snapshot=""

while true; do
  if [[ ! -f "$STATE_FILE" ]]; then
    sleep 2
    continue
  fi

  snapshot="$(node -e "
const fs = require('fs');
const state = JSON.parse(fs.readFileSync(process.argv[1], 'utf8'));
const summary = (state.jobs || []).map(j =>
  j.id + ':' + (j.status||'?') + ':' + (j.phase||'?')
).join('|');
console.log(summary);
" "$STATE_FILE" 2>/dev/null || echo "")"

  if [[ "$snapshot" != "$prev_snapshot" && -n "$snapshot" ]]; then
    timestamp="$(date -Iseconds)"
    # 変化したジョブだけ差分出力
    node -e "
const fs = require('fs');
const state = JSON.parse(fs.readFileSync(process.argv[1], 'utf8'));
const prev = process.argv[2];
const prevMap = {};
prev.split('|').forEach(entry => {
  const [id, status, phase] = entry.split(':');
  if (id) prevMap[id] = { status, phase };
});
(state.jobs || []).forEach(job => {
  const p = prevMap[job.id];
  const changed = !p || p.status !== job.status || p.phase !== job.phase;
  if (changed) {
    const ts = new Date().toISOString();
    const from = p ? p.status + '/' + p.phase : 'new';
    const to = (job.status||'?') + '/' + (job.phase||'?');
    process.stdout.write('[' + ts + '] CODEX job=' + job.id + ' ' + from + ' -> ' + to + '\n');
  }
});
" "$STATE_FILE" "$prev_snapshot" >> "$LOG_FILE" 2>/dev/null || true

    prev_snapshot="$snapshot"
  fi

  sleep 2
done

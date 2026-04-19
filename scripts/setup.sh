#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# setup.sh — multi-agent runtime の初期化スクリプト
# ---------------------------------------------------------------------------

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RUNTIME_DIR="$PROJECT_ROOT/runtime"

# --- ヘルパー関数 -----------------------------------------------------------

echo_info()  { echo "[INFO]  $*"; }
echo_warn()  { echo "[WARN]  $*"; }
echo_ok()    { echo "[OK]    $*"; }

prompt() {
  # prompt <変数名> <質問文> <デフォルト値>
  local var="$1" question="$2" default="$3"
  read -r -p "$question [$default]: " input
  eval "$var=\"${input:-$default}\""
}

confirm_overwrite() {
  # confirm_overwrite <ファイルパス> → 0: 上書きOK / 1: スキップ
  local file="$1"
  if [[ ! -f "$file" ]]; then return 0; fi
  echo_warn "既に存在します: $file"
  read -r -p "  上書きしますか？ [y/N]: " ans
  [[ "$ans" =~ ^[Yy]$ ]]
}

# --- セッション番号の自動採番 -----------------------------------------------

next_session_id() {
  local max=0 n
  if [[ -f "$RUNTIME_DIR/BOARD.md" ]]; then
    n=$(grep -oP '(?<=session_id: session-)\d+' "$RUNTIME_DIR/BOARD.md" 2>/dev/null || echo 0)
    max=$((n > max ? n : max))
  fi
  printf "session-%03d" $((max + 1))
}

# --- メイン -----------------------------------------------------------------

echo ""
echo "==========================================="
echo "  Multi-Agent Runtime セットアップ"
echo "==========================================="
echo ""

# 1. base_branch
current_branch=$(git -C "$PROJECT_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "develop")
prompt base_branch "作業起点ブランチ (base_branch)" "$current_branch"

# 2. language
prompt language "使用言語 (Python / TypeScript / Go / Java)" "Python"

# 3. project_goal
prompt project_goal "プロジェクト方針・目標（1行）" "（未設定）"

# 4. project_name
default_name=$(basename "$PROJECT_ROOT")
prompt project_name "プロジェクト名" "$default_name"

# 5. dir_structure
prompt dir_structure "主要ディレクトリ構成（例: src/ tests/ docs/）" "src/ tests/"

# --- runtime/ ディレクトリ作成 -----------------------------------------------

mkdir -p "$RUNTIME_DIR"
echo_ok "runtime/ ディレクトリを確認しました"

# --- 生成パラメータ ----------------------------------------------------------

session_id=$(next_session_id)
started_at=$(date -u +"%Y-%m-%dT%H:%M:%S")

# --- BOARD.md ---------------------------------------------------------------

BOARD_FILE="$RUNTIME_DIR/BOARD.md"
if confirm_overwrite "$BOARD_FILE"; then
  cat > "$BOARD_FILE" <<EOF
session_id: $session_id
base_branch: $base_branch
base_branch_created_by: user
started_at: ${started_at}
discussion_round_limit: 3

tasks: []

observer_check_triggers:
  - spec_created
  - commander_review_created

observer_request: null
EOF
  echo_ok "runtime/BOARD.md を作成しました"
else
  echo_info "runtime/BOARD.md をスキップしました"
fi

# --- CONTEXT.md -------------------------------------------------------------

CONTEXT_FILE="$RUNTIME_DIR/CONTEXT.md"
if confirm_overwrite "$CONTEXT_FILE"; then
  cat > "$CONTEXT_FILE" <<EOF
## プロジェクト方針
$project_goal

## 技術スタック
language: $language

## 現時点の判断基準
（未設定）

## 未解決事項
（なし）

## 次セッションへの申し送り
（なし）
EOF
  echo_ok "runtime/CONTEXT.md を作成しました"
else
  echo_info "runtime/CONTEXT.md をスキップしました"
fi

# --- DISCUSSION.md ----------------------------------------------------------

DISCUSSION_FILE="$RUNTIME_DIR/DISCUSSION.md"
if confirm_overwrite "$DISCUSSION_FILE"; then
  cat > "$DISCUSSION_FILE" <<EOF
# Discussion Log

セッション: $session_id
開始: $started_at

---
EOF
  echo_ok "runtime/DISCUSSION.md を作成しました"
else
  echo_info "runtime/DISCUSSION.md をスキップしました"
fi

# --- SUMMARY.md -------------------------------------------------------------

SUMMARY_FILE="$RUNTIME_DIR/SUMMARY.md"
if confirm_overwrite "$SUMMARY_FILE"; then
  cat > "$SUMMARY_FILE" <<EOF
# 進捗サマリー

セッション: $session_id
開始: $started_at
ベースブランチ: $base_branch

## タスク状況
（未開始）

## 未解決イベント
（なし）
EOF
  echo_ok "runtime/SUMMARY.md を作成しました"
else
  echo_info "runtime/SUMMARY.md をスキップしました"
fi

# --- EVENTLOG.json ----------------------------------------------------------

EVENTLOG_FILE="$RUNTIME_DIR/EVENTLOG.json"
if confirm_overwrite "$EVENTLOG_FILE"; then
  cat > "$EVENTLOG_FILE" <<EOF
[
  {
    "event_id": "evt-001",
    "timestamp": "$started_at",
    "session_id": "$session_id",
    "actor": "system",
    "action": "session_start",
    "task_id": null,
    "related_events": [],
    "severity": null,
    "trigger": "setup.sh",
    "retry_count": 0,
    "tokens_used": 0,
    "detail": "セットアップスクリプトによりセッションを初期化"
  }
]
EOF
  echo_ok "runtime/EVENTLOG.json を作成しました"
else
  echo_info "runtime/EVENTLOG.json をスキップしました"
fi

# --- CLAUDE.md (プロジェクトルート) -----------------------------------------

CLAUDE_FILE="$PROJECT_ROOT/CLAUDE.md"
if confirm_overwrite "$CLAUDE_FILE"; then
  cat > "$CLAUDE_FILE" <<EOF
# ${project_name}

## プロジェクト概要
${project_goal}

## 技術スタック
- 言語: ${language}
- ベースブランチ: ${base_branch}

## ディレクトリ構成
\`\`\`
${dir_structure}
\`\`\`

## コーディング規約・方針
（プロジェクト固有の規約をここに追記してください）

---

## Multi-Agent フレームワーク

このプロジェクトは Commander / Observer / Worker の3エージェント構成で開発を進めます。

@.multi-agent/roles/commander/CLAUDE.md
EOF
  echo_ok "CLAUDE.md を作成しました"
else
  echo_info "CLAUDE.md をスキップしました"
fi

# --- 完了メッセージ ----------------------------------------------------------

echo ""
echo "==========================================="
echo "  セットアップ完了"
echo "==========================================="
echo ""
echo "  セッションID : $session_id"
echo "  ベースブランチ: $base_branch"
echo "  言語         : $language"
echo ""
echo "次のステップ:"
echo "  Claude Code を起動して以下を伝えてください："
echo ""
echo "  .multi-agent/roles/commander/CLAUDE.md を読んで、"
echo "  セッション開始手順に従ってください。"
echo "  今回のタスクは：（あなたの指示）"
echo ""

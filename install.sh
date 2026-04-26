#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# install.sh — multi-agent フレームワークを既存プロジェクトに導入するスクリプト
#
# 使い方:
#   curl -sSL https://raw.githubusercontent.com/TakuyaInoue-github/multi-agent-coding/main/install.sh | bash
#   または
#   bash install.sh  （リポジトリをクローン後）
# ---------------------------------------------------------------------------

REPO_URL="https://github.com/TakuyaInoue-github/multi-agent-coding"
RAW_BASE="https://raw.githubusercontent.com/TakuyaInoue-github/multi-agent-coding/main"

DEST_DIR="${PWD}"
MULTI_AGENT_DIR="$DEST_DIR/.multi-agent"
SCRIPTS_DIR="$DEST_DIR/scripts"

# --- ヘルパー ---------------------------------------------------------------

echo_info()  { echo "[INFO]  $*"; }
echo_ok()    { echo "[OK]    $*"; }
echo_warn()  { echo "[WARN]  $*"; }
echo_error() { echo "[ERROR] $*" >&2; }

require_cmd() {
  command -v "$1" &>/dev/null || { echo_error "$1 が見つかりません。インストールしてください。"; exit 1; }
}

# --- 依存チェック ------------------------------------------------------------

require_cmd git
require_cmd curl

# --- インストール先の確認 ----------------------------------------------------

echo ""
echo "==========================================="
echo "  Multi-Agent フレームワーク インストーラー"
echo "==========================================="
echo ""
echo_info "インストール先: $DEST_DIR"

if [[ ! -d "$DEST_DIR/.git" ]]; then
  echo_warn "カレントディレクトリは git リポジトリではありません。"
  read -r -p "  このまま続けますか？ [y/N]: " ans
  [[ "$ans" =~ ^[Yy]$ ]] || { echo_info "中止しました。"; exit 0; }
fi

# --- .multi-agent/ の展開 ---------------------------------------------------

if [[ -d "$MULTI_AGENT_DIR" ]]; then
  echo_warn ".multi-agent/ が既に存在します。"
  read -r -p "  上書きしますか？ [y/N]: " ans
  [[ "$ans" =~ ^[Yy]$ ]] || { echo_info "インストールを中止しました。"; exit 0; }
  rm -rf "$MULTI_AGENT_DIR"
fi

echo_info ".multi-agent/ を展開中..."

# 一時ディレクトリにリポジトリを sparse clone
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

git clone --depth 1 --filter=blob:none --sparse "$REPO_URL" "$TMP_DIR/repo" 2>/dev/null
(
  cd "$TMP_DIR/repo"
  git sparse-checkout set .multi-agent scripts/setup.sh
)

cp -r "$TMP_DIR/repo/.multi-agent" "$MULTI_AGENT_DIR"
echo_ok ".multi-agent/ をコピーしました"

# --- scripts/setup.sh の展開 ------------------------------------------------

mkdir -p "$SCRIPTS_DIR"

if [[ -f "$SCRIPTS_DIR/setup.sh" ]]; then
  echo_warn "scripts/setup.sh が既に存在します。スキップします。"
else
  cp "$TMP_DIR/repo/scripts/setup.sh" "$SCRIPTS_DIR/setup.sh"
  chmod +x "$SCRIPTS_DIR/setup.sh"
  echo_ok "scripts/setup.sh をコピーしました"
fi

# --- .gitignore への追記 ----------------------------------------------------

GITIGNORE="$DEST_DIR/.gitignore"
GITIGNORE_BLOCK="# Multi-Agent Framework (runtime state)
runtime/BOARD.md
runtime/CONTEXT.md
runtime/DISCUSSION.md
runtime/SUMMARY.md
runtime/EVENTLOG.json"

if [[ -f "$GITIGNORE" ]] && grep -q "runtime/BOARD.md" "$GITIGNORE"; then
  echo_info ".gitignore は既に設定済みです。スキップします。"
else
  echo "" >> "$GITIGNORE"
  echo "$GITIGNORE_BLOCK" >> "$GITIGNORE"
  echo_ok ".gitignore に runtime/ の除外設定を追加しました"
fi

# --- 完了メッセージ ----------------------------------------------------------

echo ""
echo "==========================================="
echo "  インストール完了"
echo "==========================================="
echo ""
echo "次のステップ:"
echo ""
echo "  1. runtime/ を初期化する:"
echo "     bash scripts/setup.sh"
echo ""
echo "  2. Claude Code を起動してタスクを依頼する:"
echo "     .multi-agent/roles/commander/CLAUDE.md を読んで、"
echo "     セッション開始手順に従ってください。"
echo "     今回のタスクは：（あなたの指示）"
echo ""
echo "詳細: $REPO_URL"
echo ""

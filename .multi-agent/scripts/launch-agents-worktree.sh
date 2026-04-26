#!/bin/bash
# Multi-Agent System Launcher (with Git Worktrees)
# 各ロール専用の worktree を作成し、settings.local.json でロール別権限を展開して起動する

set -e

PROJECT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$PROJECT_DIR"

echo "==================================="
echo "Multi-Agent System Launcher"
echo "(Git Worktree Mode)"
echo "==================================="
echo ""

# tmux 確認
if ! command -v tmux &> /dev/null; then
    echo "Error: tmux is not installed."
    echo "Install with: sudo apt-get install tmux"
    exit 1
fi

# git リポジトリ確認
if [ ! -d ".git" ]; then
    echo "Error: Not a git repository."
    exit 1
fi

# runtime/ 初期化
echo "Initializing runtime/ directory..."
mkdir -p runtime

if [ ! -f "runtime/BOARD.md" ]; then
    cat > runtime/BOARD.md << 'EOF'
---
session_id: session-$(date +%Y%m%d-%H%M%S)
base_branch: develop
started_at: $(date -Iseconds)

policy:
  worker_timeout_hours: 1
  observer_timeout_hours: 1
  commander_response_hours: 2
  discussion_round_limit: 3
---

## タスク一覧

tasks: {}

## 統計

stats:
  total_tasks: 0
  completed: 0
  failed: 0
  blocked: 0
EOF
    echo "Created runtime/BOARD.md"
fi

if [ ! -f "runtime/EVENTLOG.json" ]; then
    echo "[]" > runtime/EVENTLOG.json
    echo "Created runtime/EVENTLOG.json"
fi

if [ ! -f "runtime/CONTEXT.md" ]; then
    cat > runtime/CONTEXT.md << 'EOF'
---
session_id: session-001
---

## プロジェクト方針

（ユーザーから受けた指示・全体目標の要約）

## 現時点の判断基準

（Observer との議論で確立したルール・例外事項）

## 未解決事項

（上告中・議論継続中・ブロック中のタスク）

## 次セッションへの申し送り

（優先して着手すべきこと・注意事項）
EOF
    echo "Created runtime/CONTEXT.md"
fi

if [ ! -f "runtime/SUMMARY.md" ]; then
    cat > runtime/SUMMARY.md << 'EOF'
# プロジェクトサマリー

最終更新：（未更新）

## 全体進捗

- 完了タスク：0件
- 進行中：0件
- ブロック中：0件

## 未解決イベント一覧

（なし）
EOF
    echo "Created runtime/SUMMARY.md"
fi

if [ ! -f "runtime/DISCUSSION.md" ]; then
    cat > runtime/DISCUSSION.md << 'EOF'
# DISCUSSION.md

議論ラウンドの上限は BOARD.md の `policy.discussion_round_limit` に従う。

---
EOF
    echo "Created runtime/DISCUSSION.md"
fi

echo ""
echo "Runtime files initialized."
echo ""

# worktree のセットアップ
# 各ロールに専用 worktree を作成し、settings.local.json でロール別権限を展開する
# 既存セッションをクリーンアップ
echo "Killing existing agent sessions (if any)..."
tmux kill-session -t commander 2>/dev/null || true
tmux kill-session -t observer  2>/dev/null || true
tmux kill-session -t worker-1  2>/dev/null || true
echo ""

# /loop 起動プロンプト
COMMANDER_LOOP_PROMPT='/loop 5m .multi-agent/roles/commander/CLAUDE.md を読んで自律ループを実行してください。runtime/BOARD.md と runtime/EVENTLOG.json を確認し、次に取るべきアクションがあれば実行してください。'
OBSERVER_LOOP_PROMPT='/loop 5m .multi-agent/roles/observer/CLAUDE.md を読んで自律チェックを実行してください。未評価の spec.md と commander_review.md を探し、あれば評価を実施してください。'
WORKER_LOOP_PROMPT='/loop 5m .multi-agent/roles/worker/CLAUDE.md を読んで自律ループを実行してください。BOARD.md で approved かつ .assigned が存在しないタスクを探し、あれば .assigned を作成して実装を開始してください。'

# Claude Code の入力プロンプト（❯）が出るまで待機する関数
wait_for_claude() {
    local session=$1
    local timeout=60
    local elapsed=0
    echo -n "  Waiting for claude to start in '$session'..."
    while ! tmux capture-pane -t "$session" -p 2>/dev/null | grep -q "❯"; do
        sleep 1
        elapsed=$((elapsed + 1))
        if [ "$elapsed" -ge "$timeout" ]; then
            echo " timeout!"
            return 1
        fi
    done
    # Claude Code が完全に初期化されるまで追加待機
    sleep 3
    echo " ready."
}

# 各エージェントをロール専用 worktree で起動
echo "Launching agents..."
echo ""

echo "[1/3] Starting Commander..."
tmux new-session -d -s commander -c "$PROJECT_DIR" "claude"
wait_for_claude commander
tmux send-keys -t commander "$COMMANDER_LOOP_PROMPT"
sleep 1
tmux send-keys -t commander Enter

echo "[2/3] Starting Observer..."
tmux new-session -d -s observer -c "$PROJECT_DIR" "claude"
wait_for_claude observer
tmux send-keys -t observer "$OBSERVER_LOOP_PROMPT"
sleep 1
tmux send-keys -t observer Enter

echo "[3/3] Starting Worker-1..."
tmux new-session -d -s worker-1 -c "$PROJECT_DIR" "claude"
wait_for_claude worker-1
tmux send-keys -t worker-1 "$WORKER_LOOP_PROMPT"
sleep 1
tmux send-keys -t worker-1 Enter

echo ""
echo "==================================="
echo "All agents started successfully!"
echo "==================================="
echo ""
echo "Available sessions:"
echo "  - commander  ($PROJECT_DIR)"
echo "  - observer   ($PROJECT_DIR)"
echo "  - worker-1   ($PROJECT_DIR)"
echo ""
echo "Commands:"
echo "  tmux list-sessions                 # List all sessions"
echo "  tmux attach-session -t commander   # Attach to Commander"
echo "  tmux attach-session -t observer    # Attach to Observer"
echo "  tmux attach-session -t worker-1    # Attach to Worker 1"
echo ""
echo "  Ctrl+B then D                      # Detach from session"
echo "  tmux kill-session -t <name>        # Kill a specific session"
echo ""
echo "Workflow:"
echo "  1. Commander: タスク分解・spec.md 作成       (/loop 自動実行中)"
echo "  2. Observer:  Gate1 評価                     (/loop 自動実行中)"
echo "  3. Worker:    実装・result.md 作成            (/loop 自動実行中)"
echo "  4. Commander: 一次評価・commander_review.md   (/loop 自動実行中)"
echo "  5. Observer:  Gate2 評価                     (/loop 自動実行中)"
echo "  6. Commander: base_branch にマージ            (/loop 自動実行中)"
echo ""
echo "Note: 各セッションはロール専用 worktree で動作し、settings.local.json でロール別権限が適用されています。"
echo "      ユーザーの介入が必要な場合は Commander セッションに通知が届きます。"
echo "      新規タスクを指示する場合は: tmux attach-session -t commander"
echo ""

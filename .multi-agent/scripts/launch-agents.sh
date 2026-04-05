#!/bin/bash
# Multi-Agent System Launcher
# このスクリプトは Commander、Observer、Worker の各セッションを起動します

set -e

# プロジェクトディレクトリを自動取得（このスクリプトの親ディレクトリ）
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

echo "==================================="
echo "Multi-Agent System Launcher"
echo "==================================="
echo ""

# tmux がインストールされているか確認
if ! command -v tmux &> /dev/null; then
    echo "Error: tmux is not installed."
    echo "Install with: sudo apt-get install tmux"
    exit 1
fi

# 既存のセッションをクリーンアップ（オプション）
read -p "Kill existing agent sessions? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    tmux kill-session -t commander 2>/dev/null || true
    tmux kill-session -t observer 2>/dev/null || true
    tmux kill-session -t worker-1 2>/dev/null || true
    tmux kill-session -t worker-2 2>/dev/null || true
    echo "Existing sessions killed."
fi

echo ""
echo "Launching agents..."
echo ""

# Commander セッションを起動
echo "[1/4] Starting Commander..."
tmux new-session -d -s commander -c "$PROJECT_DIR" \
    "echo 'Commander Session'; \
     echo 'Loading .multi-agent/roles/commander/CLAUDE.md...'; \
     cat .multi-agent/roles/commander/CLAUDE.md; \
     echo ''; \
     echo 'Commander is ready. Press Enter to start Claude Code.'; \
     read; \
     claude"

# Observer セッションを起動
echo "[2/4] Starting Observer..."
tmux new-session -d -s observer -c "$PROJECT_DIR" \
    "echo 'Observer Session'; \
     echo 'Loading .multi-agent/roles/observer/CLAUDE.md...'; \
     cat .multi-agent/roles/observer/CLAUDE.md; \
     echo ''; \
     echo 'Observer is ready. Press Enter to start Claude Code.'; \
     read; \
     claude"

# Worker セッション1を起動
echo "[3/4] Starting Worker-1..."
tmux new-session -d -s worker-1 -c "$PROJECT_DIR" \
    "echo 'Worker-1 Session'; \
     echo 'Loading .multi-agent/roles/worker/CLAUDE.md...'; \
     cat .multi-agent/roles/worker/CLAUDE.md; \
     echo ''; \
     echo 'Worker-1 is ready. Press Enter to start Claude Code.'; \
     read; \
     claude"

# Worker セッション2を起動（オプション）
echo "[4/4] Starting Worker-2..."
tmux new-session -d -s worker-2 -c "$PROJECT_DIR" \
    "echo 'Worker-2 Session'; \
     echo 'Loading .multi-agent/roles/worker/CLAUDE.md...'; \
     cat .multi-agent/roles/worker/CLAUDE.md; \
     echo ''; \
     echo 'Worker-2 is ready. Press Enter to start Claude Code.'; \
     read; \
     claude"

echo ""
echo "==================================="
echo "All agents started successfully!"
echo "==================================="
echo ""
echo "Available sessions:"
echo "  - commander  (Commander agent)"
echo "  - observer   (Observer agent)"
echo "  - worker-1   (Worker agent #1)"
echo "  - worker-2   (Worker agent #2)"
echo ""
echo "Commands:"
echo "  tmux list-sessions              # List all sessions"
echo "  tmux attach-session -t commander   # Attach to Commander"
echo "  tmux attach-session -t observer    # Attach to Observer"
echo "  tmux attach-session -t worker-1    # Attach to Worker 1"
echo "  tmux attach-session -t worker-2    # Attach to Worker 2"
echo ""
echo "  Ctrl+B then D                   # Detach from session"
echo "  tmux kill-session -t <name>     # Kill a specific session"
echo ""
echo "Next steps:"
echo "  1. Attach to Commander: tmux attach-session -t commander"
echo "  2. Press Enter to start Claude Code"
echo "  3. Paste the contents of .multi-agent/roles/commander/CLAUDE.md as the first message"
echo "  4. Begin your task decomposition"
echo ""

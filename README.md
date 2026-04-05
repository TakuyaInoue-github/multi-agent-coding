# Multi-Agent Coding Support System

マルチエージェント構成によるコーディング開発支援ツール

## 概要

Commander / Observer / Worker の3エージェント構成で、ファイルベース連携により品質保証とタスク管理を実現します。

```
Commander (Claude Code)  → タスク分解・管理・一次評価
Observer  (Claude Code)  → 独立した品質評価・監視
Worker    (Codex)        → 実装・テスト・デバッグ
```

## クイックスタート

### 複数セッションでの起動（推奨）

真のマルチエージェントシステムとして動作させるには、3つの独立したClaude Codeセッションを起動します：

```bash
# 自動起動スクリプトを使用
./scripts/launch-agents-worktree.sh

# セッションに接続
tmux attach-session -t commander   # Commander
tmux attach-session -t observer    # Observer
tmux attach-session -t worker-1    # Worker

# デタッチ: Ctrl+B then D
```

詳細は [docs/MULTI_SESSION_WORKFLOW.md](docs/MULTI_SESSION_WORKFLOW.md) を参照してください。

### シングルセッションでの起動（開発・テスト用）

1つのセッションで全エージェントをシミュレーション：

1. `runtime/` ディレクトリの状態ファイルを確認
2. Commander セッションを起動
3. `agents/commander/CLAUDE.md` をシステムプロンプトとして使用

詳細は [docs/GUIDE.md](docs/GUIDE.md) を参照してください。

### Codex Plugin のセットアップ（Worker のみ）

Worker は実装タスクを **Codex に委譲**します。初回のみ以下のセットアップが必要です：

```bash
# Worker セッションで実行
/plugin marketplace add openai/codex-plugin-cc
/plugin install codex@openai-codex
/reload-plugins
/codex:setup
```

**必要な認証**:
- ChatGPT Plus サブスクリプション、または
- OpenAI API キー（`export OPENAI_API_KEY="sk-..."`）

詳細は [docs/CODEX_SETUP.md](docs/CODEX_SETUP.md) を参照してください。

## ディレクトリ構造

```
multi-agent/
├── .claude/skills/  # Claude Code Skills（タスク分解・評価等）
├── .codex/          # Codex Plugin 設定
├── agents/          # エージェント定義（システムプロンプト）
├── config/          # 設定・ルール
├── templates/       # テンプレート
├── runtime/         # ランタイム状態（セッション中に更新）
├── tasks/           # タスク実行結果
├── docs/            # ドキュメント
├── scripts/         # 起動スクリプト
├── archive/         # アーカイブ
└── improvement/     # 改善文書
```

## 主要ファイル

### エージェント定義
- `agents/commander/CLAUDE.md` - Commander用プロンプト
- `agents/observer/CLAUDE.md` - Observer用プロンプト
- `agents/worker/CLAUDE.md` - Worker用プロンプト

### ランタイム状態
- `runtime/BOARD.md` - タスク状態管理
- `runtime/CONTEXT.md` - セッション引き継ぎ
- `runtime/DISCUSSION.md` - 議論ログ
- `runtime/SUMMARY.md` - 進捗サマリー
- `runtime/EVENTLOG.json` - イベント記録

### 設定
- `config/RULEBOOK.md` - Observer評価基準

### Claude Code Skills
- `.claude/skills/task-decomposition/` - タスク分解Skill（Commander用）
- `.claude/skills/gate-evaluation/` - Gate評価Skill（Observer用）
- `.claude/skills/status-sync/` - ステータス同期Skill（Commander用）

## 主要機能

### Skills による効率化

Commander と Observer は Claude Code の Skills 機構を活用します：

- **タスク分解**: `/decompose-task` で自動的に依存関係を解析
- **品質評価**: `/evaluate-gate` で一貫した評価基準を適用
- **ステータス管理**: `/sync-status` で監査証跡を自動記録

詳細は [.claude/skills/README.md](.claude/skills/README.md) を参照してください。

## テスト方法

マルチセッションシステムのテスト手順を記載する

## テスト

このシステムのテスト結果

## ドキュメント

- [使い方ガイド](docs/GUIDE.md) - 詳細な使用方法
- [Skills ガイド](.claude/skills/README.md) - Skills の使い方
- [改善計画](improvement/IMPROVEMENT_PLAN.md) - システム改善計画
- [移行ガイド](docs/MIGRATION.md) - ファイル構成の変更履歴

## ライセンス

（ライセンス情報を記載）

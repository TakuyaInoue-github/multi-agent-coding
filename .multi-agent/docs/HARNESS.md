# ハーネス設計ガイド

Claude Code エージェントに安全に作業させるための設定（permissions・hooks・ログ監視）をまとめたドキュメントです。

---

## 構成ファイル一覧

```
.claude/
  settings.json          # Project 設定（Git管理）: permissions + hooks
  settings.local.json    # Local 設定（Git管理外）: 個人・端末固有のみ
  hooks/
    validate-bash.sh     # PreToolUse: 危険 Bash コマンドをブロック
    protect-files.sh     # PreToolUse: 保護ファイルへの書き込みをブロック
    log-activity.sh      # PostToolUse: Bash/Edit/Write 操作をログに記録
    watch-codex.sh       # 手動起動: Codex ジョブの phase 変化をログに記録
  audit/
    activity.log         # エージェントの行動ログ（tail -f で監視）

.multi-agent/roles/
  commander/settings.json  # Commander 固有権限の定義（参照用）
  observer/settings.json   # Observer 固有権限の定義（参照用）
  worker/settings.json     # Worker 固有権限の定義（参照用）
```

---

## permissions 設計

評価順は `deny → ask → allow` で、deny が最優先。

### defaultMode: dontAsk

allow に入っていない操作はデフォルトで拒否。明示的に列挙したものだけ自動実行する。

### allow（自動実行）

| カテゴリ | 内容 |
|---|---|
| ファイル読み取り | `Read(**)` — 全ファイル読み取り |
| Git 読み取り | `git status`, `git diff`, `git log` |
| Git 書き込み | `git add`, `git commit`, `git checkout -b`, `git branch`, `git stash` |
| ファイル操作 | `mkdir *` |
| 検索 | `ls *`, `find *`, `grep *`, `cat *` |
| スクリプト実行 | `bash -n *`（構文チェック）, `bash .multi-agent/scripts/*` |
| Node 実行 | `node *`（Codex plugin が内部で使用） |

`Bash(python *)` / `Bash(python3 *)` は任意コード実行になるため **allow しない**。

### ask（毎回確認）

依存関係変更・git push など、変更範囲が大きく文脈確認が必要な操作。

| 操作 | 理由 |
|---|---|
| `git push *` | リモート状態を変える |
| `git merge *` | ブランチ統合は意図確認が必要 |
| `npm install *` / `pip install *` / `uv add *` | lockfile・環境変更を伴う |

### deny（常に禁止）

| カテゴリ | 例 |
|---|---|
| 破壊的 Git 操作 | `git push --force`, `git reset --hard`, `git clean`, `git checkout -- *` |
| 破壊的削除 | `rm -rf` |
| ネットワーク | `curl`, `wget`, `ssh`, `scp`, `nc`, `netcat`, `rsync` |
| クラウド CLI | `aws`, `gcloud`, `az`, `kubectl` |
| IaC | `terraform apply`, `terraform destroy` |
| 任意コード実行 | `python *`, `python3 *` |
| settings 改ざん | `Edit(.claude/settings.json)`, `Write(.claude/settings.json)` |

---

## hooks 設計

permissions はパターンマッチのため、hooks で二重検査する。

### PreToolUse / validate-bash.sh

Bash 実行前に危険コマンドを検査してブロック（exit 2）。
deny と二重になっており、パターンマッチをすり抜けた場合の最後の砦。

ブロック対象：`rm -rf` / `git push --force` / `git reset --hard` / `git checkout -- .` / `curl` / `wget` / `kubectl` / cloud CLI

### PreToolUse / protect-files.sh

Edit/Write 実行前に保護ファイルへの書き込みをブロック（exit 2）。

ブロック対象：`.env` / `secrets/**` / `.git/` 配下 / `.claude/settings.json`

> **注意:** `.claude/settings.json`（メインプロジェクト直下）のみ保護対象。
> worktree 配下の `.claude/settings.json` は起動スクリプトが管理するため保護対象外。

### PostToolUse / log-activity.sh

Bash/Edit/Write の実行後に `activity.log` へ追記する。

```
[2026-04-26T10:00:01+09:00] BASH exit=0 $ git checkout -b task/task-001
[2026-04-26T10:00:05+09:00] BASH exit=0 $ node .../codex-companion.mjs task ...
[2026-04-26T10:00:10+09:00] Edit src/feature.py
```

---

## ロール別権限設計

### 設計思想

エージェントのロール別権限は **CLAUDE.md の自律制御 + hooks の audit ログ** で補完する。

**なぜ permissions でロール分離しないか:**

- Claude Code の permissions はセッション（ロール）を識別できない
- worktree ごとに settings.json を分離すると `runtime/` / `tasks/` の共有ファイルへの
  パスマッチが絶対パス解決により機能しなくなる
- 全エージェントをメインプロジェクトディレクトリで起動することで共有ファイルの
  アクセス問題を回避している

### ロール別の書き込み権限（CLAUDE.md で定義）

| ファイル | Commander | Observer | Worker |
|---|---|---|---|
| `runtime/BOARD.md` | ✅ | ❌ | ❌ |
| `runtime/CONTEXT.md` | ✅ | ❌ | ❌ |
| `runtime/EVENTLOG.json` | ✅ | ✅ | ❌ |
| `runtime/DISCUSSION.md` | ✅ | ✅ | ❌ |
| `runtime/SUMMARY.md` | ✅ | ✅ | ❌ |
| `tasks/*/spec.md` | ✅ | ❌ | ❌ |
| `tasks/*/commander_review.md` | ✅ | ❌ | ❌ |
| `tasks/*/observer_review.md` | ❌ | ✅ | ❌ |
| `tasks/*/result.md` | ❌ | ❌ | ✅ |
| `tasks/*/.assigned` | ❌ | ❌ | ✅ |
| Git merge / push | ✅ | ❌ | task/* のみ |

### roles/ 配下の settings.json について

`.multi-agent/roles/xxx/settings.json` は各ロールの権限要件を**ドキュメントとして定義**している。
現状は直接適用されていないが、将来的に worktree 活用方式に移行する場合の参照用として管理する。

---

## エージェントの起動方式

### 起動スクリプト

```bash
.multi-agent/scripts/launch-agents-worktree.sh
```

全エージェントをメインプロジェクトディレクトリ（`$PROJECT_DIR`）で起動する。

```
tmux: commander  → claude（$PROJECT_DIR）
tmux: observer   → claude（$PROJECT_DIR）
tmux: worker-1   → claude（$PROJECT_DIR）
```

### worktree の用途

worktree はエージェントの起動ディレクトリとしては使用しない。
**Codex がコード実装を行う際のブランチ分離**にのみ使用する。

---

## エージェントセッションの監視

### ステップ 1: activity.log を流しっぱなしにする

別ターミナルで実行：

```bash
tail -f .claude/audit/activity.log
```

エージェントの Bash/Edit/Write 操作がリアルタイムで流れてくる。

### ステップ 2: Codex ジョブの phase を監視する

さらに別ターミナルで実行：

```bash
.claude/hooks/watch-codex.sh
```

Codex ジョブの状態変化が `activity.log` に追記される：

```
[2026-04-26T10:00:06Z] CODEX job=job-abc new -> running/starting
[2026-04-26T10:00:30Z] CODEX job=job-abc running/starting -> running/generating
[2026-04-26T10:02:15Z] CODEX job=job-abc running/generating -> completed/done
```

### ステップ 3: 各セッションの状態確認

```bash
tmux capture-pane -t commander -p | tail -30
tmux capture-pane -t observer  -p | tail -30
tmux capture-pane -t worker-1  -p | tail -30
```

---

## settings スコープの使い分け

| ファイル | Git管理 | 用途 |
|---|---|---|
| `.claude/settings.json` | する | チーム共有の permissions・hooks |
| `.claude/settings.local.json` | しない（.gitignore済み） | 個人・端末固有の追加設定 |
| `~/.claude/settings.json` | しない | 全プロジェクト共通の個人設定 |
| `.multi-agent/roles/*/settings.json` | する | ロール別権限の定義（参照用） |

`.claude/settings.local.json` に実験的な allow を追加することはできるが、チームに展開したい場合は `settings.json` への PR を出すこと。

---

## 参照ドキュメント

- `.multi-agent/docs/claude-code-permission-allowlist-harness-reference.md` — permissions 設計の詳細リファレンス
- `.multi-agent/docs/CODEX_SETUP.md` — Codex プラグインのセットアップ
- `.multi-agent/docs/MULTI_SESSION_WORKFLOW.md` — マルチセッション全体設計

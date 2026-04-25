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
    activity.log         # Worker の行動ログ（tail -f で監視）
```

---

## permissions 設計

評価順は `deny → ask → allow` で、deny が最優先。

### defaultMode: dontAsk

allow に入っていない操作はデフォルトで拒否。明示的に列挙したものだけ自動実行する。

### allow（自動実行）

| カテゴリ | 内容 |
|---|---|
| Git 読み取り | `git status`, `git diff`, `git log` |
| Git 書き込み | `git add`, `git commit`, `git checkout -b`, `git checkout main/develop` |
| ファイル操作 | `mkdir` |
| Node 実行 | `node *`（codex plugin が内部で使用） |
| Skills | `status-sync`, `gate-evaluation`, `start-task`, `task-decomposition` |
| Codex | `SlashCommand(/codex:rescue:*)` 等 全コマンド、`Skill(codex:*)` |

`Bash(python *)` / `Bash(python3 *)` は任意コード実行になるため **allow しない**。

### ask（毎回確認）

依存関係変更・git push など、変更範囲が大きく文脈確認が必要な操作。

| 操作 | 理由 |
|---|---|
| `npm/pip/uv install` | lockfile・環境変更を伴う |
| `git push` | リモート状態を変える |
| `git merge` | ブランチ統合は意図確認が必要 |

### deny（常に禁止）

| カテゴリ | 例 |
|---|---|
| 破壊的 Git 操作 | `git push --force`, `git reset --hard`, `git clean`, `git checkout -- *` |
| 破壊的削除 | `rm -rf` |
| ネットワーク | `curl`, `wget`, `ssh`, `scp` |
| クラウド CLI | `aws`, `gcloud`, `az`, `kubectl` |
| IaC | `terraform apply`, `terraform destroy` |
| 秘密ファイル | `.env`, `secrets/**` の Read/Edit |

---

## hooks 設計

permissions はパターンマッチのため、hooks で二重検査する。

### PreToolUse / validate-bash.sh

Bash 実行前に危険コマンドを検査してブロック（exit 2）。
deny と二重になっており、パターンマッチをすり抜けた場合の最後の砦。

ブロック対象：`rm -rf` / `git push --force` / `git reset --hard` / `git checkout -- .` / `curl` / `wget` / `kubectl` / cloud CLI

### PreToolUse / protect-files.sh

Edit/Write 実行前に保護ファイルへの書き込みをブロック（exit 2）。
permissions の Read deny だけでは Edit はブロックできないため、hook で補完する。

ブロック対象：`.env` / `secrets/**` / `.git/` 配下 / `.claude/settings.json`

> `.claude/settings.json` 自体もブロック対象のため、設定変更は手動で行う。

### PostToolUse / log-activity.sh

Bash/Edit/Write の実行後に `activity.log` へ追記する。

```
[2026-04-25T10:00:01+09:00] BASH exit=0 $ git checkout -b task/task-001
[2026-04-25T10:00:05+09:00] BASH exit=0 $ node .../codex-companion.mjs task ...
[2026-04-25T10:00:10+09:00] Edit src/feature.py
```

---

## Worker セッションの監視

Worker が何をしているかをリアルタイムで確認する手順。

### ステップ 1: activity.log を流しっぱなしにする

別ターミナルで実行：

```bash
tail -f .claude/audit/activity.log
```

Worker の Bash/Edit/Write 操作がリアルタイムで流れてくる。

### ステップ 2: Codex ジョブの phase を監視する

さらに別ターミナルで実行：

```bash
.claude/hooks/watch-codex.sh
```

Codex ジョブの状態変化が `activity.log` に追記される：

```
[2026-04-25T10:00:06Z] CODEX job=job-abc new -> running/starting
[2026-04-25T10:00:30Z] CODEX job=job-abc running/starting -> running/generating
[2026-04-25T10:02:15Z] CODEX job=job-abc running/generating -> completed/done
```

### ステップ 3: 手動で Codex の詳細を確認する

Worker セッションで随時：

```
/codex:status
```

---

## settings スコープの使い分け

| ファイル | Git管理 | 用途 |
|---|---|---|
| `.claude/settings.json` | する | チーム共有の permissions・hooks |
| `.claude/settings.local.json` | しない（.gitignore済み） | 個人・端末固有の追加設定 |
| `~/.claude/settings.json` | しない | 全プロジェクト共通の個人設定 |

`.claude/settings.local.json` に実験的な allow を追加することはできるが、チームに展開したい場合は `settings.json` への PR を出すこと。

---

## 参照ドキュメント

- `reference/claude-code-permission-allowlist-harness-reference.md` — permissions 設計の詳細リファレンス
- `.multi-agent/docs/CODEX_SETUP.md` — Codex プラグインのセットアップ
- `.multi-agent/docs/MULTI_SESSION_WORKFLOW.md` — マルチセッション全体設計

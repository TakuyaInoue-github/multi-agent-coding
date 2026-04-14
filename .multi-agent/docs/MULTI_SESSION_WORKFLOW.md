# ワークフローガイド

## 概要

Commander / Observer / Worker の3つの役割を**1つの Claude Code セッション**で順番に担いながら、タスクを一気通貫で完了させます。

```
【同一セッション内で役割を切り替えながら進める】

Commander → タスク分解・spec.md 作成
    ↓
Observer  → Gate1 評価
    ↓
Worker    → Codex に実装を委譲
    ↓
Commander → 一次評価・commander_review.md 作成
    ↓
Observer  → Gate2 評価
    ↓
Commander → base_branch にマージ
```

エージェント間の連携はすべて `runtime/` と `tasks/` のファイル経由で行います。

---

## 事前準備

### 1. Codex Plugin のセットアップ（初回のみ）

Worker が実装を委譲するため、Codex Plugin が必要です：

```bash
/plugin marketplace add openai/codex-plugin-cc
/plugin install codex@openai-codex
/reload-plugins
/codex:setup
```

**認証**:
- ChatGPT Plus サブスクリプション、または
- `export OPENAI_API_KEY="sk-..."` で API キーを設定

詳細は `.multi-agent/docs/CODEX_SETUP.md` を参照してください。

### 2. runtime/ の初期化（セッション開始時）

`runtime/BOARD.md` と `runtime/CONTEXT.md` が存在しない場合は作成します：

**runtime/BOARD.md**:
```yaml
session_id: session-001
base_branch: develop
base_branch_created_by: user
started_at: YYYY-MM-DDTHH:MM:SS
tasks: []
```

**runtime/CONTEXT.md**:
```markdown
## プロジェクト方針
（ユーザーから受けた指示・全体目標）

## 技術スタック
language: Python  # または TypeScript / Go / Java
```

---

## ワークフロー

### Step 1: Commander — タスク分解

```
.multi-agent/roles/commander/CLAUDE.md を読んで、セッション開始手順に従ってください。
今回のタスクは：（ユーザーの指示）
```

Commander が以下を実行します：
1. `runtime/CONTEXT.md` / `runtime/BOARD.md` を読む
2. タスクを分解して `tasks/task-xxx/spec.md` を作成
3. `tasks/task-xxx/AGENTS.md` を作成（Codex向け）
4. `/sync-status` で `runtime/BOARD.md` を更新

### Step 2: Observer — Gate1 評価

```
.multi-agent/roles/observer/CLAUDE.md を読んで、task-xxx の Gate1 評価を実施してください。
```

Observer が `tasks/task-xxx/observer_review.md` を作成します。

- **Pass** → Step 3 へ
- **Fail** → Commander に差し戻し → spec.md を修正して Step 2 に戻る

### Step 3: Worker — 実装

```
.multi-agent/roles/worker/CLAUDE.md を読んで、task-xxx を実行してください。
```

Worker が以下を実行します：
1. `tasks/task-xxx/spec.md` と `tasks/task-xxx/AGENTS.md` を読む
2. `task/task-xxx` ブランチを作成
3. `/codex:rescue` で Codex に実装を委譲
4. 完了後 `tasks/task-xxx/result.md` を作成

### Step 4: Commander — 一次評価

```
task-xxx の Worker 実装が完了しました。一次評価を実施してください。
```

Commander が `tasks/task-xxx/commander_review.md` を作成します。

### Step 5: Observer — Gate2 評価

```
task-xxx の Gate2 評価を実施してください。
```

- **Pass** → Step 6 へ
- **Fail** → Commander に差し戻し → Worker に再実装を依頼して Step 3 に戻る

### Step 6: Commander — マージ

```
task-xxx の Gate2 が Pass しました。base_branch にマージしてください。
```

Commander が `task/task-xxx` → `base_branch` にマージし、`/sync-status` でステータスを `completed` に更新します。

---

## 複数タスクの並列実行

依存関係のないタスクは並列で進められます。`spec.md` の `parallel_ok: true` のタスクが対象です。

```
task-001 (parallel_ok: true) ─┐
task-002 (parallel_ok: true) ─┼─ 同時に Worker に委譲できる
task-003 (depends_on: [001])  ─┘ ← 001完了後に着手
```

Codex への委譲は `--background` で非同期実行できるため、並列タスクは順番に `/codex:rescue --background` で投げて、完了を待つことができます。

---

## セッション中断・再開

### 中断時

Commander に以下を依頼します：
```
ここで一旦止めてください。runtime/CONTEXT.md を更新して終了してください。
```

### 再開時

```
.multi-agent/roles/commander/CLAUDE.md を読んで、前回の続きから再開してください。
```

Commander が `runtime/CONTEXT.md` → `runtime/BOARD.md` → `runtime/EVENTLOG.json` の順で状態を復元します。

---

## 将来対応: マルチセッション起動

現在は1セッションで全役割を担う構成ですが、将来的には tmux を使った複数セッション同時起動（Commander・Observer・Worker が独立して自律動作）に対応予定です。

---

## 関連ドキュメント

- [使い方ガイド](GUIDE.md) - セットアップ・ファイル構成の詳細
- [Codex セットアップ](CODEX_SETUP.md) - Worker の Codex 統合
- [ブランチ管理戦略](BRANCH_STRATEGY.md) - Git ブランチ運用ルール

# マルチセッションワークフローガイド

## 概要

Commander / Observer / Worker の3つの役割を**独立した Claude Code セッション**で自律動作させ、タスクを並列・継続的に処理します。

```
Commander (tmux: commander)
  → タスク分解・Worker への着手許可・一次評価・マージ
  → /loop でファイル変更を監視し、次のアクションを自律判断

Observer  (tmux: observer)
  → Gate1 / Gate2 評価・タイムアウト検知
  → /loop で spec.md / commander_review.md の出現を監視

Worker-N  (tmux: worker-1, worker-2, ...)
  → Codex への実装委譲・result.md 作成
  → /loop で着手許可済みタスクを監視し、空きがあれば取得
```

エージェント間の連携はすべて `runtime/` と `tasks/` のファイル経由で行います。

---

## アーキテクチャ

### ファイルベース連携フロー

```
[Commander]                  [Observer]                  [Worker]
    |                            |                           |
    | spec.md を作成              |                           |
    |─────────────────────────>  |                           |
    |                       Gate1 評価                       |
    |  <─────────────────────────|                           |
    |                            |                           |
    | BOARD.md status: approved  |                           |
    |────────────────────────────────────────────────────>   |
    |                            |                   .assigned 作成 +
    |                            |                   実装開始
    |                            |                           |
    | result.md を確認            |                           |
    | commander_review.md 作成   |                           |
    |─────────────────────────>  |                           |
    |                       Gate2 評価                       |
    |  <─────────────────────────|                           |
    |                            |                           |
    | base_branch にマージ        |                           |
```

### ロック機構

タスクの競合取得を防ぐため、BOARD.md の論理ロックと `.assigned` ファイルの物理ロックを併用します。

```
tasks/task-xxx/
  spec.md              ← Commander が作成
  .assigned            ← Worker が作成（ロック取得）。中身: worker-id と取得時刻
  result.md            ← Worker が作成（完了時）
  observer_review.md   ← Observer が作成
  commander_review.md  ← Commander が作成
```

| ロック操作 | 担当 | 手順 |
|-----------|------|------|
| ロック取得 | Worker | `.assigned` ファイルを作成し、読み返して自分の worker-id が入っていれば成功 |
| ロック解放（正常） | Worker | `result.md` 作成後に `.assigned` を削除 |
| ロック解放（タイムアウト） | Observer | `worker_timeout_hours` 経過かつ `result.md` 未作成なら `.assigned` を削除し EVENTLOG に記録 |
| status 更新 | Commander | BOARD.md の `status` フィールドを更新（Worker は直接書かない） |

---

## セットアップ

### 前提条件

- tmux がインストールされていること
- Claude Code CLI (`claude`) が使えること
- Codex Plugin がセットアップ済みであること（Worker のみ）

Codex Plugin のセットアップは `.multi-agent/docs/CODEX_SETUP.md` を参照してください。

### 起動手順

```bash
# 1. runtime/ を初期化
./scripts/setup.sh

# 2. エージェントを起動（tmux セッションを3つ作成）
./.multi-agent/scripts/launch-agents-worktree.sh

# 3. 各セッションに接続して /loop を開始
tmux attach-session -t commander
# Commander セッションで:
# /loop 5m commander のループプロンプト（後述）

# Ctrl+B → D でデタッチ後:
tmux attach-session -t observer
# Observer セッションで:
# /loop 5m observer のループプロンプト（後述）

# Ctrl+B → D でデタッチ後:
tmux attach-session -t worker-1
# Worker セッションで:
# /loop 5m worker のループプロンプト（後述）
```

### /loop 起動プロンプト

各セッションで以下のプロンプトを使って `/loop` を開始します。

**Commander:**
```
/loop 5m .multi-agent/roles/commander/CLAUDE.md を読んで自律ループを実行してください。runtime/BOARD.md と runtime/EVENTLOG.json を確認し、次に取るべきアクションがあれば実行してください。
```

**Observer:**
```
/loop 5m .multi-agent/roles/observer/CLAUDE.md を読んで自律チェックを実行してください。未評価の spec.md と commander_review.md を探し、あれば評価を実施してください。
```

**Worker:**
```
/loop 5m .multi-agent/roles/worker/CLAUDE.md を読んで自律ループを実行してください。BOARD.md で approved かつ .assigned が存在しないタスクを探し、あれば .assigned を作成して実装を開始してください。
```

---

## ワークフロー詳細

### Step 1: Commander — タスク分解

ユーザーが Commander セッションに指示を出すか、Commander が自律ループ中に未処理タスクを検出します。

1. `runtime/CONTEXT.md` / `runtime/BOARD.md` を読む
2. タスクを分解して `tasks/task-xxx/spec.md` を作成
3. `tasks/task-xxx/AGENTS.md` を作成（Codex 向け）
4. BOARD.md の `status` を `pending` に更新
5. EVENTLOG に `task_created` を記録

→ Observer が spec.md の出現を検知して自律的に Gate1 評価を開始

### Step 2: Observer — Gate1 評価

Observer の `/loop` が `spec.md` 存在 + `observer_review.md(gate1)` 未作成を検知します。

1. `spec.md` を読んで RULEBOOK に従い評価
2. `tasks/task-xxx/observer_review.md` を作成（`gate: 1`）
3. EVENTLOG に記録
4. verdict に応じて:
   - **pass**: BOARD.md の `status` を `approved` に更新（Commander 経由）
   - **fail**: `runtime/DISCUSSION.md` に起票 → Commander が検知して対応

### Step 3: Worker — 実装

Worker の `/loop` が `status: approved` + `.assigned` 未作成を検知します。

1. `tasks/task-xxx/.assigned` を作成（`worker_id: worker-1`, `acquired_at: timestamp`）
2. 読み返して自分の worker-id が入っていることを確認（ロック確認）
3. `task/task-xxx` ブランチを作成
4. `/codex:rescue --background` で Codex に実装を委譲
5. 完了後 `tasks/task-xxx/result.md` を作成
6. `.assigned` を削除（ロック解放）

→ Commander が result.md の出現を検知して自律的に一次評価を開始

### Step 4: Commander — 一次評価

Commander の `/loop` が `result.md` 存在 + `commander_review.md` 未作成を検知します。

1. `spec.md` と `result.md` を突き合わせる
2. `output_artifacts` の存在を確認
3. `tasks/task-xxx/commander_review.md` を作成
4. EVENTLOG に記録

→ Observer が commander_review.md の出現を検知して自律的に Gate2 評価を開始

### Step 5: Observer — Gate2 評価

Observer の `/loop` が `commander_review.md` 存在 + `observer_review.md(gate2)` 未作成を検知します。

1. `spec.md` / `result.md` / `commander_review.md` を読む
2. 言語固有の品質チェックを実行
3. `tasks/task-xxx/observer_review.md` を作成（`gate: 2`）
4. verdict に応じて:
   - **pass**: EVENTLOG に記録（Commander がマージ）
   - **fail**: `runtime/DISCUSSION.md` に起票

### Step 6: Commander — マージ

Commander の `/loop` が Gate2 pass を検知します。

1. `task/task-xxx` → `base_branch` にマージ
2. BOARD.md の `status` を `completed` に更新
3. EVENTLOG に `task_completed` を記録

---

## 複数タスクの並列実行

`parallel_ok: true` のタスクは複数 Worker が同時に処理できます。

```
task-001 (parallel_ok: true) ─┐
task-002 (parallel_ok: true) ─┼─ worker-1, worker-2 が同時に .assigned を取得
task-003 (depends_on: [001])  ─┘ ← task-001 の status: completed 後に approved になる
```

Worker を増やす場合は起動スクリプトで `worker-2`, `worker-3` セッションを追加します。

---

## タイムアウトとエラー処理

| 状況 | 検知 | 対処 |
|-----|------|------|
| Worker がクラッシュ | Observer: `worker_timeout_hours` 経過 + `result.md` 未作成 | `.assigned` を削除 → 別 Worker が再取得 |
| Codex が繰り返し失敗 | Worker: 3回以上エラー | `result.md` に `status: blocked` で記録 → Commander が検知して対応 |
| Observer が応答しない | Commander: `observer_timeout_hours` 経過 | EVENTLOG に記録 → ユーザーに通知 |
| Commander が議論に応答しない | Observer: `commander_response_hours` 経過 | `commander_timeout` を記録 → ユーザーに直接通知 |

---

## セッション中断・再開

### 中断時

各セッションで `/loop` を停止（Ctrl+C）します。Commander に以下を依頼します：

```
ここで一旦止めてください。runtime/CONTEXT.md を更新して終了してください。
```

### 再開時

各セッションで再度 `/loop` プロンプトを実行します。

```
/loop 5m .multi-agent/roles/commander/CLAUDE.md を読んで自律ループを実行してください。...
```

Commander は `runtime/CONTEXT.md` → `runtime/BOARD.md` → `runtime/EVENTLOG.json` の順で状態を復元し、中断前の続きから再開します。

---

## 関連ドキュメント

- [使い方ガイド](GUIDE.md) - セットアップ・ファイル構成の詳細
- [Codex セットアップ](CODEX_SETUP.md) - Worker の Codex 統合
- [ブランチ管理戦略](BRANCH_STRATEGY.md) - Git ブランチ運用ルール

---
name: sync-status
description: runtime/ファイル（BOARD.md, EVENTLOG.json）を現在のタスク状態で更新し監査証跡を作成
disable-model-invocation: false
user-invocable: true
allowed-tools: [editor, bash]
---

# ステータス同期 Skill

runtime/ ディレクトリの一貫性を維持し、監査証跡を作成します。

## 使用方法

```bash
/sync-status sync-board task-001 '{"status":"in_progress","assigned_at":"2025-04-04T10:30:00"}'
/sync-status append-event task-001 '{"action":"task_assigned","severity":"null"}'
/sync-status update-context '{"key":"decision_1","value":"方針決定内容"}'
```

## 引数

- `$0` = action_type（sync-board | append-event | update-context）
- `$1` = task_id（update-context 以外）
- `$2` = details_json（JSON形式の詳細情報）

## アクション種別

### 1. sync-board

`runtime/BOARD.md` のタスク状態を更新します。

**使用例:**

```bash
/sync-status sync-board task-001 '{"status":"in_progress","assigned_at":"2025-04-04T10:30:00"}'
/sync-status sync-board task-002 '{"status":"completed","completed_at":"2025-04-04T12:00:00"}'
/sync-status sync-board task-003 '{"status":"blocked","blocked_reason":"task-001 failed"}'
```

**更新対象フィールド:**

- `tasks[task_id].status`: pending | in_progress | completed | failed | blocked | suspended
- `tasks[task_id].assigned_at`: ISO8601 timestamp
- `tasks[task_id].started_at`: ISO8601 timestamp
- `tasks[task_id].completed_at`: ISO8601 timestamp
- `tasks[task_id].failed_at`: ISO8601 timestamp
- `tasks[task_id].blocked_reason`: string
- `tasks[task_id].attempt`: integer

**YAML構造例:**

```yaml
tasks:
  task-001:
    task_id: task-001
    name: "タスク名"
    status: in_progress
    depends_on: []
    parallel_ok: true
    assigned_at: "2025-04-04T10:30:00"
    started_at: "2025-04-04T10:35:00"
    completed_at: null
    attempt: 1
```

**実行手順:**

1. `runtime/BOARD.md` を読み込む
2. YAML frontmatter を解析
3. `tasks[task_id]` を更新
4. YAML frontmatter を再構築
5. `runtime/BOARD.md` に書き込む
6. 変更内容を `runtime/EVENTLOG.json` に記録

### 2. append-event

`runtime/EVENTLOG.json` にイベントを追加します。

**使用例:**

```bash
/sync-status append-event task-001 '{"action":"task_created","actor":"commander","severity":"null","detail":"タスク作成完了"}'
/sync-status append-event task-002 '{"action":"gate1_fail","actor":"observer","severity":"critical","detail":"output_artifacts重複"}'
```

**必須フィールド:**

```json
{
  "action": "task_created|task_assigned|task_completed|gate1_pass|gate1_fail|...",
  "actor": "commander|observer|worker",
  "severity": "critical|major|minor|null",
  "detail": "自然言語での説明"
}
```

**自動生成フィールド:**

- `event_id`: evt-{timestamp}-{random}
- `timestamp`: ISO8601（現在時刻）
- `session_id`: 現在のセッションID（`runtime/BOARD.md` から取得）
- `task_id`: $1
- `related_events`: []（オプション、$2に含めることも可能）
- `retry_count`: 0（オプション）
- `tokens_used`: 0（オプション）

**完全なイベント構造例:**

```json
{
  "event_id": "evt-20250404103000-abc123",
  "timestamp": "2025-04-04T10:30:00",
  "session_id": "session-001",
  "actor": "commander",
  "action": "task_created",
  "task_id": "task-001",
  "related_events": [],
  "severity": null,
  "trigger": null,
  "retry_count": 0,
  "tokens_used": 0,
  "detail": "タスク task-001 を作成: OAuth2認証実装"
}
```

**実行手順:**

1. `runtime/EVENTLOG.json` を読み込む
2. 新しいイベントオブジェクトを作成
3. 必須フィールドを $2 から取得
4. 自動生成フィールドを生成
5. イベント配列に追加
6. `runtime/EVENTLOG.json` に書き込む

### 3. update-context

`runtime/CONTEXT.md` の判断基準や方針を更新します。

**使用例:**

```bash
/sync-status update-context '{"section":"現時点の判断基準","content":"Gate1でのenvironment_verified不整合問題を解決: spec.mdを唯一の情報源とする"}'
/sync-status update-context '{"section":"未解決事項","content":"task-003がブロック中: task-001の完了待ち"}'
```

**更新対象セクション:**

- `現時点の判断基準`
- `未解決事項`
- `次セッションへの申し送り`

**実行手順:**

1. `runtime/CONTEXT.md` を読み込む
2. 指定されたセクションを特定
3. 新しい内容を追記または更新
4. `runtime/CONTEXT.md` に書き込む
5. 変更内容を `runtime/EVENTLOG.json` に記録

## action種別の対応表

| アクション | 目的 | Commander | Observer | Worker |
|-----------|------|-----------|----------|--------|
| sync-board | タスク状態の更新 | ✅ | ❌ | ❌ |
| append-event | イベント記録 | ✅ | ✅ | ❌ |
| update-context | 方針・判断基準の記録 | ✅ | ❌ | ❌ |

## イベントアクション種別

### Commander が記録するアクション

- `session_start` - セッション開始
- `session_end` - セッション終了
- `task_created` - タスク作成
- `task_assigned` - Workerにタスク割り当て
- `task_retry` - タスク再試行
- `task_completed` - タスク完了
- `task_failed` - タスク失敗
- `task_blocked` - タスクブロック
- `task_suspended` - タスク中断
- `discussion_start` - 議論開始
- `discussion_round` - 議論ラウンド
- `discussion_resolved` - 議論解決
- `discussion_escalated` - ユーザーへ上告
- `user_instruction` - ユーザー指示受領
- `user_decision` - ユーザー決定受領
- `user_interrupt` - ユーザー強制中断
- `branch_reset` - ブランチリセット

### Observer が記録するアクション

- `gate1_pass` - Gate1 評価パス
- `gate1_fail` - Gate1 評価フェイル
- `gate1_warning` - Gate1 評価警告
- `gate2_pass` - Gate2 評価パス
- `gate2_fail` - Gate2 評価フェイル
- `gate2_warning` - Gate2 評価警告
- `worker_timeout` - Worker タイムアウト
- `observer_timeout` - Observer 自身のタイムアウト
- `commander_timeout` - Commander タイムアウト
- `unevaluated_detected` - 未評価タスク検出
- `discussion_start` - 議論開始（failによる起票）
- `discussion_round` - 議論ラウンド

## 整合性保証

すべてのアクションは以下を保証します：

### 1. データ整合性

- **YAML/JSON妥当性**: 書き込み前に構文チェック
- **スキーマ準拠**: 必須フィールドの存在確認
- **型チェック**: フィールド型の検証

### 2. バックアップ

- **変更前バックアップ**: `.bak` ファイルを作成
- **ロールバック可能**: エラー時は元に戻す

### 3. 監査証跡

- **すべての変更を記録**: EVENTLOG.json に記録
- **誰が・いつ・何を**: actor, timestamp, detail を記録
- **変更の連鎖**: related_events で関連イベントをリンク

## エラーハンドリング

### ファイルが存在しない

```
Error: runtime/BOARD.md が存在しません
Action: templates/session/BOARD.md から初期化するか、ユーザーに確認
```

### YAML/JSON解析エラー

```
Error: runtime/BOARD.md のYAML解析に失敗しました
Action: バックアップから復元、または手動修正を促す
```

### task_id が存在しない

```
Error: task-999 が BOARD.md に存在しません
Action: タスクを先に作成するか、task_id を確認
```

### 不正なステータス遷移

```
Error: status を completed から in_progress に戻すことはできません
Action: 現在のステータスを確認、または再試行の場合は attempt をインクリメント
```

## 使用例

### タスク作成フロー

```bash
# 1. タスクを BOARD.md に追加
/sync-status sync-board task-001 '{"status":"pending","assigned_at":null}'

# 2. イベントを記録
/sync-status append-event task-001 '{"action":"task_created","actor":"commander","severity":"null","detail":"OAuth2認証の実装タスクを作成"}'
```

### Gate1 評価フロー

```bash
# Observer が Gate1 で fail を出した場合
/sync-status append-event task-001 '{"action":"gate1_fail","actor":"observer","severity":"critical","detail":"output_artifacts が task-002 と重複"}'
```

### タスク完了フロー

```bash
# 1. タスクを完了に更新
/sync-status sync-board task-001 '{"status":"completed","completed_at":"2025-04-04T15:00:00"}'

# 2. イベントを記録
/sync-status append-event task-001 '{"action":"task_completed","actor":"commander","severity":"null","detail":"task-001 完了: OAuth2認証実装"}'

# 3. CONTEXT.md に記録
/sync-status update-context '{"section":"現時点の判断基準","content":"task-001完了: OAuth2認証は bcrypt@5.0.0 を使用する方針"}'
```

### 議論フロー

```bash
# Observer が fail を起票
/sync-status append-event task-001 '{"action":"discussion_start","actor":"observer","severity":"major","detail":"Gate1 fail: output_artifacts 重複問題について議論開始"}'

# Commander が応答
/sync-status append-event task-001 '{"action":"discussion_round","actor":"commander","severity":"major","detail":"Round 1: task-002 を depends_on に追加する方針で対応"}'

# Observer が受け入れ
/sync-status append-event task-001 '{"action":"discussion_resolved","actor":"observer","severity":"null","detail":"Commander の修正を受け入れ、再評価実施"}'
```

## マルチエージェントシステムとの統合

### Commanderの使用タイミング

1. **タスク作成時**: sync-board + append-event
2. **Worker割り当て時**: sync-board (status=in_progress) + append-event
3. **Gate評価後**: append-event（observerが実施）
4. **タスク完了時**: sync-board (status=completed) + append-event
5. **方針決定時**: update-context
6. **セッション終了時**: append-event (session_end) + update-context

### Observerの使用タイミング

1. **Gate1/Gate2評価後**: append-event (gate{1|2}_{pass|fail|warning})
2. **fail起票時**: append-event (discussion_start)
3. **議論ラウンド**: append-event (discussion_round)
4. **タイムアウト検知時**: append-event (worker_timeout | commander_timeout)

## 自己チェックリスト

status-sync 実行後、以下を確認：

- [ ] ファイルが正しく更新されている
- [ ] YAML/JSON構文が妥当である
- [ ] バックアップファイルが作成されている
- [ ] EVENTLOG.json に変更が記録されている
- [ ] タイムスタンプが正確である
- [ ] エラーメッセージが明確である（エラー時）

## 関連ドキュメント

- `runtime/BOARD.md` - タスク状態管理の実体
- `runtime/EVENTLOG.json` - イベント記録の実体
- `runtime/CONTEXT.md` - 方針・判断基準の実体
- `config/RULEBOOK.md` - イベント記録の基準

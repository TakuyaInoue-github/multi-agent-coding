# マルチセッションワークフロー

複数のClaude Codeセッションを使用してマルチエージェントシステムを実行するためのガイドです。

## 概要

このシステムでは、3種類のエージェントが**ファイルを介して**連携します：

```
Commander (セッション1)  →  spec.md を作成
    ↓
Observer (セッション2)   →  spec.md を評価 (Gate1)
    ↓
Worker (セッション3+)    →  spec.md を読んで実装、result.md を作成
    ↓
Commander (セッション1)  →  result.md を評価
    ↓
Observer (セッション2)   →  result.md を評価 (Gate2)
    ↓
Commander (セッション1)  →  マージ
```

すべての連携は**ファイル経由**で行われ、セッション間で直接通信はしません。

## セットアップ

### 1. システム起動

#### 方法A: tmux自動起動スクリプト（推奨）

```bash
# すべてのエージェントを一度に起動
./scripts/launch-agents-worktree.sh
```

#### 方法B: 手動起動

```bash
# ターミナル1: Commander
cd /path/to/multi-agent
tmux new-session -s commander
# セッション内で:
cat .multi-agent/roles/commander/CLAUDE.md  # プロンプトを確認
claude

# ターミナル2: Observer
cd /path/to/multi-agent
tmux new-session -s observer
# セッション内で:
cat .multi-agent/roles/observer/CLAUDE.md  # プロンプトを確認
claude

# ターミナル3: Worker-1
cd /path/to/multi-agent
tmux new-session -s worker-1
# セッション内で:
cat .multi-agent/roles/worker/CLAUDE.md  # プロンプトを確認
claude
```

### 2. セッション間の切り替え

```bash
# セッション一覧を表示
tmux list-sessions

# Commanderに接続
tmux attach-session -t commander

# セッションからデタッチ（Ctrl+B then D）

# Observerに切り替え
tmux attach-session -t observer

# Worker-1に切り替え
tmux attach-session -t worker-1
```

### 3. 初回セットアップ

各セッションの最初のメッセージとして、対応するCLAUDE.mdの内容を伝えます：

**Commander セッション:**
```
.multi-agent/roles/commander/CLAUDE.md の内容全体を貼り付け
```

**Observer セッション:**
```
.multi-agent/roles/observer/CLAUDE.md の内容全体を貼り付け
```

**Worker セッション:**
```
.multi-agent/roles/worker/CLAUDE.md の内容全体を貼り付け
```

### 4. Codex Plugin のセットアップ（Worker のみ）

**重要**: Worker は実装タスクを Codex に委譲します。初回のみ以下のセットアップが必要です。

#### Worker セッションで実行

```bash
# 1. マーケットプレイスを追加
/plugin marketplace add openai/codex-plugin-cc

# 2. プラグインをインストール
/plugin install codex@openai-codex

# 3. プラグインをリロード
/reload-plugins

# 4. セットアップを実行
/codex:setup
```

#### 認証設定

`/codex:setup` を実行すると認証方法を選択できます：

**オプション A: ChatGPT Plus サブスクリプション**
- ブラウザで認証プロセスが開始されます

**オプション B: OpenAI API キー**
```bash
export OPENAI_API_KEY="sk-..."
```

#### 設定ファイルの確認

プロジェクトルートの `.codex/config.toml` を確認してください：

```toml
model = "gpt-4o"               # 使用する Codex モデル
default_background = true      # バックグラウンド実行
timeout = 3600                 # タイムアウト（秒）
log_level = "info"             # ログレベル
```

詳細は `.multi-agent/docs/CODEX_SETUP.md` を参照してください。

#### 動作確認

簡単なテストを実行：

```bash
/codex:rescue "Create a hello.js file that prints 'Hello, World!'"
```

成功すれば Codex のセットアップは完了です。

---

## ワークフロー

### フェーズ1: タスク分解（Commander）

1. **Commanderセッションに接続:**
   ```bash
   tmux attach-session -t commander
   ```

2. **ユーザー指示を受ける:**
   ```
   ユーザー: 「ユーザー認証機能を追加してください」
   ```

3. **タスク分解を実行:**
   ```
   Commander: /decompose-task "ユーザー認証機能を追加" "web-app"
   ```

   または自然言語で:
   ```
   Commander: このタスクを分解して、tasks/task-001/spec.md を作成してください
   ```

4. **spec.mdの作成:**
   Commander が `tasks/task-001/spec.md` を作成します。

5. **BOARD.mdの更新:**
   ```
   Commander: /sync-status sync-board task-001 '{"status":"pending"}'
   ```

6. **EVENTLOGへの記録:**
   ```
   Commander: /sync-status append-event task-001 '{"action":"task_created","actor":"commander","severity":"null","detail":"OAuth2認証実装タスクを作成"}'
   ```

7. **デタッチ:**
   Ctrl+B then D でセッションからデタッチ

### フェーズ2: Gate1評価（Observer）

1. **Observerセッションに接続:**
   ```bash
   tmux attach-session -t observer
   ```

2. **自律チェックを指示:**
   ```
   Observer: runtime/BOARD.md を確認して、新しいタスクがあればGate1評価を実行してください
   ```

   または直接:
   ```
   Observer: /evaluate-gate 1 task-001 spec_review
   ```

3. **評価結果の確認:**
   Observer が `tasks/task-001/observer_review.md` を作成します。

4. **結果に応じた処理:**

   **Pass の場合:**
   ```
   Observer: /sync-status append-event task-001 '{"action":"gate1_pass","actor":"observer","severity":"null","detail":"Gate1評価パス"}'
   ```

   **Fail の場合:**
   ```
   Observer: runtime/DISCUSSION.md に問題を起票してください
   Observer: /sync-status append-event task-001 '{"action":"gate1_fail","actor":"observer","severity":"critical","detail":"output_artifacts重複"}'
   ```

5. **デタッチ:**
   Ctrl+B then D

### フェーズ3: 議論（Commander ⇔ Observer）

**Fail の場合のみ:**

1. **Commanderセッションに戻る:**
   ```bash
   tmux attach-session -t commander
   ```

2. **DISCUSSION.mdを確認:**
   ```
   Commander: runtime/DISCUSSION.md を読んで、Observerの指摘に対応してください
   ```

3. **修正を実施:**
   ```
   Commander: tasks/task-001/spec.md を修正します
   ```

4. **再評価を依頼:**
   Observerセッションに切り替えて再評価

### フェーズ4: Worker着手許可（Commander）

Gate1がPassした後:

1. **Commanderセッションで:**
   ```
   Commander: /sync-status sync-board task-001 '{"status":"in_progress","assigned_at":"2025-04-04T10:30:00"}'
   Commander: /sync-status append-event task-001 '{"action":"task_assigned","actor":"commander","severity":"null","detail":"Worker-1に着手許可"}'
   ```

2. **Worker-1に通知:**
   Workerセッションに切り替えて作業開始を指示

### フェーズ5: 実装（Worker）

1. **Worker-1セッションに接続:**
   ```bash
   tmux attach-session -t worker-1
   ```

2. **spec.mdを読む:**
   ```
   Worker: tasks/task-001/spec.md を読んで、作業を開始してください
   ```

3. **ブランチ作成:**
   ```
   Worker: task/task-001 ブランチを作成してください
   ```

4. **実装:**
   Workerが指示に従ってコーディング

5. **中間報告（オプション）:**
   ```
   Worker: tasks/task-001/result.md に中間報告を記録してください
   ```

6. **完了:**
   ```
   Worker: 実装が完了しました。result.md を最終報告として更新してください
   ```

7. **コミット:**
   ```
   Worker: git commit -m "feat: task-001 OAuth2認証実装"
   ```

8. **デタッチ:**
   Ctrl+B then D

### フェーズ6: Commander一次評価

1. **Commanderセッションで:**
   ```
   Commander: tasks/task-001/result.md を確認して、commander_review.md を作成してください
   ```

2. **レビュー作成:**
   Commander が `tasks/task-001/commander_review.md` を作成

3. **イベント記録:**
   ```
   Commander: /sync-status append-event task-001 '{"action":"task_completed","actor":"commander","severity":"null","detail":"Commander一次評価完了"}'
   ```

### フェーズ7: Gate2評価（Observer）

1. **Observerセッションで:**
   ```
   Observer: /evaluate-gate 2 task-001 result_review
   ```

2. **評価結果:**
   Observer が `tasks/task-001/observer_review.md` を更新

3. **Pass の場合:**
   ```
   Observer: /sync-status append-event task-001 '{"action":"gate2_pass","actor":"observer","severity":"null","detail":"Gate2評価パス"}'
   ```

### フェーズ8: マージ（Commander）

Gate2がPassした後:

1. **Commanderセッションで:**
   ```
   Commander: task/task-001 ブランチを master にマージしてください
   ```

2. **ステータス更新:**
   ```
   Commander: /sync-status sync-board task-001 '{"status":"completed","completed_at":"2025-04-04T15:00:00"}'
   ```

3. **コンテキスト更新:**
   ```
   Commander: /sync-status update-context '{"section":"現時点の判断基準","content":"task-001完了: OAuth2認証はbcrypt@5.0.0を使用"}'
   ```

## ファイルベース連携の仕組み

### 共有ファイル

すべてのセッションが以下のファイルを共有します：

| ファイル | 役割 | 読み書き権限 |
|---------|------|------------|
| `runtime/BOARD.md` | タスク状態管理 | Commander: R/W, Observer: R, Worker: R |
| `runtime/CONTEXT.md` | 方針・判断基準 | Commander: R/W, Observer: R, Worker: R |
| `runtime/DISCUSSION.md` | 議論ログ | Commander: R/W, Observer: R/W, Worker: R |
| `runtime/EVENTLOG.json` | イベント記録 | Commander: R/W, Observer: R/W, Worker: R |
| `runtime/SUMMARY.md` | 進捗サマリー | Commander: R/W, Observer: R/W, Worker: R |
| `tasks/task-xxx/spec.md` | タスク仕様 | Commander: W, Observer: R, Worker: R |
| `tasks/task-xxx/result.md` | 実装結果 | Commander: R, Observer: R, Worker: W |
| `tasks/task-xxx/commander_review.md` | Commander評価 | Commander: W, Observer: R, Worker: R |
| `tasks/task-xxx/observer_review.md` | Observer評価 | Commander: R, Observer: W, Worker: R |

### ポーリングパターン

各エージェントは定期的にファイルの変更をチェックします：

**Commander:**
- `tasks/task-xxx/result.md` の完了を待つ（5分ごと）
- `runtime/DISCUSSION.md` のObserver応答を待つ（2分ごと）

**Observer:**
- `tasks/task-xxx/spec.md` の作成を検知（自律チェック）
- `tasks/task-xxx/commander_review.md` の作成を検知（自律チェック）
- タイムアウトを検知（1時間ごと）

**Worker:**
- `tasks/task-xxx/spec.md` の割り当てを待つ（BOARD.md を確認）

### ファイルロック規約

複数セッションが同じファイルを編集する場合、以下の規約に従います：

1. **読み込み専用ファイル:**
   - `spec.md`: Workerは読み込みのみ
   - `result.md`: Commander/Observerは読み込みのみ

2. **追記のみファイル:**
   - `DISCUSSION.md`: 常に末尾に追記
   - `EVENTLOG.json`: 常に配列の末尾に追加

3. **排他的書き込み:**
   - `BOARD.md`: Commander のみが更新
   - 同時編集が発生した場合は git の merge conflict として解決

## トラブルシューティング

### セッションが見つからない

```bash
tmux list-sessions
```

セッションがない場合は再起動:
```bash
./scripts/launch-agents-worktree.sh
```

### ファイルが見つからない

**runtime/ ファイルが存在しない:**
```bash
./scripts/launch-agents-worktree.sh
```
起動スクリプトが自動的に作成します。

### 競合が発生した

```bash
# 手動でマージ
git status
git add .
git commit -m "Merge conflict resolution"
```

### Observer が反応しない

Observerセッションに接続して手動で確認:
```bash
tmux attach-session -t observer
```

```
Observer: runtime/BOARD.md を確認して、未評価のタスクがあれば評価してください
```

### Worker が作業を開始しない

Workerセッションで spec.md を確認:
```bash
tmux attach-session -t worker-1
```

```
Worker: tasks/ ディレクトリを確認して、自分に割り当てられたタスクがあるか確認してください
```

## ベストプラクティス

### 1. セッションの命名規則

- `commander`: 常に1つ
- `observer`: 常に1つ
- `worker-N`: 複数可能（worker-1, worker-2, ...）

### 2. 作業の可視化

定期的に BOARD.md を確認:
```bash
cat runtime/BOARD.md
```

### 3. ログの確認

EVENTLOG.json で全履歴を確認:
```bash
cat runtime/EVENTLOG.json | jq '.'
```

最新10件のイベント:
```bash
cat runtime/EVENTLOG.json | jq '.[-10:]'
```

### 4. セッションの整理

不要なセッションを終了:
```bash
tmux kill-session -t worker-2
```

すべてのセッションを終了:
```bash
tmux kill-server
```

### 5. バックアップ

重要な作業前にコミット:
```bash
git add -A
git commit -m "checkpoint: before major task"
```

## まとめ

マルチセッションワークフローの要点：

1. **3つのセッション**: Commander、Observer、Worker
2. **ファイル経由で連携**: runtime/ と tasks/ ディレクトリを共有
3. **独立した動作**: 各セッションは自律的に動作
4. **Skills で効率化**: `/decompose-task`、`/evaluate-gate`、`/sync-status`
5. **tmux で管理**: セッションの切り替えとデタッチ

次のステップ:
1. `./scripts/launch-agents-worktree.sh` でシステム起動
2. Commanderで最初のタスクを分解
3. ワークフローに従って実行

詳細は [.multi-agent/docs/GUIDE.md](GUIDE.md) を参照してください。

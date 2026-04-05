# CLAUDE.md - Worker

あなたはこのプロジェクトの **Worker** です。
与えられた `spec.md` の指示に従い、タスクを実行してください。
指示の範囲外のことは行わないでください。
判断に迷った場合は実行を止めて `result.md` に `blocked_reason` を記載してください。

---

## タスク開始時の手順

1. `tasks/task-xxx/spec.md` を読む
2. `permissions` を確認する（書き込み可能なパス・実行可能なコマンド）
3. `required_packages` が環境に揃っているか確認する（揃っていない場合は blocked）
4. `input_artifacts` が存在するか確認する（存在しない場合は blocked）
5. `task/task-xxx` ブランチに切り替える（なければ作成する）
6. 作業を開始する

---

## 中間報告の手順

以下のタイミングで `result.md` に追記する：

- 作業の区切り（サブタスク完了時）
- 問題・ブロッカーを発見した時
- 長時間作業の場合は定期的に

```yaml
---
task_id: task-xxx
status: in_progress
attempt: 1
branch: task/task-xxx
merge_status: pending
commit: （現時点のコミットハッシュ）
timestamp: （現在時刻）
---

## 中間報告 Round N
（自然言語）
```

コミットは以下の形式で行う：
```
wip: task-xxx （進捗概要）
```

---

## タスク完了時の手順

1. 最終コミットを行う：
   ```
   feat/fix/test: task-xxx （作業概要）
   ```
2. `result.md` を最終報告として更新する（`status: completed`）
3. `templates/task/result.md` の全セクションを埋める
4. Commander に完了を報告する

**Human Control モード時の出力:**
```markdown
---
✅ **タスク完了**

task-xxx の実装が完了しました。

📋 **次のステップ (Human Control)**:
1. 別のターミナルで `tmux attach-session -t commander` を実行
2. Commanderに以下を依頼: "task-xxx の Worker 実装が完了しました。一次評価（commander_review.md作成）を実施してください"
3. Commander が一次評価を完了したら、Observer セッションへ移動

📂 **確認すべきファイル**:
- `tasks/task-xxx/result.md`: 完了報告
- output_artifacts（成果物）: spec.md に記載されているファイル
- git log: コミット履歴
---
```

---

## タスク失敗時の手順

1. 失敗のコミットを行う：
   ```
   wip: task-xxx [FAILED] （理由）
   ```
2. `result.md` を更新する（`status: failed`）
3. `未達・問題` セクションに失敗理由を詳細に記載する
4. `申し送り` セクションに次の attempt への情報を記載する
5. Commander に失敗を報告する

**Human Control モード時の出力:**
```markdown
---
❌ **タスク失敗**

task-xxx の実装に失敗しました。

📋 **次のステップ (Human Control)**:
1. 別のターミナルで `tmux attach-session -t commander` を実行
2. Commanderに以下を依頼: "task-xxx が失敗しました。result.md を確認して、リトライまたは仕様変更を判断してください"
3. Commander の判断を待つ

📂 **確認すべきファイル**:
- `tasks/task-xxx/result.md`: 失敗理由と申し送り
- git log: 失敗時点のコミット
- `runtime/BOARD.md`: retry_limit の残数
---
```

---

## blocked 時の手順

以下の場合は即座に作業を止めて報告する：

- `required_packages` が存在しない
- `input_artifacts` が存在しない
- `permissions` の範囲外の操作が必要になった
- 仕様が不明確で判断できない

`result.md` の `未達・問題` セクションに `blocked_reason` を明記する。

**Human Control モード時の出力:**
```markdown
---
🚫 **タスクブロック**

task-xxx がブロックされました。

📋 **次のステップ (Human Control)**:
1. 別のターミナルで `tmux attach-session -t commander` を実行
2. Commanderに以下を依頼: "task-xxx がブロックされました。result.md を確認して、環境整備または仕様変更を実施してください"
3. Commander がブロックを解消したら、このセッションに戻って再開

📂 **確認すべきファイル**:
- `tasks/task-xxx/result.md`: ブロック理由（blocked_reason）
- `tasks/task-xxx/spec.md`: 仕様（修正が必要な場合）
- `runtime/BOARD.md`: タスクステータス
---
```

---

## 権限ルール

`spec.md` の `permissions` に従い厳守する：

| 操作 | 確認先 |
|-----|-------|
| ファイル書き込み | permissions.filesystem.write に含まれるパスのみ |
| コマンド実行 | permissions.execution.allowed に含まれるもののみ |
| ネットワーク | permissions.network.disallowed に含まれないもののみ |
| パッケージインストール | 禁止（Commander が事前に準備する） |
| develop/main への操作 | 禁止 |
| runtime/BOARD.md 等プロジェクトファイルへの書き込み | 禁止 |

---

## Git ルール

| 操作 | 可否 |
|-----|------|
| task/task-xxx ブランチの作成・コミット | ✅ |
| task/task-xxx へのプッシュ | ✅ |
| 他のブランチへの操作 | ❌ |
| develop / main へのマージ | ❌ |

---
name: start-task
description: WorkerがタスクをCodexに委譲するまでの事前確認・ブランチ作成・委譲ワークフロー
disable-model-invocation: false
user-invocable: true
allowed-tools: [editor, bash]
---

# タスク開始 Skill

WorkerがSpec.mdを読み込み、Codexにタスクを委譲します。

## 使用方法

```bash
/start-task task-001
```

## 手順

1. `tasks/task-xxx/spec.md` を読む
2. 以下を確認し、不足があれば即座に `status: blocked` で `result.md` を作成して報告する：
   - `permissions` の範囲が妥当か
   - `required_packages` が環境に揃っているか
   - `input_artifacts` がすべて存在するか
3. `task/task-xxx` ブランチを作成する（なければ）：
   ```bash
   git checkout -b task/task-xxx
   ```
4. Codex にタスクを委譲する：
   ```bash
   /codex:rescue --background "
   tasks/[task_id]/spec.md と tasks/[task_id]/AGENTS.md に従って実装してください。

   ## タスク: [task_id]
   ### 指示内容
   [spec.md の「指示内容」セクション]

   ### 期待する成果物
   [output_artifacts のリスト]

   ### 重要
   - AGENTS.md の品質チェックをすべて実行してからコミットすること
   - チェックが通らない場合は自分で修正してから再実行すること
   "
   ```
5. Codex の実行完了を `/codex:status` で確認する
6. 完了後は `result.md` を作成する（`.multi-agent/templates/task/result.md` 参照）

## blocked / failed 時

1. 実行中なら `/codex:cancel` を実行する
2. `result.md` を作成する（`status: blocked` or `status: failed`、`blocked_reason` を明記）
3. Commander にエスカレーションする

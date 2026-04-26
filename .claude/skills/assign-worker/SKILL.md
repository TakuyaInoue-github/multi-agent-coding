---
name: assign-worker
description: Gate1通過済みタスクをWorkerに割り当て、着手許可を出すCommanderワークフロー
disable-model-invocation: false
user-invocable: true
allowed-tools: [editor, bash]
---

# Worker 着手許可 Skill

CommanderがGate1通過済みタスクをWorkerに割り当てます。

## 使用方法

```bash
/assign-worker task-001
```

## 手順

1. `runtime/BOARD.md` で対象タスクの status が `approved` であることを確認する
2. `depends_on` のタスクがすべて `completed` であることを確認する
3. `tasks/task-xxx/spec.md` の `input_artifacts` がすべて存在することを確認する
4. `output_artifacts` が他の `in_progress` タスクと重複していないことを確認する
5. すべてOKなら以下を実行する：
   - `/sync-status sync-board task-xxx '{"status":"in_progress","assigned_at":"<timestamp>"}'`
   - `/sync-status append-event task-xxx '{"action":"task_assigned","actor":"commander","severity":"null","detail":"Workerに着手許可"}'`
6. Workerに `tasks/task-xxx/spec.md` を渡して着手を依頼する

## ブロック条件

以下の場合は着手許可を出さず、状況に応じて対応する：

| 状況 | 対応 |
|-----|------|
| depends_on が未完了 | 完了を待つ、または partial_ok の場合は spec.md を修正して判断 |
| input_artifacts が存在しない | Commander がユーザーに確認または上告 |
| output_artifacts が重複 | BOARD.md を確認し別タスクの完了を待つ |
| depends_on が failed | ユーザーへ上告 |

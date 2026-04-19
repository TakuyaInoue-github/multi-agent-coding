---
name: review-result
description: WorkerのresultをCommanderが一次評価しcommander_review.mdを作成するワークフロー
disable-model-invocation: false
user-invocable: true
allowed-tools: [editor, bash]
---

# 一次評価 Skill

CommanderがWorkerの成果物を一次評価し、`commander_review.md` を作成します。

## 使用方法

```bash
/review-result task-001
```

## 手順

1. `tasks/task-xxx/spec.md` を読む（指示内容・成功基準・output_artifacts）
2. `tasks/task-xxx/result.md` を読む（成果報告）
3. 以下を突き合わせて評価する：
   - `output_artifacts` に列挙されたファイルが実際に存在するか
   - `success_criteria` を1つずつ満たしているか
   - 指示の範囲外の変更が含まれていないか
4. `commander_review.md` を作成する（`.multi-agent/templates/task/commander_review.md` 参照）
5. `/sync-status append-event task-xxx '{"action":"commander_review_created","actor":"commander","severity":"null","detail":"一次評価完了"}'` を実行する
6. ObserverのGate2評価を待つ（自律的に検知される）

## 判定基準

| 状況 | commander_review の verdict |
|-----|---------------------------|
| 全成功基準を満たしている | pass |
| 軽微な問題あり（動作は正常） | pass with note |
| 成功基準の一部未達 | fail（Workerに再指示） |
| 指示範囲外の変更あり | fail（差し戻し） |

fail の場合は `commander_review.md` に再指示内容を具体的に記載し、Workerに差し戻す。

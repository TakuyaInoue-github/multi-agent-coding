---
name: handle-discussion
description: ObserverのfailによるDISCUSSION起票にCommanderが応答するワークフロー
disable-model-invocation: false
user-invocable: true
allowed-tools: [editor, bash]
---

# 議論対応 Skill

CommanderがObserverの指摘に対して応答します。

## 使用方法

```bash
/handle-discussion task-001
```

## 手順

1. `runtime/DISCUSSION.md` を読み、未応答のObserver起票を把握する
2. `.multi-agent/config/RULEBOOK.md` で指摘の妥当性を確認する
3. `runtime/BOARD.md` の `policy.discussion_round_limit` を確認する
4. 以下のいずれかで `runtime/DISCUSSION.md` に応答を記載する：

### 受け入れる場合

- `spec.md` または実装を修正する
- `runtime/DISCUSSION.md` に受け入れ理由と修正内容を記載する
- `/sync-status append-event` で `discussion_round` を記録する
- Gate評価フローを再開する

### 反論する場合

- `runtime/DISCUSSION.md` に根拠を明記して反論を記載する
- `/sync-status append-event` で `discussion_round` を記録する
- Observerの再評価を待つ

### 上告する場合（`discussion_round_limit` 超過時）

- `runtime/DISCUSSION.md` に上告理由を記載する
- `/sync-status append-event task-xxx '{"action":"discussion_escalated","actor":"commander","severity":"major","detail":"上告理由"}'` を実行する
- `runtime/SUMMARY.md` の未解決イベント一覧を更新する
- ユーザーに状況を説明して決裁を求める

## DISCUSSION応答の形式

```markdown
## Round N - Commander（task-xxx / gate: X）

**応答**: 受け入れ | 反論 | 上告

**理由**
（RULEBOOK.md の該当箇所を引用しながら根拠を記述）

**対応内容**
（受け入れの場合: 修正した内容 / 反論の場合: 主張の根拠 / 上告の場合: ユーザーへの質問）
```

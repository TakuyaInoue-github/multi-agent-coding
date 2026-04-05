# RULEBOOK.md

## Observer 評価の原則

1. 評価はこのRULEBOOKの項目に基づく
2. RULEBOOKに記載のない判断は「不明確」として fail ではなく warning とする
3. Commanderの意図ではなく成果物の事実を評価する
4. 「おそらく問題ない」は pass の根拠にならない
5. pass を出す根拠ではなく fail の根拠を探す

---

## スコアリング方式

各チェック項目を以下で評価する：

```
pass / fail / warning / not_applicable
```

| 判定条件 | verdict | severity |
|---------|---------|---------|
| critical が 1つでも fail | fail | critical |
| major が 2つ以上 fail | fail | major |
| major が 1つ fail | warning | major |
| minor のみ fail | pass | - |
| 全項目 pass/not_applicable | pass | - |

verdict が warning の場合はログのみ記録し進行を許可する。
DISCUSSION を起票するのは verdict が fail の場合のみ。

---

## Gate1 チェックリスト（タスク分解評価）

### 構造的チェック（severity: critical）

- [ ] task_id が一意である
- [ ] depends_on に存在しない task_id が含まれていない
- [ ] output_artifacts が他タスクと重複していない
- [ ] input_artifacts が depends_on によって保証されている
- [ ] environment_verified が true になっている
- [ ] worker_type が定義済みの種別（coding/testing/debugging）である

### 内容的チェック（severity: major）

- [ ] 指示内容が単一責務に収まっている
- [ ] 指示内容が曖昧でなく実行可能な粒度である
- [ ] Worker 1セッションで完結できる規模である
- [ ] CONTEXT.md のプロジェクト方針と矛盾していない
- [ ] commander_reasoning が明記されている

### 権限チェック（severity: major）

- [ ] required_packages が明記されている（必要な場合）
- [ ] permissions.filesystem.write のスコープが適切である
- [ ] permissions.network が適切に制限されている

---

## Gate2 チェックリスト（成果物評価）

### 完全性チェック（severity: critical）

- [ ] result.md の全セクションが記載されている
- [ ] output_artifacts に列挙されたファイルが実際に存在する
- [ ] commit ハッシュが記載されている
- [ ] status が completed の場合、未達セクションが空である

### Commander 評価チェック（severity: major）

- [ ] commander_review が spec.md の指示内容を網羅している
- [ ] pass の根拠が具体的に明示されている
- [ ] fail の場合、再指示の内容が具体的である
- [ ] 見落としや過小評価が見受けられない

### 品質チェック（severity: major）

- [ ] 成果物が CONTEXT.md のプロジェクト方針と整合している
- [ ] テストタスクの場合、カバレッジが妥当である
- [ ] デバッグタスクの場合、原因の特定まで至っている

### attempt チェック（severity: minor）

- [ ] attempt が 2 以上の場合、前回 fail の指摘が反映されている

---

## Observer モデル切り替え条件

以下のいずれかを満たした場合、Observer を Codex に切り替えることを検討する：

- Gate2 の pass 率が 95% を超えている（Observer が甘い）
- DISCUSSION で Commander が常に議論に勝っている（win rate > 80%）
- ユーザーが Observer の見落としを 3 回以上指摘している

切り替え判断は BOARD.md の `observer_model_switch_conditions` の数値を参照する。

---

## プロジェクト固有ルール

（ユーザーがここに追記する）

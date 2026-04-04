---
name: evaluate-gate
description: タスクのspecまたはresultを品質ゲート（Gate1/Gate2）に照らして評価
disable-model-invocation: false
user-invocable: true
allowed-tools: [editor, bash]
---

# Gate評価 Skill

Observerがタスクを品質ゲートに照らして評価します。

## 使用方法

```bash
/evaluate-gate 1 task-001 spec_review
/evaluate-gate 2 task-001 result_review
```

## 引数

- `$0` = gate_number（1 または 2）
- `$1` = task_id
- `$2` = evaluation_type（spec_review または result_review）

## Gate1: 仕様レビュー

`tasks/$1/spec.md` を評価する場合：

### チェックリスト

#### 構造的チェック（severity: critical）

- [ ] task_id が一意である
- [ ] depends_on に存在しない task_id が含まれていない
- [ ] output_artifacts が他タスクと重複していない
- [ ] input_artifacts が depends_on によって保証されている
- [ ] environment_verified が true になっている（パッケージ必要時）
- [ ] worker_type が定義済みの種別（coding/testing/debugging）である

#### 内容的チェック（severity: major）

- [ ] 指示内容が単一責務に収まっている
- [ ] 指示内容が曖昧でなく実行可能な粒度である
- [ ] Worker 1セッションで完結できる規模である
- [ ] `runtime/CONTEXT.md` のプロジェクト方針と矛盾していない
- [ ] commander_reasoning が明記されている

#### 権限チェック（severity: major）

- [ ] required_packages が明記されている（必要な場合）
- [ ] permissions.filesystem.write のスコープが適切である
- [ ] permissions.network が適切に制限されている

### 出力構造

```markdown
---
task_id: $1
gate: 1
verdict: pass | warning | fail
severity: null | minor | major | critical
trigger: autonomous | requested
trigger_type: structure | content | permission | null
round: 1
attempt: 1
timestamp: YYYY-MM-DDTHH:MM:SS
---

## 評価サマリー

**Verdict**: [PASS|FAIL|WARNING]
**Severity**: [CRITICAL|MAJOR|MINOR|NULL]

## チェック結果

| 項目 | 結果 | severity | 備考 |
|-----|------|---------|------|
| task_id 一意性 | pass | critical | |
| depends_on 存在確認 | pass | critical | |
| output_artifacts 重複 | fail | critical | task-002と重複: src/app.js |
| input_artifacts 保証 | pass | critical | |
| environment_verified | pass | critical | |
| worker_type 定義 | pass | critical | |
| 単一責務 | pass | major | |
| 実行可能粒度 | pass | major | |
| Worker完結可能 | pass | major | |
| プロジェクト方針整合 | pass | major | |
| commander_reasoning | pass | major | |
| required_packages | pass | major | |
| filesystem.write | pass | major | |
| network制限 | pass | major | |

## 指摘事項

### Critical問題

1. **output_artifacts重複**: task-002と`src/app.js`が重複
   - **影響**: 並列実行時に競合発生の可能性
   - **対応**: task-002の完了を depends_on に追加、または output_artifacts を分離

### Major問題

（なし）

### Minor問題

（なし）

## DISCUSSION 起票内容

（verdict が fail の場合のみ記述）

```markdown
## Round 1 - Observer（task-001 / gate: 1）

**verdict**: fail
**severity**: critical
**trigger_type**: structure

**指摘事項**

`config/RULEBOOK.md` の Gate1 チェックリスト「構造的チェック」に違反：
- output_artifacts が他タスク（task-002）と重複している: `src/app.js`

**Commander への問いかけ**

以下のいずれかで対応してください：
1. task-002の完了を task-001の depends_on に追加する
2. output_artifacts を分離する（例: src/app.js を src/app-core.js と src/app-routes.js に分割）
3. 並列実行を諦めて parallel_ok を false にする

どの方針で進めますか？
\```
```

## Gate2: 成果物レビュー

`tasks/$1/result.md` を `spec.md` と照らし合わせて評価する場合：

### チェックリスト

#### 完全性チェック（severity: critical）

- [ ] result.md の全セクションが記載されている
- [ ] output_artifacts に列挙されたファイルが実際に存在する
- [ ] commit ハッシュが記載されている
- [ ] status が completed の場合、未達セクションが空である

#### Commander評価チェック（severity: major）

- [ ] commander_review が spec.md の指示内容を網羅している
- [ ] pass の根拠が具体的に明示されている
- [ ] fail の場合、再指示の内容が具体的である
- [ ] 見落としや過小評価が見受けられない

#### 品質チェック（severity: major）

- [ ] 成果物が `runtime/CONTEXT.md` のプロジェクト方針と整合している
- [ ] テストタスクの場合、カバレッジが妥当である
- [ ] デバッグタスクの場合、原因の特定まで至っている

#### attemptチェック（severity: minor）

- [ ] attempt が 2 以上の場合、前回 fail の指摘が反映されている

### 出力構造

```markdown
---
task_id: $1
gate: 2
verdict: pass | warning | fail
severity: null | minor | major | critical
trigger: autonomous | requested
trigger_type: completeness | commander_review | quality | null
round: 1
attempt: 1
timestamp: YYYY-MM-DDTHH:MM:SS
---

## 評価サマリー

**Verdict**: [PASS|FAIL|WARNING]
**Severity**: [CRITICAL|MAJOR|MINOR|NULL]

## チェック結果

| 項目 | 結果 | severity | 備考 |
|-----|------|---------|------|
| result.md 全セクション | pass | critical | |
| output_artifacts 存在確認 | pass | critical | |
| commit ハッシュ | pass | critical | |
| status=completed時の未達 | pass | critical | |
| commander_review 網羅性 | pass | major | |
| pass根拠の明示 | pass | major | |
| 見落とし・過小評価 | pass | major | |
| プロジェクト方針整合 | pass | major | |
| テストカバレッジ | not_applicable | major | テストタスクではない |
| デバッグ原因特定 | not_applicable | major | デバッグタスクではない |
| 前回fail反映 | not_applicable | minor | attempt=1 |

## 指摘事項

（fail / warning の場合のみ記述）

## DISCUSSION 起票内容

（verdict が fail の場合のみ記述）
```

## 判定ロジック

### Verdict 決定

```
if (critical が 1つでも fail):
    verdict = fail
    severity = critical

elif (major が 2つ以上 fail):
    verdict = fail
    severity = major

elif (major が 1つ fail):
    verdict = warning
    severity = major

elif (minor のみ fail):
    verdict = pass
    severity = null

else:  # 全項目 pass/not_applicable
    verdict = pass
    severity = null
```

### アクション決定

```
if (verdict == fail):
    runtime/DISCUSSION.md に起票
    runtime/EVENTLOG.json に gate{1|2}_fail を記録

elif (verdict == warning):
    runtime/EVENTLOG.json に gate{1|2}_warning を記録
    進行を許可

else:  # verdict == pass
    runtime/EVENTLOG.json に gate{1|2}_pass を記録
    進行を許可
```

## 評価の原則

### 1. 客観性

- **事実ベース**: Commander の意図ではなく、成果物の事実を評価する
- **ルールベース**: `config/RULEBOOK.md` に記載のない判断は「不明確」として warning
- **証拠ベース**: 「おそらく問題ない」は pass の根拠にならない

### 2. 批判的思考

- **fail を探す**: pass を出す根拠ではなく fail の根拠を探す
- **前進を急がない**: Commander が前進を急いでいるときこそ慎重に評価
- **懐疑的**: すべての主張に対して「本当にそうか？」と問う

### 3. 建設性

- **具体的な指摘**: 「曖昧」ではなく「どこが曖昧か」を指摘
- **代替案の提示**: 問題を指摘するだけでなく、解決策も提案
- **Commander との議論**: fail を出すときは Commander が応答できる形で起票

## 関連ファイル

詳細なチェック基準は `checklists/gate1-checklist.md` と `checklists/gate2-checklist.md` を参照。
実際の評価例は `examples/` を参照。

## マルチエージェントシステムとの統合

### Gate1フロー

1. Commander が `tasks/task-xxx/spec.md` を作成
2. Observer が自律的に検知（`runtime/BOARD.md` の trigger を監視）
3. Observer が `/evaluate-gate 1 task-xxx spec_review` を実行
4. Observer が `tasks/task-xxx/observer_review.md` を作成
5. verdict に応じて：
   - **pass**: 何もしない（Commander が Worker に着手許可）
   - **warning**: `runtime/EVENTLOG.json` に記録のみ
   - **fail**: `runtime/DISCUSSION.md` に起票

### Gate2フロー

1. Worker が `tasks/task-xxx/result.md` を作成
2. Commander が `tasks/task-xxx/commander_review.md` を作成
3. Observer が自律的に検知
4. Observer が `/evaluate-gate 2 task-xxx result_review` を実行
5. Observer が `tasks/task-xxx/observer_review.md` を更新
6. verdict に応じて：
   - **pass**: 何もしない（Commander が develop へマージ）
   - **warning**: `runtime/EVENTLOG.json` に記録のみ
   - **fail**: `runtime/DISCUSSION.md` に起票

## 議論プロセス

### DISCUSSION.md への起票

```markdown
## Round 1 - Observer（task-xxx / gate: X）

**verdict**: fail
**severity**: major
**trigger_type**: content

**指摘事項**

（`config/RULEBOOK.md` のどの項目に違反しているかを具体的に記述）

**Commander への問いかけ**

（合意するための具体的な修正提案または質問）
```

### Commander の応答への対応

Commander が `runtime/DISCUSSION.md` に応答したら：

1. 応答内容と `config/RULEBOOK.md` を突き合わせる
2. 以下のいずれかで応答する：
   - **受け入れ**: 修正後の spec.md or result.md を再評価する
   - **維持**: 根拠を明記して議論継続
3. `runtime/BOARD.md` の `policy.discussion_round_limit` を超えた場合は Commander に上告義務があることを明示する

## 自己チェックリスト

評価完了後、以下を確認：

- [ ] すべてのチェック項目に対して結果を記載した
- [ ] verdict が判定ロジックに従って決定されている
- [ ] severity が適切に設定されている
- [ ] fail の場合、DISCUSSION 起票内容が具体的である
- [ ] EVENTLOG.json に記録した
- [ ] observer_review.md を作成/更新した

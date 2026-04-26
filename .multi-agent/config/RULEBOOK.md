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

## 言語固有評価基準（Gate2）

Gate2 評価時は、プロジェクトの言語に応じて以下の基準を適用する。
`CONTEXT.md` の `技術スタック.language` を参照すること。

### Python

#### 必須項目 (severity: critical)

**モダンツールチェーン（2025年推奨: Ruff + uv）**:
- [ ] `ruff format --check` でフォーマット確認が通過
- [ ] `ruff check` で警告・エラーなし
- [ ] 仮想環境が使用されている（`.venv/` 存在）
- [ ] `pyproject.toml` が存在し、依存関係が記載されている

**従来のツールチェーン（後方互換性: black + flake8）**:
- [ ] `black --check` でフォーマット確認が通過
- [ ] `flake8` で警告・エラーなし
- [ ] 仮想環境が使用されている（`venv/` または `.venv/` 存在）
- [ ] `requirements.txt` が存在し、依存関係が記載されている

**注**: モダンツールチェーンは `pyproject.toml` に `[tool.ruff]` があるかで判定

#### 推奨項目 (severity: major)

- [ ] `mypy` または `pyright` で型エラーなし（型ヒントが使われている場合）
- [ ] `pytest` でテストがすべて通過（テストタスクの場合）
- [ ] カバレッジが 80% 以上（テストタスクの場合）
- [ ] `__init__.py` が適切に配置されている
- [ ] docstring が主要な関数・クラスに存在する
- [ ] `uv.lock` が存在し、依存関係が固定されている（uv使用時）

### TypeScript

#### 必須項目 (severity: critical)

- [ ] `tsc --noEmit` で型エラーなし
- [ ] `prettier --check` でフォーマット確認が通過
- [ ] `eslint` で警告・エラーなし
- [ ] `package.json` が存在し、依存関係が記載されている
- [ ] `tsconfig.json` で `strict: true` が有効

#### 推奨項目 (severity: major)

- [ ] `vitest` / `jest` でテストがすべて通過（テストタスクの場合）
- [ ] カバレッジが 80% 以上（テストタスクの場合）
- [ ] `@typescript-eslint/no-explicit-any` ルールが有効
- [ ] 関数の戻り値型が明示されている（主要な関数）
- [ ] ビルドが成功する (`npm run build`)

### Go

#### 必須項目 (severity: critical)

- [ ] `gofmt -d .` で差分なし（フォーマット済み）
- [ ] `go vet ./...` でエラーなし
- [ ] `go build` でビルド成功
- [ ] `go.mod` と `go.sum` が存在し、整合している
- [ ] すべての `if err != nil` チェックが適切に処理されている

#### 推奨項目 (severity: major)

- [ ] `golangci-lint run` で警告なし
- [ ] `go test ./...` でテストがすべて通過（テストタスクの場合）
- [ ] カバレッジが 80% 以上（テストタスクの場合）
- [ ] `goimports` でインポート文が整理されている
- [ ] エラーが適切にラップされている（`%w` 使用）

### Java

#### 必須項目 (severity: critical)

- [ ] `mvn compile` / `./gradlew compileJava` でコンパイル成功
- [ ] `mvn checkstyle:check` でスタイル違反なし
- [ ] パッケージ構造が適切（逆ドメイン形式: `com.example.projectname`）
- [ ] `pom.xml` / `build.gradle` が存在し、依存関係が記載されている
- [ ] Java バージョンが明示されている

#### 推奨項目 (severity: major)

- [ ] `mvn test` / `./gradlew test` でテストがすべて通過（テストタスクの場合）
- [ ] JaCoCo カバレッジが 80% 以上（テストタスクの場合）
- [ ] `mvn spotbugs:check` で警告なし
- [ ] 適切な例外処理が実装されている（checked exceptions）
- [ ] Javadoc が主要なクラス・メソッドに存在する

---

## プロジェクト固有ルール

（ユーザーがここに追記する）

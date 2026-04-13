---
name: go-quality-check
description: |
  Run quality checks on Go code. Invoke automatically after writing or modifying Go files,
  before committing, or when asked to verify code quality.
  Triggers: after implementing .go files, before git commit, "check quality", "run checks",
  "verify implementation", Gate2 evaluation by Observer.
  Checks: gofmt format, go vet static analysis, go build, go test (testing tasks only).
disable-model-invocation: false
user-invocable: true
allowed-tools: [bash]
---

# Go 品質チェック Skill

Observer が Gate2 評価時に Go コードの品質をチェックするために使用します。

## 使用方法

```bash
/go-quality-check "task-001"
/go-quality-check "$TASK_ID"
```

## 引数

- `$0` = タスクID（例: "task-001"）

## チェック項目

このスキルは以下のチェックを実行し、結果を `tasks/$TASK_ID/quality_report.md` に出力します。

### 1. フォーマットチェック (gofmt)

```bash
cd tasks/$TASK_ID
gofmt -d .
```

**評価基準**:
- ✅ pass: 差分なし
- ❌ fail: フォーマット差分あり

### 2. インポート整理チェック (goimports)

```bash
cd tasks/$TASK_ID
goimports -d . || echo "goimports not installed"
```

**評価基準**:
- ✅ pass: 差分なし、または goimports 未インストール
- ⚠️  warning: 差分あり（goimports 推奨）
- ❌ fail: インポート文が大きく乱れている

### 3. 静的解析 (go vet)

```bash
cd tasks/$TASK_ID
go vet ./...
```

**評価基準**:
- ✅ pass: エラーなし
- ❌ fail: エラーあり

### 4. リンターチェック (golangci-lint) - オプション

```bash
cd tasks/$TASK_ID
golangci-lint run || echo "golangci-lint not configured"
```

**評価基準**:
- ✅ pass: エラーなし、または未設定
- ⚠️  warning: 警告のみ
- ❌ fail: エラーあり

### 5. ビルドチェック

```bash
cd tasks/$TASK_ID
go build ./...
```

**評価基準**:
- ✅ pass: ビルド成功
- ❌ fail: ビルド失敗

### 6. テストチェック (go test) - テストタスクのみ

```bash
cd tasks/$TASK_ID
go test -v -cover ./...
```

**評価基準**:
- ✅ pass: テスト全通過、カバレッジ 80% 以上
- ⚠️  warning: テスト全通過、カバレッジ 80% 未満
- ❌ fail: テスト失敗

### 7. 構造チェック

- [ ] `go.mod` と `go.sum` が存在する
- [ ] `go.mod` と `go.sum` が整合している（`go mod verify` 通過）
- [ ] すべての `if err != nil` が適切に処理されている
- [ ] エラーがラップされている（`%w` 使用）

## 出力形式

`tasks/$TASK_ID/quality_report.md`:

```markdown
# Go 品質チェックレポート

タスクID: $TASK_ID
実行日時: $(date)

## フォーマットチェック (gofmt)

**結果**: pass | fail
**詳細**:
\`\`\`
(gofmt の出力)
\`\`\`

## インポート整理チェック (goimports)

**結果**: pass | warning | fail
**詳細**:
\`\`\`
(goimports の出力)
\`\`\`

## 静的解析 (go vet)

**結果**: pass | fail
**詳細**:
\`\`\`
(go vet の出力)
\`\`\`

## リンターチェック (golangci-lint)

**結果**: pass | warning | fail | not_applicable
**詳細**:
\`\`\`
(golangci-lint の出力)
\`\`\`

## ビルドチェック

**結果**: pass | fail
**詳細**:
\`\`\`
(go build の出力)
\`\`\`

## テストチェック (go test)

**結果**: pass | warning | fail | not_applicable
**カバレッジ**: XX%
**詳細**:
\`\`\`
(go test の出力)
\`\`\`

## 構造チェック

- [x] go.mod と go.sum が存在する
- [x] go mod verify が通過
- [x] if err != nil が適切に処理されている
- [x] エラーがラップされている

## 総合評価

**verdict**: pass | warning | fail

**判定基準**:
- gofmt fail → 全体 fail (severity: critical)
- go vet fail → 全体 fail (severity: critical)
- go build fail → 全体 fail (severity: critical)
- テスト失敗 → 全体 fail (severity: critical)
- エラーチェック漏れ → 全体 fail (severity: major)
- カバレッジ 80% 未満 → warning (severity: major)
- それ以外 → pass

**推奨アクション**:
(fail の場合の修正方法を記載)
```

## 関連ファイル

- `.multi-agent/config/languages/go.md` - Go プロジェクトガイドライン
- `.multi-agent/config/RULEBOOK.md` - 評価基準

## 使用例

### Observer が Gate2 評価時に実行

```bash
/go-quality-check "task-001"
```

その後、`tasks/task-001/quality_report.md` を読んで評価結果を確認。

## 注意事項

- Go Modules が有効化されている状態で実行すること
- `gofmt`, `go vet`, `go build`, `go test` は Go 標準
- `goimports` と `golangci-lint` はオプション（推奨）
  - `go install golang.org/x/tools/cmd/goimports@latest`
  - `go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest`
- テストチェックは `worker_type: testing` のタスクでのみ実施

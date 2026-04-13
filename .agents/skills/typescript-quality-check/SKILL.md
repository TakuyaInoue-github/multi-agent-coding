---
name: typescript-quality-check
description: |
  Run quality checks on TypeScript code. Invoke automatically after writing or modifying
  TypeScript files, before committing, or when asked to verify code quality.
  Triggers: after implementing .ts/.tsx files, before git commit, "check quality", "run checks",
  "verify implementation", Gate2 evaluation by Observer.
  Checks: tsc type check, prettier format, eslint lint, vitest/jest (testing tasks only), build.
disable-model-invocation: false
user-invocable: true
allowed-tools: [bash]
---

# TypeScript 品質チェック Skill

Observer が Gate2 評価時に TypeScript コードの品質をチェックするために使用します。

## 使用方法

```bash
/typescript-quality-check "task-001"
/typescript-quality-check "$TASK_ID"
```

## 引数

- `$0` = タスクID（例: "task-001"）

## チェック項目

このスキルは以下のチェックを実行し、結果を `tasks/$TASK_ID/quality_report.md` に出力します。

### 1. 型チェック (tsc)

```bash
cd tasks/$TASK_ID
npx tsc --noEmit
```

**評価基準**:
- ✅ pass: 型エラーなし
- ❌ fail: 型エラーあり

### 2. フォーマットチェック (prettier)

```bash
cd tasks/$TASK_ID
npx prettier --check "src/**/*.ts" "src/**/*.tsx"
```

**評価基準**:
- ✅ pass: フォーマット差分なし
- ❌ fail: フォーマット差分あり

### 3. リンターチェック (eslint)

```bash
cd tasks/$TASK_ID
npx eslint "src/**/*.ts" "src/**/*.tsx"
```

**評価基準**:
- ✅ pass: エラー・警告なし
- ⚠️  warning: 警告のみ（エラーなし）
- ❌ fail: エラーあり

### 4. テストチェック (vitest / jest) - テストタスクのみ

```bash
cd tasks/$TASK_ID
npx vitest run --coverage || npx jest --coverage
```

**評価基準**:
- ✅ pass: テスト全通過、カバレッジ 80% 以上
- ⚠️  warning: テスト全通過、カバレッジ 80% 未満
- ❌ fail: テスト失敗

### 5. ビルドチェック

```bash
cd tasks/$TASK_ID
npm run build || echo "no build script"
```

**評価基準**:
- ✅ pass: ビルド成功
- ⚠️  warning: ビルドスクリプトなし
- ❌ fail: ビルド失敗

### 6. 構造チェック

- [ ] `package.json` が存在する
- [ ] `tsconfig.json` が存在し、`strict: true` が設定されている
- [ ] `node_modules/` が `.gitignore` に含まれている
- [ ] 関数の戻り値型が明示されている（主要な関数）

## 出力形式

`tasks/$TASK_ID/quality_report.md`:

```markdown
# TypeScript 品質チェックレポート

タスクID: $TASK_ID
実行日時: $(date)

## 型チェック (tsc)

**結果**: pass | fail
**詳細**:
\`\`\`
(tsc の出力)
\`\`\`

## フォーマットチェック (prettier)

**結果**: pass | fail
**詳細**:
\`\`\`
(prettier の出力)
\`\`\`

## リンターチェック (eslint)

**結果**: pass | warning | fail
**詳細**:
\`\`\`
(eslint の出力)
\`\`\`

## テストチェック (vitest/jest)

**結果**: pass | warning | fail | not_applicable
**カバレッジ**: XX%
**詳細**:
\`\`\`
(テストの出力)
\`\`\`

## ビルドチェック

**結果**: pass | warning | fail
**詳細**:
\`\`\`
(ビルドの出力)
\`\`\`

## 構造チェック

- [x] package.json が存在する
- [x] tsconfig.json で strict: true
- [x] node_modules/ が .gitignore に含まれている
- [x] 戻り値型が明示されている

## 総合評価

**verdict**: pass | warning | fail

**判定基準**:
- tsc で型エラー → 全体 fail (severity: critical)
- prettier fail → 全体 fail (severity: critical)
- eslint error あり → 全体 fail (severity: critical)
- テスト失敗 → 全体 fail (severity: critical)
- ビルド失敗 → 全体 fail (severity: critical)
- カバレッジ 80% 未満 → warning (severity: major)
- それ以外 → pass

**推奨アクション**:
(fail の場合の修正方法を記載)
```

## 関連ファイル

- `.multi-agent/config/languages/typescript.md` - TypeScript プロジェクトガイドライン
- `.multi-agent/config/RULEBOOK.md` - 評価基準

## 使用例

### Observer が Gate2 評価時に実行

```bash
/typescript-quality-check "task-001"
```

その後、`tasks/task-001/quality_report.md` を読んで評価結果を確認。

## 注意事項

- `node_modules/` がインストールされている状態で実行すること
- `typescript`, `prettier`, `eslint`, テストフレームワークがインストールされている前提
- テストチェックは `worker_type: testing` のタスクでのみ実施
- パッケージマネージャー (npm/yarn/pnpm) は自動検出

---
name: python-quality-check
description: Python コードの品質チェック（Gate2 評価で Observer が使用）
disable-model-invocation: false
user-invocable: true
allowed-tools: [bash]
---

# Python 品質チェック Skill

Observer が Gate2 評価時に Python コードの品質をチェックするために使用します。

## 使用方法

```bash
/python-quality-check "task-001"
/python-quality-check "$TASK_ID"
```

## 引数

- `$0` = タスクID（例: "task-001"）

## チェック項目

このスキルは以下のチェックを実行し、結果を `tasks/$TASK_ID/quality_report.md` に出力します。

### 1. フォーマットチェック (black)

```bash
cd tasks/$TASK_ID
black --check --diff $(find . -name "*.py" | grep -v venv)
```

**評価基準**:
- ✅ pass: 差分なし
- ❌ fail: フォーマット差分あり

### 2. リンターチェック (flake8)

```bash
cd tasks/$TASK_ID
flake8 $(find . -name "*.py" | grep -v venv)
```

**評価基準**:
- ✅ pass: 警告・エラーなし
- ⚠️  warning: 警告のみ（エラーなし）
- ❌ fail: エラーあり

### 3. 型チェック (mypy) - オプション

```bash
cd tasks/$TASK_ID
mypy $(find . -name "*.py" | grep -v venv) || echo "mypy not configured"
```

**評価基準**:
- ✅ pass: エラーなし、または mypy 未設定
- ⚠️  warning: 型エラーがあるが mypy が厳格モードでない
- ❌ fail: 型エラーあり（mypy strict モード）

### 4. テストチェック (pytest) - テストタスクのみ

```bash
cd tasks/$TASK_ID
pytest --cov --cov-report=term-missing || echo "no tests found"
```

**評価基準**:
- ✅ pass: テスト全通過、カバレッジ 80% 以上
- ⚠️  warning: テスト全通過、カバレッジ 80% 未満
- ❌ fail: テスト失敗

### 5. 構造チェック

- [ ] 仮想環境が使用されている（`venv/` または `.venv/` 存在）
- [ ] `requirements.txt` が存在する（パッケージ使用時）
- [ ] `__init__.py` が適切に配置されている
- [ ] docstring が主要な関数・クラスに存在する

## 出力形式

`tasks/$TASK_ID/quality_report.md`:

```markdown
# Python 品質チェックレポート

タスクID: $TASK_ID
実行日時: $(date)

## フォーマットチェック (black)

**結果**: pass | fail
**詳細**:
\`\`\`
(black の出力)
\`\`\`

## リンターチェック (flake8)

**結果**: pass | warning | fail
**詳細**:
\`\`\`
(flake8 の出力)
\`\`\`

## 型チェック (mypy)

**結果**: pass | warning | fail | not_applicable
**詳細**:
\`\`\`
(mypy の出力)
\`\`\`

## テストチェック (pytest)

**結果**: pass | warning | fail | not_applicable
**カバレッジ**: XX%
**詳細**:
\`\`\`
(pytest の出力)
\`\`\`

## 構造チェック

- [x] 仮想環境が使用されている
- [x] requirements.txt が存在する
- [x] __init__.py が適切に配置されている
- [x] docstring が存在する

## 総合評価

**verdict**: pass | warning | fail

**判定基準**:
- black fail → 全体 fail (severity: critical)
- flake8 error あり → 全体 fail (severity: critical)
- mypy strict モードで型エラー → 全体 fail (severity: major)
- テスト失敗 → 全体 fail (severity: critical)
- カバレッジ 80% 未満 → warning (severity: major)
- それ以外 → pass

**推奨アクション**:
(fail の場合の修正方法を記載)
```

## 関連ファイル

- `.multi-agent/config/languages/python.md` - Python プロジェクトガイドライン
- `.multi-agent/config/RULEBOOK.md` - 評価基準

## 使用例

### Observer が Gate2 評価時に実行

```bash
/python-quality-check "task-001"
```

その後、`tasks/task-001/quality_report.md` を読んで評価結果を確認。

## 注意事項

- 仮想環境が有効化されている状態で実行すること
- `black`, `flake8`, `mypy`, `pytest` がインストールされている前提
- テストチェックは `worker_type: testing` のタスクでのみ実施

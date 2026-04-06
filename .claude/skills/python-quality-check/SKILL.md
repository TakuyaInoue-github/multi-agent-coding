---
name: python-quality-check
description: Python コードの品質チェック（Gate2 評価で Observer が使用、2025年モダンツール対応）
disable-model-invocation: false
user-invocable: true
allowed-tools: [bash]
---

# Python 品質チェック Skill

Observer が Gate2 評価時に Python コードの品質をチェックするために使用します。

**2025年更新**: Ruff による超高速品質チェックに対応しました。

## 使用方法

```bash
/python-quality-check "task-001"
/python-quality-check "$TASK_ID"
```

## 引数

- `$0` = タスクID（例: "task-001"）

## チェック項目

このスキルは以下のチェックを実行し、結果を `tasks/$TASK_ID/quality_report.md` に出力します。

ツールチェーンは自動検出されます：
- `pyproject.toml` に `[tool.ruff]` がある → **モダンツールチェーン**
- `requirements.txt` のみ または black/flake8 設定 → **従来のツールチェーン**

---

## モダンツールチェーン（Ruff）

### 1. フォーマットチェック (ruff format)

```bash
cd tasks/$TASK_ID
ruff format --check $(find . -name "*.py" | grep -v .venv)
```

**評価基準**:
- ✅ pass: 差分なし
- ❌ fail: フォーマット差分あり

### 2. リントチェック (ruff check)

```bash
cd tasks/$TASK_ID
ruff check $(find . -name "*.py" | grep -v .venv)
```

**評価基準**:
- ✅ pass: エラー・警告なし
- ⚠️  warning: 警告のみ（エラーなし）
- ❌ fail: エラーあり

**補足**: Ruff は以下を統合してチェック：
- pycodestyle (E, W)
- pyflakes (F)
- isort (I)
- pep8-naming (N)
- pyupgrade (UP)
- flake8-bugbear (B)
- その他 900以上のルール

### 3. 型チェック (mypy / pyright)

```bash
cd tasks/$TASK_ID
mypy $(find . -name "*.py" | grep -v .venv) || pyright || echo "type checker not configured"
```

**評価基準**:
- ✅ pass: エラーなし、または型チェッカー未設定
- ⚠️  warning: 型エラーがあるが strict モードでない
- ❌ fail: 型エラーあり（strict モード）

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

- [ ] 仮想環境が使用されている（`.venv/` 存在）
- [ ] `pyproject.toml` が存在する
- [ ] `uv.lock` が存在する（uv 使用時）
- [ ] `__init__.py` が適切に配置されている
- [ ] docstring が主要な関数・クラスに存在する

---

## 従来のツールチェーン（black + flake8）

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

### 3. インポート整理チェック (isort) - オプション

```bash
cd tasks/$TASK_ID
isort --check-only $(find . -name "*.py" | grep -v venv) || echo "isort not configured"
```

### 4. 型チェック (mypy)

```bash
cd tasks/$TASK_ID
mypy $(find . -name "*.py" | grep -v venv) || echo "mypy not configured"
```

### 5. テストチェック (pytest)

```bash
cd tasks/$TASK_ID
pytest --cov --cov-report=term-missing || echo "no tests found"
```

### 6. 構造チェック

- [ ] 仮想環境が使用されている（`venv/` または `.venv/` 存在）
- [ ] `requirements.txt` が存在する
- [ ] `__init__.py` が適切に配置されている
- [ ] docstring が主要な関数・クラスに存在する

---

## 出力形式

`tasks/$TASK_ID/quality_report.md`:

```markdown
# Python 品質チェックレポート

タスクID: $TASK_ID
ツールチェーン: モダン (Ruff) | 従来 (black + flake8)
実行日時: $(date)

## フォーマットチェック

**ツール**: ruff format | black
**結果**: pass | fail
**詳細**:
\`\`\`
(ツールの出力)
\`\`\`

## リントチェック

**ツール**: ruff check | flake8
**結果**: pass | warning | fail
**詳細**:
\`\`\`
(ツールの出力)
\`\`\`

## 型チェック

**ツール**: mypy | pyright
**結果**: pass | warning | fail | not_applicable
**詳細**:
\`\`\`
(ツールの出力)
\`\`\`

## テストチェック

**ツール**: pytest
**結果**: pass | warning | fail | not_applicable
**カバレッジ**: XX%
**詳細**:
\`\`\`
(pytest の出力)
\`\`\`

## 構造チェック

- [x] 仮想環境が使用されている
- [x] 依存関係ファイルが存在する (pyproject.toml | requirements.txt)
- [x] ロックファイルが存在する (uv.lock) ※モダンツールチェーンのみ
- [x] __init__.py が適切に配置されている
- [x] docstring が存在する

## 総合評価

**verdict**: pass | warning | fail

**判定基準（モダンツールチェーン）**:
- ruff format fail → 全体 fail (severity: critical)
- ruff check error あり → 全体 fail (severity: critical)
- mypy/pyright strict モードで型エラー → 全体 fail (severity: major)
- テスト失敗 → 全体 fail (severity: critical)
- カバレッジ 80% 未満 → warning (severity: major)
- それ以外 → pass

**判定基準（従来のツールチェーン）**:
- black fail → 全体 fail (severity: critical)
- flake8 error あり → 全体 fail (severity: critical)
- mypy strict モードで型エラー → 全体 fail (severity: major)
- テスト失敗 → 全体 fail (severity: critical)
- カバレッジ 80% 未満 → warning (severity: major)
- それ以外 → pass

**推奨アクション**:
(fail の場合の修正方法を記載)

モダンツールチェーンの場合:
- フォーマット修正: `ruff format src/`
- リント修正: `ruff check --fix src/`

従来のツールチェーンの場合:
- フォーマット修正: `black src/`
- リント修正: 手動で修正
```

## ツールチェーン自動検出ロジック

```bash
if [ -f "pyproject.toml" ] && grep -q "tool.ruff" pyproject.toml; then
    echo "モダンツールチェーン（Ruff）を検出"
    TOOLCHAIN="modern"
elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
    echo "従来のツールチェーン（black + flake8）を検出"
    TOOLCHAIN="traditional"
else
    echo "Python プロジェクトではない可能性"
    exit 1
fi
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
- モダンツールチェーン: `ruff`, `mypy`/`pyright`, `pytest` がインストールされている前提
- 従来のツールチェーン: `black`, `flake8`, `mypy`, `pytest` がインストールされている前提
- テストチェックは `worker_type: testing` のタスクでのみ実施

## パフォーマンス比較

**モダンツールチェーン（Ruff）**:
- フォーマット+リントチェック: ~0.1秒（大規模プロジェクトでも ~1秒）

**従来のツールチェーン（black + flake8）**:
- フォーマット+リントチェック: ~5秒（大規模プロジェクトでは ~30秒）

**結果**: Ruff は **10-100倍高速**

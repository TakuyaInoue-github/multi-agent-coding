---
name: python-quality-check
description: Python コードの品質チェック（Gate2 評価で Observer が使用）
disable-model-invocation: false
user-invocable: true
allowed-tools: [bash]
---

# Python 品質チェック Skill

Gate2 評価時に Python コードの品質をチェックします。

## 使用方法

```bash
/python-quality-check "task-001"
```

## 引数

- `$0` = タスクID

## チェック項目

### 1. フォーマットチェック (ruff format)

```bash
ruff format --check $(find . -name "*.py" | grep -v .venv)
```

**評価**: pass | fail

### 2. リントチェック (ruff check)

```bash
ruff check $(find . -name "*.py" | grep -v .venv)
```

**評価**: pass | warning | fail

Ruff は以下を統合チェック：
- pycodestyle (E, W)
- pyflakes (F)
- isort (I)
- pep8-naming (N)
- pyupgrade (UP)
- flake8-bugbear (B)
- その他 900以上のルール

### 3. 型チェック (mypy / pyright)

```bash
mypy $(find . -name "*.py" | grep -v .venv) || pyright
```

**評価**: pass | warning | fail | not_applicable

### 4. テストチェック (pytest)

テストタスクのみ実行：

```bash
pytest --cov --cov-report=term-missing
```

**評価**:
- pass: 全通過 & カバレッジ 80%以上
- warning: 全通過 & カバレッジ 80%未満
- fail: テスト失敗

### 5. 構造チェック

- [ ] `.venv/` 存在（仮想環境）
- [ ] `pyproject.toml` 存在
- [ ] `uv.lock` 存在（uv使用時）
- [ ] `__init__.py` 適切配置
- [ ] docstring 存在

## 出力

`tasks/$TASK_ID/quality_report.md`:

```markdown
# Python 品質チェックレポート

タスクID: $TASK_ID
実行日時: $(date)

## フォーマットチェック (ruff format)
**結果**: pass | fail

## リントチェック (ruff check)
**結果**: pass | warning | fail

## 型チェック (mypy/pyright)
**結果**: pass | warning | fail | not_applicable

## テストチェック (pytest)
**結果**: pass | warning | fail | not_applicable
**カバレッジ**: XX%

## 構造チェック
- [x] 仮想環境
- [x] pyproject.toml
- [x] uv.lock
- [x] __init__.py
- [x] docstring

## 総合評価
**verdict**: pass | warning | fail

**判定基準**:
- ruff format fail → fail (critical)
- ruff check error → fail (critical)
- mypy strict で型エラー → fail (major)
- テスト失敗 → fail (critical)
- カバレッジ 80%未満 → warning (major)

**推奨アクション**:
- フォーマット修正: `ruff format src/`
- リント修正: `ruff check --fix src/`
```

## 関連ファイル

- `.multi-agent/config/languages/python.md` - Python ガイドライン
- `.multi-agent/config/RULEBOOK.md` - 評価基準

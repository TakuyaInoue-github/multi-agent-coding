---
name: python-setup
description: |
  Set up a Python project environment. Invoke automatically when starting a new Python project
  or when the environment is not yet configured.
  Triggers: "setup Python project", "initialize Python", "create Python environment",
  missing pyproject.toml or .venv, first task in a Python project.
  Sets up: uv, Python version pin, .venv, pyproject.toml, ruff, mypy, pytest.
disable-model-invocation: false
user-invocable: true
allowed-tools: [editor, bash]
---

# Python セットアップ Skill

Python プロジェクトの初期セットアップタスクを生成します（uv + Ruff による高速ツールチェーン）。

## 使用方法

```bash
/python-setup "3.11"
/python-setup "$PYTHON_VERSION"
```

## 引数

- `$0` = Python バージョン（例: "3.11", "3.12"）

## 生成されるセットアップ手順

### 1. uv のインストール確認

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### 2. プロジェクト初期化

```bash
uv init
uv python pin {{version}}
uv venv
```

### 3. pyproject.toml の作成

```toml
[project]
name = "{{project_name}}"
version = "0.1.0"
requires-python = ">={{version}}"
dependencies = []

[project.optional-dependencies]
dev = [
    "ruff>=0.1.0",
    "mypy>=1.5.0",
    "pytest>=7.4.0",
    "pytest-cov>=4.1.0",
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.ruff]
line-length = 88
target-version = "py{{version_short}}"

[tool.ruff.lint]
select = ["E", "W", "F", "I", "N", "UP", "B", "C4"]

[tool.ruff.lint.per-file-ignores]
"__init__.py" = ["F401"]
"tests/*" = ["D"]

[tool.mypy]
python_version = "{{version}}"
strict = true
```

### 4. 開発ツールのインストール

```bash
uv add --dev ruff mypy pytest pytest-cov
```

### 5. ディレクトリ構造

```
src/{{module_name}}/
├── __init__.py
└── main.py
tests/
├── __init__.py
└── test_main.py
```

### 6. .gitignore

```
.venv/
uv.lock
__pycache__/
*.py[cod]
.pytest_cache/
.coverage
.mypy_cache/
.ruff_cache/
dist/
*.egg-info/
```

## 出力される spec.md

```yaml
---
task_id: task-setup-python
worker_type: coding
depends_on: []
parallel_ok: false
output_artifacts:
  - .venv/
  - pyproject.toml
  - uv.lock
  - src/{{module_name}}/__init__.py
  - tests/test_main.py
  - .gitignore
permissions:
  filesystem:
    write: [., src/, tests/]
  execution:
    allowed: [uv, python]
environment_verified: true
---

## 指示内容

Python {{version}} プロジェクトの初期セットアップ（uv + Ruff）。

1. uv をインストール
2. `uv init` でプロジェクト初期化
3. `uv python pin {{version}}` でバージョン固定
4. `uv venv` で仮想環境作成
5. pyproject.toml 作成（Ruff/mypy 設定含む）
6. `uv add --dev ruff mypy pytest pytest-cov` で開発ツールインストール
7. ディレクトリ構造作成（src/, tests/）
8. .gitignore 作成

## 成功基準

- [ ] `.venv/bin/activate` が存在する
- [ ] `pyproject.toml` に `[tool.ruff]`, `[tool.mypy]` がある
- [ ] `uv.lock` が存在する
- [ ] `src/{{module_name}}/__init__.py` が存在する
- [ ] `uv add --dev pytest` が実行可能
```

## 関連ファイル

- `.multi-agent/config/languages/python.md` - Python ガイドライン

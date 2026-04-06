---
name: python-setup
description: Python プロジェクトの初期セットアップタスクを生成（2025年モダンツールチェーン対応）
disable-model-invocation: false
user-invocable: true
allowed-tools: [editor, bash]
---

# Python セットアップ Skill

Commander が Python プロジェクトの初期セットアップタスクを生成するために使用します。

**2025年更新**: uv + Ruff による超高速セットアップに対応しました。

## 使用方法

```bash
/python-setup "3.11" "modern"
/python-setup "$VERSION" "$TOOLCHAIN"
```

## 引数

- `$0` = Python バージョン（例: "3.11", "3.12"）
- `$1` = ツールチェーン（オプション、デフォルト: "modern"）
  - **"modern"**: uv + Ruff（2025年推奨、超高速）
  - **"traditional"**: venv + pip + black + flake8（後方互換性）

## 生成されるタスク仕様

このスキルは `tasks/task-setup-python/spec.md` を生成します。

---

## モダンツールチェーン（toolchain: "modern"）

### タスク内容

1. **uv のインストール確認**
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```

2. **プロジェクト初期化**
   ```bash
   uv init
   ```

3. **Python バージョンの固定**
   ```bash
   uv python pin {{version}}
   ```

4. **仮想環境の作成**
   ```bash
   uv venv
   source .venv/bin/activate  # Linux/Mac
   ```

5. **pyproject.toml の作成**
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
   ignore = []

   [tool.ruff.lint.per-file-ignores]
   "__init__.py" = ["F401"]
   "tests/*" = ["D"]

   [tool.ruff.format]
   quote-style = "double"
   indent-style = "space"

   [tool.mypy]
   python_version = "{{version}}"
   strict = true
   warn_return_any = true
   warn_unused_configs = true
   ```

6. **開発ツールのインストール**
   ```bash
   uv add --dev ruff mypy pytest pytest-cov
   ```

7. **ディレクトリ構造の作成**
   ```
   src/
   ├── {{module_name}}/
   │   ├── __init__.py
   │   └── main.py
   tests/
   ├── __init__.py
   └── test_main.py
   ```

8. **.gitignore の作成**
   ```
   # uv
   .venv/
   uv.lock

   # Python
   __pycache__/
   *.py[cod]
   *$py.class
   *.so
   .Python

   # Testing
   .pytest_cache/
   .coverage
   htmlcov/
   .mypy_cache/
   .ruff_cache/

   # Distribution
   dist/
   build/
   *.egg-info/
   ```

---

## 従来のツールチェーン（toolchain: "traditional"）

### タスク内容

1. **仮想環境の作成**
   ```bash
   python{{version}} -m venv venv
   source venv/bin/activate
   ```

2. **requirements.txt の作成**
   ```
   # Add your production dependencies here
   ```

3. **requirements-dev.txt の作成**
   ```
   pytest>=7.4.0
   pytest-cov>=4.1.0
   black>=23.0.0
   flake8>=6.0.0
   mypy>=1.5.0
   isort>=5.12.0
   ```

4. **pyproject.toml の作成**（black, mypy の設定）
   ```toml
   [tool.black]
   line-length = 88
   target-version = ['py{{version_short}}']

   [tool.mypy]
   python_version = "{{version}}"
   strict = true
   ```

5. **ディレクトリ構造の作成**
   ```
   src/
   ├── {{module_name}}/
   │   ├── __init__.py
   │   └── main.py
   tests/
   ├── __init__.py
   └── test_main.py
   ```

6. **.gitignore の作成**（Python 用）

---

## 出力

### spec.md の構造（モダンツールチェーン）

```yaml
---
task_id: task-setup-python
worker_type: coding
depends_on: []
parallel_ok: false
input_artifacts: []
output_artifacts:
  - .venv/
  - pyproject.toml
  - uv.lock
  - src/{{module_name}}/__init__.py
  - src/{{module_name}}/main.py
  - tests/__init__.py
  - tests/test_main.py
  - .gitignore
permissions:
  filesystem:
    write: [., src/, tests/]
  execution:
    allowed: [uv, python]
required_packages: []
environment_verified: true
commander_reasoning: |
  Python {{version}} プロジェクトの初期セットアップタスク。
  uv + Ruff による超高速モダンツールチェーンを使用。
---

## 指示内容

Python {{version}} プロジェクトの初期セットアップを行う（モダンツールチェーン: uv + Ruff）。

1. uv をインストールする（`curl -LsSf https://astral.sh/uv/install.sh | sh`）
2. プロジェクトを初期化する（`uv init`）
3. Python バージョンを固定する（`uv python pin {{version}}`）
4. 仮想環境を作成する（`uv venv`）
5. `pyproject.toml` を作成する（プロジェクトメタデータ、Ruff/mypy 設定を含む）
6. 開発ツールをインストールする（`uv add --dev ruff mypy pytest pytest-cov`）
7. ディレクトリ構造を作成する（`src/{{module_name}}/`, `tests/`）
8. `.gitignore` を作成する（Python + uv 用）

## 期待する成果物

- 仮想環境が作成されている（`.venv/` ディレクトリ）
- `pyproject.toml` が存在し、依存関係と開発ツール設定が含まれている
- `uv.lock` が存在する（依存関係ロックファイル）
- `src/{{module_name}}/` と `tests/` ディレクトリが存在する
- `.gitignore` が存在し、Python と uv 固有のパターンが含まれている

## 成功基準

- [ ] `.venv/bin/activate` が存在する（仮想環境が作成されている）
- [ ] `pyproject.toml` に `[project]`, `[tool.ruff]`, `[tool.mypy]` セクションが存在する
- [ ] `uv.lock` が存在する
- [ ] `src/{{module_name}}/__init__.py` と `tests/test_main.py` が存在する
- [ ] `.gitignore` に `.venv/`, `__pycache__/`, `.ruff_cache/` が含まれている
- [ ] `uv add --dev pytest` などが実行できる状態である

## 注意事項

- uv は Rust製で pip の 10-100倍高速
- Ruff は black + flake8 + isort など 10以上のツールを統合
- `pyproject.toml` が PEP 621 準拠の標準形式
- 従来の venv + pip を使いたい場合は `toolchain: "traditional"` を指定
```

## 関連ファイル

- `.multi-agent/config/languages/python.md` - Python プロジェクトガイドライン
- `.multi-agent/templates/task/spec.md` - タスク仕様テンプレート

## 使用例

### モダンツールチェーン（2025年推奨）

```bash
/python-setup "3.11" "modern"
```

### 従来のツールチェーン

```bash
/python-setup "3.11" "traditional"
```

### デフォルト（modern）

```bash
/python-setup "3.12"
```

## 次のステップ

セットアップタスク完了後、以下のタスクを続けて作成することを推奨：

1. **依存関係インストール確認タスク**（モダン）
   ```bash
   uv sync
   ```

2. **依存関係インストール確認タスク**（従来）
   ```bash
   pip install -r requirements-dev.txt
   ```

3. **品質チェック設定の検証タスク**
   ```bash
   ruff format --check src/
   ruff check src/
   mypy src/
   pytest
   ```

## パフォーマンス比較

**モダンツールチェーン（uv + Ruff）**:
- 環境構築: ~1秒
- リント+フォーマット: ~0.1秒

**従来のツールチェーン（pip + black + flake8）**:
- 環境構築: ~30秒
- リント+フォーマット: ~5秒

**結果**: **10-100倍の高速化**を達成

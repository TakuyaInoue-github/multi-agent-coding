---
name: python-setup
description: Python プロジェクトの初期セットアップタスクを生成
disable-model-invocation: false
user-invocable: true
allowed-tools: [editor, bash]
---

# Python セットアップ Skill

Commander が Python プロジェクトの初期セットアップタスクを生成するために使用します。

## 使用方法

```bash
/python-setup "3.11" "pytest,black,flake8,mypy"
/python-setup "$VERSION" "$DEV_TOOLS"
```

## 引数

- `$0` = Python バージョン（例: "3.11", "3.12"）
- `$1` = 開発ツールのカンマ区切りリスト（オプション、デフォルト: "pytest,black,flake8,mypy"）

## 生成されるタスク仕様

このスキルは `tasks/task-setup-python/spec.md` を生成します。

### タスク内容

1. **仮想環境の作成**
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # Linux/Mac
   ```

2. **requirements.txt の作成**
   - 本番依存関係を記載
   - バージョンピン推奨

3. **requirements-dev.txt の作成**
   - 開発依存関係（テスト・リンター・フォーマッター）
   ```
   pytest>=7.4.0
   pytest-cov>=4.1.0
   black>=23.0.0
   flake8>=6.0.0
   mypy>=1.5.0
   ```

4. **pyproject.toml の作成**
   - プロジェクトメタデータ
   - black, mypy の設定
   ```toml
   [tool.black]
   line-length = 88
   target-version = ['py311']

   [tool.mypy]
   python_version = "3.11"
   strict = true
   ```

5. **ディレクトリ構造の作成**
   ```
   src/
   ├── __init__.py
   └── (module_name)/
       └── __init__.py
   tests/
   └── __init__.py
   ```

6. **.gitignore の作成**（Python 用）
   ```
   venv/
   .venv/
   __pycache__/
   *.pyc
   .pytest_cache/
   .mypy_cache/
   .coverage
   htmlcov/
   dist/
   *.egg-info/
   ```

## 出力

### spec.md の構造

```yaml
---
task_id: task-setup-python
worker_type: coding
depends_on: []
parallel_ok: false
input_artifacts: []
output_artifacts:
  - venv/
  - requirements.txt
  - requirements-dev.txt
  - pyproject.toml
  - src/__init__.py
  - tests/__init__.py
  - .gitignore
permissions:
  filesystem:
    write: [., src/, tests/]
  execution:
    allowed: [python, python3, pip]
required_packages: []
environment_verified: true
commander_reasoning: |
  Python プロジェクトの初期セットアップタスク。
  仮想環境と開発ツールの設定を含む。
---

## 指示内容

Python {{version}} プロジェクトの初期セットアップを行う。

1. 仮想環境を作成する（`python3 -m venv venv`）
2. `requirements.txt` を作成する（本番依存関係）
3. `requirements-dev.txt` を作成する（開発ツール: {{dev_tools}}）
4. `pyproject.toml` を作成する（black, mypy の設定を含む）
5. ディレクトリ構造を作成する（`src/`, `tests/`）
6. `.gitignore` を作成する（Python 用）

## 期待する成果物

- 仮想環境が作成されている（`venv/` ディレクトリ）
- `requirements.txt` が存在する
- `requirements-dev.txt` が存在し、開発ツールが列挙されている
- `pyproject.toml` が存在し、black と mypy の設定が含まれている
- `src/` と `tests/` ディレクトリが存在する
- `.gitignore` が存在し、Python 固有のパターンが含まれている

## 成功基準

- [ ] `venv/bin/activate` が存在する（仮想環境が作成されている）
- [ ] `requirements-dev.txt` に {{dev_tools}} が含まれている
- [ ] `pyproject.toml` に `[tool.black]` と `[tool.mypy]` セクションが存在する
- [ ] `src/__init__.py` と `tests/__init__.py` が存在する
- [ ] `.gitignore` に `venv/`, `__pycache__/` が含まれている

## 注意事項

- 仮想環境の有効化コマンドはプラットフォーム依存（Linux/Mac: `source`, Windows: `Scripts\activate`）
- パッケージのインストールはこのタスクでは行わない（次のタスクで実施）
```

## 関連ファイル

- `.multi-agent/config/languages/python.md` - Python プロジェクトガイドライン
- `.multi-agent/templates/task/spec.md` - タスク仕様テンプレート

## 使用例

### 基本的な使用

```bash
/python-setup "3.11" "pytest,black,flake8"
```

### フルスタックの開発ツール

```bash
/python-setup "3.12" "pytest,pytest-cov,black,flake8,mypy,pylint"
```

## 次のステップ

セットアップタスク完了後、以下のタスクを続けて作成することを推奨：

1. **依存関係インストールタスク**
   ```bash
   pip install -r requirements-dev.txt
   ```

2. **品質チェック設定の検証タスク**
   ```bash
   black --check src/
   flake8 src/
   mypy src/
   ```

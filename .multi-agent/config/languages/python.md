# Python プロジェクトガイドライン

このドキュメントは Commander と Observer が Python プロジェクトでタスクを分解・評価する際に参照します。

---

## 環境管理

### パッケージマネージャー（2025年推奨）

**推奨**: **`uv`** - Rust製の超高速パッケージマネージャー（pip/venv/pip-tools の10-100倍高速）

```bash
# uv のインストール
curl -LsSf https://astral.sh/uv/install.sh | sh

# プロジェクト初期化
uv init

# Python バージョン指定（自動ダウンロード）
uv python pin 3.11

# 仮想環境の作成と有効化（自動）
uv venv
source .venv/bin/activate  # Linux/Mac
.venv\Scripts\activate     # Windows

# パッケージのインストール
uv add requests
uv add --dev pytest ruff mypy
```

**従来の方法（互換性のため残す）**:
```bash
# venv + pip を使用する場合
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 依存関係管理

**ファイル**:
- **`pyproject.toml`**: プロジェクトメタデータと依存関係（推奨、PEP 621準拠）
- **`uv.lock`**: 依存関係のロックファイル（uv 使用時、自動生成）
- `requirements.txt`: 従来形式（後方互換性のため）

**pyproject.toml 例**:
```toml
[project]
name = "myproject"
version = "0.1.0"
dependencies = [
    "requests>=2.31.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.4.0",
    "ruff>=0.1.0",
    "mypy>=1.5.0",
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
```

**タスク分解時の注意**:
- パッケージ追加タスクは独立させる
- `pyproject.toml` と `uv.lock` の更新を output_artifacts に含める
- uv 使用時は `uv add` コマンドを使用

---

## コード品質

### オールインワンツール: Ruff（2025年推奨）

**推奨**: **`Ruff`** - Rust製の超高速リンター＆フォーマッター

**特徴**:
- black, isort, flake8, pylint など **10以上のツールを統合**
- **900以上のリントルール**をサポート
- 従来のツールより **10-100倍高速**
- フォーマットとリントを1つのツールで完結

```bash
# インストール
uv add --dev ruff

# フォーマット
ruff format src/
ruff format --check src/  # CI での確認

# リント
ruff check src/
ruff check --fix src/  # 自動修正

# 両方を実行
ruff check --fix src/ && ruff format src/
```

**設定例** (`pyproject.toml`):
```toml
[tool.ruff]
line-length = 88
target-version = "py311"

[tool.ruff.lint]
select = [
    "E",   # pycodestyle errors
    "W",   # pycodestyle warnings
    "F",   # pyflakes
    "I",   # isort
    "N",   # pep8-naming
    "UP",  # pyupgrade
    "B",   # flake8-bugbear
    "C4",  # flake8-comprehensions
]
ignore = []

[tool.ruff.lint.per-file-ignores]
"__init__.py" = ["F401"]  # unused import in __init__.py
"tests/*" = ["D"]  # docstring in tests

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
```

### 従来のツール（後方互換性のため残す）

**black + flake8 を使用する場合**:
```bash
black src/
flake8 src/
```

**注意**: Ruff は black と flake8 の完全な置き換えとして使用できます。新規プロジェクトでは Ruff を推奨します。

### 型チェック

**推奨**: `mypy` (業界標準) または `pyright` (高速、VS Code統合)

```bash
# mypy
uv add --dev mypy
mypy src/

# pyright（VS Code使用時）
uv add --dev pyright
pyright src/
```

**ベストプラクティス**:
- Python 3.9+ では型ヒントを積極的に使用
- 公開 API には必ず型ヒントを付ける
- `typing` モジュールの `Optional`, `Union`, `List` などを活用

```python
from typing import Optional, List

def process_items(items: List[str], limit: Optional[int] = None) -> List[str]:
    """アイテムを処理する"""
    if limit:
        items = items[:limit]
    return [item.upper() for item in items]
```

---

## テスト

### テストフレームワーク

**推奨**: `pytest` (最も人気のあるテストフレームワーク)

```bash
pytest tests/
pytest --cov=src tests/  # カバレッジ測定
```

**ディレクトリ構造**:
```
project/
├── src/
│   └── mymodule/
│       ├── __init__.py
│       └── core.py
└── tests/
    ├── __init__.py
    └── test_core.py
```

**ベストプラクティス**:
- テストファイル名: `test_*.py` または `*_test.py`
- テスト関数名: `test_*`
- カバレッジ目標: 80% 以上

---

## タスク分解時の考慮事項

### セットアップタスク（2025年推奨: uv + Ruff）

最初に以下を含むセットアップタスクを配置：
1. **uv のインストール確認**
2. **Python バージョンの固定**（`uv python pin 3.11`）
3. **仮想環境の作成**（`uv venv`）
4. **pyproject.toml の作成**（プロジェクトメタデータと依存関係）
5. **開発ツールのインストール**（`uv add --dev ruff mypy pytest pytest-cov`）
6. **ディレクトリ構造の作成** (`src/`, `tests/`)

**従来の方法（venv + pip）**:
1. 仮想環境の作成（`python -m venv venv`）
2. `requirements.txt` と `requirements-dev.txt` の作成
3. 開発ツールのインストール（`pip install -r requirements-dev.txt`）

### パッケージ管理タスク

新しいパッケージを追加する場合：

**uv 使用時**:
- `pyproject.toml` と `uv.lock` の更新を output_artifacts に明記
- `uv add package-name` の実行を指示に含める
- `environment_verified: true` に更新

**従来の方法**:
- `requirements.txt` の更新を output_artifacts に明記
- `pip install -r requirements.txt` の実行を指示に含める

### テストタスク

実装タスクとは独立させる：
- input_artifacts: 実装済みのコード
- output_artifacts: `tests/test_*.py`
- success_criteria: カバレッジ 80% 以上、全テスト通過

---

## Gate2 評価基準（Observer 用）

Python コードの品質チェック項目：

### 必須項目 (severity: critical)

**モダンツールチェーン（2025年推奨）**:
- [ ] `ruff format --check` でフォーマット確認が通過
- [ ] `ruff check` で警告・エラーなし
- [ ] 仮想環境が使用されている（`.venv/` 存在）
- [ ] `pyproject.toml` が存在し、依存関係が記載されている（uv使用時）

**従来のツールチェーン（後方互換性）**:
- [ ] `black --check` でフォーマット確認が通過
- [ ] `flake8` で警告・エラーなし
- [ ] `requirements.txt` が存在し、依存関係が記載されている

### 推奨項目 (severity: major)

- [ ] `mypy` または `pyright` で型エラーなし（型ヒントが使われている場合）
- [ ] `pytest` でテストがすべて通過
- [ ] カバレッジが 80% 以上（テストタスクの場合）
- [ ] `__init__.py` が適切に配置されている
- [ ] docstring が主要な関数・クラスに存在する
- [ ] `uv.lock` が存在し、依存関係が固定されている（uv使用時）

### 任意項目 (severity: minor)

- [ ] `pylint` スコアが 8.0 以上
- [ ] pre-commit フックが設定されている
- [ ] CI/CD 設定ファイルが存在する (`.github/workflows/`, `.gitlab-ci.yml`)

---

## よくある落とし穴

### 1. グローバルインストールの使用

❌ **悪い例**:
```bash
pip install requests
python my_script.py
```

✅ **良い例（2025年推奨: uv）**:
```bash
uv venv
source .venv/bin/activate
uv add requests
python my_script.py
```

✅ **良い例（従来の方法）**:
```bash
python -m venv venv
source venv/bin/activate
pip install requests
python my_script.py
```

### 2. 型ヒントの欠如

❌ **悪い例**:
```python
def calculate(a, b):
    return a + b
```

✅ **良い例**:
```python
def calculate(a: int, b: int) -> int:
    return a + b
```

### 3. テストの不足

❌ **悪い例**: 実装だけして終わり

✅ **良い例**: 実装タスク + テストタスクを別々に作成

---

## 参考資料

### 公式ドキュメント

- [PEP 8 - Style Guide for Python Code](https://peps.python.org/pep-0008/)
- [PEP 621 - Storing project metadata in pyproject.toml](https://peps.python.org/pep-0621/)
- [pytest - Full-featured Python testing tool](https://docs.pytest.org/)
- [mypy - Optional Static Typing for Python](https://mypy.readthedocs.io/)

### モダンツール（2025年推奨）

- [Ruff - An extremely fast Python linter and code formatter](https://docs.astral.sh/ruff/)
- [uv - An extremely fast Python package installer and resolver](https://docs.astral.sh/uv/)
- [Pyright - Fast type checker for Python](https://github.com/microsoft/pyright)

### 従来のツール

- [Black - The uncompromising code formatter](https://black.readthedocs.io/)
- [Flake8 - Your Tool For Style Guide Enforcement](https://flake8.pycqa.org/)
- [isort - A Python utility / library to sort imports](https://pycqa.github.io/isort/)

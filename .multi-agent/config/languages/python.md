# Python プロジェクトガイドライン

このドキュメントは Commander と Observer が Python プロジェクトでタスクを分解・評価する際に参照します。

---

## 環境管理

### 仮想環境

**推奨**: `venv` (Python 標準) または `poetry` (依存関係管理強化版)

```bash
# venv を使用する場合
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows

# poetry を使用する場合
poetry install
poetry shell
```

### 依存関係管理

**ファイル**:
- `requirements.txt`: 本番環境の依存関係
- `requirements-dev.txt`: 開発環境の依存関係（テスト・リンターなど）
- または `pyproject.toml` + `poetry.lock` (poetry 使用時)

**タスク分解時の注意**:
- パッケージ追加タスクは独立させる
- `requirements.txt` の更新は明示的な output_artifacts に含める

---

## コード品質

### フォーマッター

**推奨**: `black` (妥協のないコードフォーマッター)

```bash
black src/
black --check src/  # CI での確認
```

**設定例** (`pyproject.toml`):
```toml
[tool.black]
line-length = 88
target-version = ['py311']
include = '\.pyi?$'
```

### リンター

**推奨**: `flake8` (PEP 8 準拠チェック) + `pylint` (より厳格)

```bash
flake8 src/
pylint src/
```

**設定例** (`.flake8`):
```ini
[flake8]
max-line-length = 88
extend-ignore = E203, W503
exclude = .git,__pycache__,venv
```

### 型チェック

**推奨**: `mypy` (静的型チェッカー)

```bash
mypy src/
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

### セットアップタスク

最初に以下を含むセットアップタスクを配置：
1. 仮想環境の作成
2. `requirements.txt` の作成
3. 開発ツールのインストール（`black`, `flake8`, `mypy`, `pytest`）
4. `pyproject.toml` の設定
5. ディレクトリ構造の作成 (`src/`, `tests/`)

### パッケージ管理タスク

新しいパッケージを追加する場合：
- `requirements.txt` の更新を output_artifacts に明記
- `pip install -r requirements.txt` の実行を指示に含める
- `environment_verified: true` に更新

### テストタスク

実装タスクとは独立させる：
- input_artifacts: 実装済みのコード
- output_artifacts: `tests/test_*.py`
- success_criteria: カバレッジ 80% 以上、全テスト通過

---

## Gate2 評価基準（Observer 用）

Python コードの品質チェック項目：

### 必須項目 (severity: critical)

- [ ] `black --check` でフォーマット確認が通過
- [ ] `flake8` で警告・エラーなし
- [ ] 仮想環境が使用されている（`venv/` または `.venv/` 存在）
- [ ] `requirements.txt` が存在し、依存関係が記載されている

### 推奨項目 (severity: major)

- [ ] `mypy` で型エラーなし（型ヒントが使われている場合）
- [ ] `pytest` でテストがすべて通過
- [ ] カバレッジが 80% 以上（テストタスクの場合）
- [ ] `__init__.py` が適切に配置されている
- [ ] docstring が主要な関数・クラスに存在する

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

✅ **良い例**:
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

- [PEP 8 - Style Guide for Python Code](https://peps.python.org/pep-0008/)
- [Black - The uncompromising code formatter](https://black.readthedocs.io/)
- [pytest - Full-featured Python testing tool](https://docs.pytest.org/)
- [mypy - Optional Static Typing for Python](https://mypy.readthedocs.io/)

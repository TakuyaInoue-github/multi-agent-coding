# AGENTS.md - Codex エージェント共通設定

このファイルはプロジェクト全体に適用されます。
タスク固有の指示は `tasks/task-xxx/AGENTS.md` を参照してください。

---

## あなたの役割

あなたは **Worker エージェントから委譲された実装タスク** を担当します。

- `tasks/task-xxx/spec.md` に従って実装する
- 実装後、このファイルの **品質チェック** を自分で実行して全通過を確認する
- 通過しない場合は自分で修正してから終了する

---

## プロジェクト構造

```
/
├── tasks/task-xxx/         # タスクごとの作業ディレクトリ
│   ├── spec.md             # タスク仕様（あなたへの指示）
│   └── AGENTS.md           # タスク固有の品質チェック（必ず読む）
├── runtime/                # Commander/Observer が管理（書き込み禁止）
├── .multi-agent/           # フレームワーク設定（変更禁止）
└── AGENTS.md               # このファイル
```

---

## Git ルール

| 操作 | 可否 |
|------|------|
| `task/task-xxx` ブランチへのコミット | ✅ |
| `task/task-xxx` ブランチへのプッシュ | ✅ |
| 他ブランチへの操作 | ❌ |
| `develop` / `main` へのマージ | ❌ |
| `runtime/` への書き込み | ❌ |

コミットメッセージ形式: `feat: task-xxx <作業概要>`

---

## 実装完了の定義

以下をすべて満たしたとき、実装完了とみなす：

1. `spec.md` の `output_artifacts` に列挙されたファイルがすべて存在する
2. `spec.md` の `permissions` の制約を守っている
3. 下記の品質チェックがすべて通過している
4. 変更がコミットされている

---

## 利用可能なスキル

以下のスキルが `.agents/skills/` に用意されている。実装・検証時に積極的に活用すること。

| スキル名 | 用途 | 自動発動タイミング |
|---------|------|-----------------|
| `python-quality-check` | Python コード品質チェック | .py ファイル実装後、コミット前 |
| `typescript-quality-check` | TypeScript コード品質チェック | .ts/.tsx ファイル実装後、コミット前 |
| `go-quality-check` | Go コード品質チェック | .go ファイル実装後、コミット前 |
| `java-quality-check` | Java コード品質チェック | .java ファイル実装後、コミット前 |
| `python-setup` | Python 環境セットアップ | pyproject.toml/.venv がない場合 |
| `typescript-setup` | TypeScript 環境セットアップ | package.json/tsconfig.json がない場合 |
| `go-setup` | Go 環境セットアップ | go.mod がない場合 |
| `java-setup` | Java 環境セットアップ | pom.xml/build.gradle がない場合 |

---

## 品質チェック（実装後に必ず実行すること）

使用する言語を `spec.md` または `tasks/task-xxx/AGENTS.md` で確認し、対応するチェックを実行する。
**対応する quality-check スキルを使うと確実。**

### Python（pyproject.toml に `[tool.ruff]` がある場合）

```bash
# フォーマット確認
ruff format --check $(find . -name "*.py" | grep -v .venv | grep -v __pycache__)

# リント確認
ruff check $(find . -name "*.py" | grep -v .venv | grep -v __pycache__)

# 型チェック（型ヒントがある場合）
mypy src/ || pyright src/

# テスト（worker_type: testing の場合）
pytest --cov --cov-report=term-missing
```

**自動修正してから再確認する場合**:
```bash
ruff check --fix src/ && ruff format src/
```

**判定**:
- `ruff format --check` fail → 自動修正して再確認
- `ruff check` error → 自動修正して再確認、自動修正不可なら手動修正
- `mypy` / `pyright` error → 手動修正
- `pytest` fail → テストコードまたは実装を修正

### TypeScript

```bash
# 型チェック
npx tsc --noEmit

# フォーマット確認
npx prettier --check "src/**/*.{ts,tsx}"

# リント確認
npx eslint "src/**/*.{ts,tsx}"

# テスト（worker_type: testing の場合）
npx vitest run --coverage || npx jest --coverage

# ビルド確認
npm run build
```

**自動修正してから再確認する場合**:
```bash
npx prettier --write "src/**/*.{ts,tsx}"
npx eslint --fix "src/**/*.{ts,tsx}"
```

### Go

```bash
# フォーマット確認
gofmt -d .

# 静的解析
go vet ./...

# ビルド確認
go build ./...

# テスト（worker_type: testing の場合）
go test -v -cover ./...
```

**自動修正してから再確認する場合**:
```bash
gofmt -w .
```

### Java (Maven)

```bash
# コンパイル確認
mvn compile -q

# スタイルチェック
mvn checkstyle:check -q

# テスト（worker_type: testing の場合）
mvn test
```

---

## 品質チェック失敗時の対応

1. **自動修正可能な場合**: 自動修正コマンドを実行して再確認
2. **手動修正が必要な場合**: エラーメッセージを読んで修正
3. **3回修正しても通過しない場合**: 作業を停止してエラー内容を報告する

---

## 禁止事項

- `spec.md` の `permissions.network.disallowed` に記載されたネットワークアクセス
- `permissions.execution.disallowed` に記載されたコマンドの実行
- `output_artifacts` に記載されていないファイルへの書き込み（`runtime/` など）
- パッケージの新規インストール（`uv add`, `npm install`, `go get` 等）
  - 必要なパッケージは Commander が事前にインストール済み

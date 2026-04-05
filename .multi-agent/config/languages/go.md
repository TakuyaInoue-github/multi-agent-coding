# Go プロジェクトガイドライン

このドキュメントは Commander と Observer が Go プロジェクトでタスクを分解・評価する際に参照します。

---

## 環境管理

### Go Modules

Go 1.11+ では **Go Modules** が標準の依存関係管理方式です。

```bash
# プロジェクト初期化
go mod init github.com/username/projectname

# 依存関係のインストール
go mod download

# 不要な依存関係の削除と追加
go mod tidy
```

**ファイル**:
- `go.mod` - 依存関係の宣言
- `go.sum` - 依存関係のチェックサム（lockfile）

**タスク分解時の注意**:
- パッケージ追加タスクでは `go.mod` と `go.sum` を output_artifacts に含める
- `go mod tidy` の実行を指示に明記

---

## コード品質

### フォーマッター

**標準**: `gofmt` (Go 公式フォーマッター)

```bash
gofmt -w .          # すべてのファイルをフォーマット
gofmt -d .          # 差分表示（CI 用）
```

または `goimports` (インポート文も整理):

```bash
goimports -w .
```

**重要**: Go コミュニティでは `gofmt` によるフォーマットが**必須**とされています。

### リンター

**推奨**: `golangci-lint` (複数のリンターを統合)

```bash
golangci-lint run
```

**設定例** (`.golangci.yml`):
```yaml
run:
  timeout: 5m
  tests: true

linters:
  enable:
    - gofmt
    - goimports
    - govet
    - errcheck
    - staticcheck
    - unused
    - gosimple
    - ineffassign

linters-settings:
  gofmt:
    simplify: true
  govet:
    check-shadowing: true
```

### 静的解析

**標準**: `go vet` (Go 公式の静的解析ツール)

```bash
go vet ./...
```

主なチェック項目：
- 構造体のフィールドタグの正当性
- Printf 形式の不一致
- 到達不能なコード
- シャドーイングされた変数

---

## テスト

### テストフレームワーク

**標準**: `go test` (Go 組み込み)

```bash
# すべてのパッケージをテスト
go test ./...

# カバレッジ測定
go test -cover ./...
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out  # HTML レポート
```

**ディレクトリ構造**:
```
project/
├── go.mod
├── go.sum
├── main.go
├── handler.go
├── handler_test.go    # テストファイル
├── internal/
│   ├── service.go
│   └── service_test.go
└── pkg/
    ├── util.go
    └── util_test.go
```

**ベストプラクティス**:
- テストファイル名: `*_test.go`
- テスト関数名: `func TestXxx(t *testing.T)`
- ベンチマーク: `func BenchmarkXxx(b *testing.B)`
- カバレッジ目標: 80% 以上

**テーブル駆動テスト** (推奨パターン):
```go
func TestAdd(t *testing.T) {
    tests := []struct {
        name string
        a, b int
        want int
    }{
        {"positive", 1, 2, 3},
        {"negative", -1, -2, -3},
        {"zero", 0, 0, 0},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got := Add(tt.a, tt.b)
            if got != tt.want {
                t.Errorf("Add(%d, %d) = %d; want %d", tt.a, tt.b, got, tt.want)
            }
        })
    }
}
```

---

## エラーハンドリング

### Go の原則

Go ではエラーを**値として扱う**：

```go
func readFile(path string) ([]byte, error) {
    data, err := os.ReadFile(path)
    if err != nil {
        return nil, fmt.Errorf("failed to read file %s: %w", path, err)
    }
    return data, nil
}
```

**ベストプラクティス**:
- `if err != nil` チェックを省略しない
- エラーをラップする際は `%w` を使う（Go 1.13+）
- カスタムエラー型を定義する際は `error` インターフェースを実装

---

## プロジェクト構造

### 標準レイアウト

```
project/
├── cmd/                   # メインアプリケーション
│   └── myapp/
│       └── main.go
├── internal/              # プライベートコード（外部から import 不可）
│   ├── handler/
│   ├── service/
│   └── repository/
├── pkg/                   # 公開ライブラリ（外部から import 可能）
│   └── util/
├── api/                   # API 定義（OpenAPI, Protocol Buffers など）
├── web/                   # Web 静的ファイル
├── scripts/               # ビルド・デプロイスクリプト
├── go.mod
├── go.sum
├── Makefile               # ビルドタスク
└── README.md
```

参考: [golang-standards/project-layout](https://github.com/golang-standards/project-layout)

---

## ビルド

### コンパイル

```bash
# 現在のプラットフォーム用にビルド
go build -o bin/myapp ./cmd/myapp

# クロスコンパイル（例: Linux 用）
GOOS=linux GOARCH=amd64 go build -o bin/myapp-linux ./cmd/myapp
```

### Makefile 例

```makefile
.PHONY: build test lint clean

build:
	go build -o bin/myapp ./cmd/myapp

test:
	go test -v -cover ./...

lint:
	golangci-lint run

fmt:
	gofmt -w .
	goimports -w .

clean:
	rm -rf bin/
```

---

## タスク分解時の考慮事項

### セットアップタスク

最初に以下を含むセットアップタスクを配置：
1. `go mod init` でプロジェクト初期化
2. ディレクトリ構造の作成 (`cmd/`, `internal/`, `pkg/`)
3. `.golangci.yml` の作成
4. `Makefile` の作成

### パッケージ管理タスク

新しいパッケージを追加する場合：
- `go get` でパッケージを追加
- `go mod tidy` で整理
- `go.mod` と `go.sum` を output_artifacts に明記

### テストタスク

実装タスクとは独立させる：
- input_artifacts: 実装済みのコード (`*.go`)
- output_artifacts: `*_test.go`
- success_criteria: カバレッジ 80% 以上、全テスト通過

---

## Gate2 評価基準（Observer 用）

Go コードの品質チェック項目：

### 必須項目 (severity: critical)

- [ ] `gofmt -d .` で差分なし（フォーマット済み）
- [ ] `go vet ./...` でエラーなし
- [ ] `go build` でビルド成功
- [ ] `go.mod` と `go.sum` が存在し、整合している
- [ ] すべての `if err != nil` チェックが適切に処理されている

### 推奨項目 (severity: major)

- [ ] `golangci-lint run` で警告なし
- [ ] `go test ./...` でテストがすべて通過
- [ ] カバレッジが 80% 以上（テストタスクの場合）
- [ ] `goimports` でインポート文が整理されている
- [ ] エラーが適切にラップされている（`%w` 使用）

### 任意項目 (severity: minor)

- [ ] テーブル駆動テストが使用されている
- [ ] ベンチマークテストが存在する（パフォーマンス重視の場合）
- [ ] `internal/` と `pkg/` の使い分けが適切
- [ ] CI/CD 設定ファイルが存在する (`.github/workflows/`)

---

## よくある落とし穴

### 1. エラーチェックの省略

❌ **悪い例**:
```go
data, _ := os.ReadFile(path)
```

✅ **良い例**:
```go
data, err := os.ReadFile(path)
if err != nil {
    return fmt.Errorf("failed to read file: %w", err)
}
```

### 2. グローバル変数の乱用

❌ **悪い例**:
```go
var db *sql.DB  // グローバル変数

func init() {
    db, _ = sql.Open("mysql", "...")
}
```

✅ **良い例**:
```go
type App struct {
    db *sql.DB
}

func NewApp(dsn string) (*App, error) {
    db, err := sql.Open("mysql", dsn)
    if err != nil {
        return nil, err
    }
    return &App{db: db}, nil
}
```

### 3. ポインタと値の混乱

Go では値型とポインタの違いを理解する必要があります：

```go
// 構造体が大きい場合や変更を反映したい場合はポインタ
func (h *Handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
    // ...
}

// 小さい構造体や不変の場合は値
func (p Point) Distance(q Point) float64 {
    // ...
}
```

---

## 参考資料

- [Effective Go](https://go.dev/doc/effective_go)
- [Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments)
- [golang-standards/project-layout](https://github.com/golang-standards/project-layout)
- [golangci-lint](https://golangci-lint.run/)

---
name: go-setup
description: |
  Set up a Go project environment. Invoke automatically when starting a new Go project
  or when the environment is not yet configured.
  Triggers: "setup Go project", "initialize Go", "create Go module",
  missing go.mod, first task in a Go project.
  Sets up: go mod init, directory structure (cmd/, internal/, pkg/), golangci-lint.
disable-model-invocation: false
user-invocable: true
allowed-tools: [editor, bash]
---

# Go セットアップ Skill

Commander が Go プロジェクトの初期セットアップタスクを生成するために使用します。

## 使用方法

```bash
/go-setup "github.com/username/projectname" "1.21"
/go-setup "$MODULE_PATH" "$GO_VERSION"
```

## 引数

- `$0` = モジュールパス（例: "github.com/username/projectname"）
- `$1` = Go バージョン（例: "1.21", "1.22"、デフォルト: "1.21"）

## 生成されるタスク仕様

このスキルは `tasks/task-setup-go/spec.md` を生成します。

### タスク内容

1. **Go Modules の初期化**
   ```bash
   go mod init {{module_path}}
   ```

2. **ディレクトリ構造の作成**
   ```
   cmd/
   └── {{app_name}}/
       └── main.go
   internal/
   ├── handler/
   ├── service/
   └── repository/
   pkg/
   └── util/
   ```

3. **.golangci.yml の作成**
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

4. **Makefile の作成**
   ```makefile
   .PHONY: build test lint fmt clean

   APP_NAME := {{app_name}}

   build:
   	go build -o bin/$(APP_NAME) ./cmd/$(APP_NAME)

   test:
   	go test -v -cover ./...

   lint:
   	golangci-lint run

   fmt:
   	gofmt -w .
   	goimports -w .

   vet:
   	go vet ./...

   clean:
   	rm -rf bin/
   ```

5. **.gitignore の作成**（Go 用）
   ```
   # Binaries
   bin/
   *.exe
   *.exe~
   *.dll
   *.so
   *.dylib

   # Test binary
   *.test

   # Output of the go coverage tool
   *.out

   # Go workspace file
   go.work

   # IDE
   .idea/
   .vscode/
   ```

6. **main.go の作成**
   ```go
   package main

   import "fmt"

   func main() {
       fmt.Println("Hello, {{app_name}}!")
   }
   ```

## 出力

### spec.md の構造

```yaml
---
task_id: task-setup-go
worker_type: coding
depends_on: []
parallel_ok: false
input_artifacts: []
output_artifacts:
  - go.mod
  - cmd/{{app_name}}/main.go
  - internal/handler/.gitkeep
  - internal/service/.gitkeep
  - internal/repository/.gitkeep
  - pkg/util/.gitkeep
  - .golangci.yml
  - Makefile
  - .gitignore
permissions:
  filesystem:
    write: [., cmd/, internal/, pkg/]
  execution:
    allowed: [go]
required_packages: []
environment_verified: true
commander_reasoning: |
  Go プロジェクトの初期セットアップタスク。
  Go Modules, ディレクトリ構造, Makefile, リンター設定を含む。
---

## 指示内容

Go プロジェクトの初期セットアップを行う（モジュールパス: {{module_path}}, Go バージョン: {{go_version}}）。

1. Go Modules を初期化する（`go mod init {{module_path}}`）
2. 標準的なディレクトリ構造を作成する
   - `cmd/{{app_name}}/` - メインアプリケーション
   - `internal/` - プライベートコード（handler, service, repository）
   - `pkg/` - 公開ライブラリ
3. `.golangci.yml` を作成する（リンター設定）
4. `Makefile` を作成する（ビルド・テスト・リントタスク）
5. `.gitignore` を作成する（Go 用）
6. `cmd/{{app_name}}/main.go` を作成する（基本的な Hello World）

## 期待する成果物

- `go.mod` が存在し、モジュールパスが正しく設定されている
- ディレクトリ構造が作成されている（`cmd/`, `internal/`, `pkg/`）
- `.golangci.yml` が存在し、推奨リンターが有効化されている
- `Makefile` が存在し、`build`, `test`, `lint`, `fmt` ターゲットが定義されている
- `.gitignore` が存在し、`bin/`, `*.out` が含まれている
- `cmd/{{app_name}}/main.go` が存在し、ビルド可能である

## 成功基準

- [ ] `go mod verify` が成功する
- [ ] `go build ./cmd/{{app_name}}` でビルドが成功する
- [ ] `make build` が成功する
- [ ] `make fmt` が実行できる
- [ ] `make vet` でエラーがない
- [ ] ディレクトリ構造が標準レイアウトに準拠している

## 注意事項

- Go バージョンは `go.mod` の `go` ディレクティブに記載される
- `internal/` パッケージは外部から import できない（Go の仕様）
- `golangci-lint` のインストールが必要（`go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest`）
- `goimports` のインストールが推奨（`go install golang.org/x/tools/cmd/goimports@latest`）
```

## 関連ファイル

- `.multi-agent/config/languages/go.md` - Go プロジェクトガイドライン
- `.multi-agent/templates/task/spec.md` - タスク仕様テンプレート

## 使用例

### 標準的なプロジェクト

```bash
/go-setup "github.com/myorg/myapp" "1.21"
```

### ライブラリプロジェクト

```bash
/go-setup "github.com/myorg/mylib" "1.22"
```

## 次のステップ

セットアップタスク完了後、以下のタスクを続けて作成することを推奨：

1. **依存関係のインストールタスク**（必要なパッケージがある場合）
   ```bash
   go get github.com/some/package
   go mod tidy
   ```

2. **品質チェック設定の検証タスク**
   ```bash
   make fmt
   make vet
   make lint
   make build
   ```

## 参考

- [Standard Go Project Layout](https://github.com/golang-standards/project-layout)
- [Effective Go](https://go.dev/doc/effective_go)

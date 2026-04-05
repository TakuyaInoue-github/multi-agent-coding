# Codex Plugin セットアップガイド

このガイドでは、Worker エージェントで Codex を使用するための `codex-plugin-cc` のセットアップ方法を説明します。

---

## 概要

Worker エージェントは Claude Code で起動しますが、実際のコーディングタスクは `/codex:rescue` コマンドを使って **Codex に委譲**します。

これにより以下の利点があります：
- **コスト削減**: Codex は Claude よりも安価
- **モデル多様性**: Claude（思考）+ Codex（実装）の組み合わせ
- **高速実装**: Codex の code generation 性能を活用

---

## 前提条件

### 1. 必要なソフトウェア

- **Node.js 18.18 以上**
  ```bash
  node --version  # 18.18+ を確認
  ```

- **Claude Code**: 既にインストール済み

### 2. OpenAI 認証

以下のいずれかが必要です：
- ChatGPT Plus サブスクリプション、または
- OpenAI API キー

---

## インストール手順

### Step 1: Claude Code で codex-plugin-cc をインストール

Worker セッション（または任意の Claude Code セッション）で以下を実行：

```bash
# 1. マーケットプレイスを追加
/plugin marketplace add openai/codex-plugin-cc

# 2. プラグインをインストール
/plugin install codex@openai-codex

# 3. プラグインをリロード
/reload-plugins

# 4. セットアップを実行
/codex:setup
```

### Step 2: 認証設定

`/codex:setup` を実行すると、認証方法を選択できます：

**オプション A: ChatGPT Plus サブスクリプション**
- ブラウザで認証プロセスが開始されます
- ChatGPT アカウントでログイン

**オプション B: OpenAI API キー**
- API キーを環境変数に設定：
  ```bash
  export OPENAI_API_KEY="sk-..."
  ```
- または `.codex/config.toml` に記載（後述）

### Step 3: プロジェクト設定ファイルの作成

プロジェクトルートに `.codex/config.toml` を作成：

```toml
# Worker が使用する Codex モデル
model = "gpt-4o"  # または gpt-4o-mini, o1-mini, o3-mini など

# 推論努力レベル（o1/o3 系モデルのみ）
# model_reasoning_effort = "medium"  # low, medium, high

# バックグラウンド実行をデフォルトに
default_background = true

# タイムアウト設定（秒）
timeout = 600  # 10分

# ログレベル
log_level = "info"  # debug, info, warn, error
```

**推奨モデル**:
- コスト重視: `gpt-4o-mini`
- バランス: `gpt-4o`
- 性能重視: `o1` または `o3-mini`

### Step 4: 動作確認

Worker セッションで簡単なタスクをテスト：

```bash
/codex:rescue "Create a simple hello.js file that prints 'Hello, World!'"
```

成功すれば、`hello.js` が作成されます。

---

## 使用方法

### 基本コマンド

#### `/codex:rescue` - タスクを Codex に委譲

```bash
# 基本形
/codex:rescue "タスクの説明"

# バックグラウンド実行
/codex:rescue --background "長時間タスク"

# 完了まで待機
/codex:rescue --wait "すぐに結果が必要なタスク"

# モデル指定
/codex:rescue --model gpt-4o-mini "簡単なタスク"

# 前回のタスクを継続
/codex:rescue --resume "前回の続きを実行"
```

#### `/codex:status` - 進捗確認

```bash
/codex:status
```

バックグラウンドで実行中のタスクの状態を確認します。

#### `/codex:cancel` - タスクをキャンセル

```bash
/codex:cancel
```

実行中のタスクを停止します。

### Worker での使用フロー

Worker エージェントは以下の手順でタスクを実行します：

1. **spec.md を読む**
   ```
   tasks/task-xxx/spec.md の内容を確認
   ```

2. **Codex にタスクを委譲**
   ```bash
   /codex:rescue --background "
   以下の仕様に従って実装してください：

   [spec.md の内容を貼り付け]

   期待する成果物：
   - [output_artifacts のリスト]

   注意事項：
   - [permissions の制約]
   - [required_packages の確認]
   "
   ```

3. **進捗を確認**
   ```bash
   /codex:status
   ```

4. **完了後、result.md を作成**
   - Codex が生成したファイルを確認
   - 成功基準をチェック
   - result.md に報告を記載

---

## トラブルシューティング

### プラグインが見つからない

```bash
# プラグインリストを確認
/plugin list

# 再インストール
/plugin uninstall codex@openai-codex
/plugin install codex@openai-codex
/reload-plugins
```

### 認証エラー

```bash
# 認証状態を確認
/codex:setup

# API キーを再設定
export OPENAI_API_KEY="sk-..."
```

### タスクがタイムアウト

`.codex/config.toml` でタイムアウトを延長：

```toml
timeout = 1200  # 20分
```

### モデルが見つからない

利用可能なモデルを確認：
```bash
/codex:rescue --help
```

最新のモデル名を `.codex/config.toml` に設定。

---

## ベストプラクティス

### 1. モデル選択

| タスク種別 | 推奨モデル | 理由 |
|-----------|-----------|------|
| 簡単な実装 | `gpt-4o-mini` | コスト効率が良い |
| 標準的な実装 | `gpt-4o` | バランスが良い |
| 複雑なロジック | `o1-mini` | 推論能力が高い |
| 高度なアルゴリズム | `o3-mini` | 最高性能 |

### 2. タスクの粒度

- **1タスク = 1つの明確な成果物**
- 大きなタスクは Commander が分解済み
- Worker は spec.md の指示をそのまま Codex に渡す

### 3. バックグラウンド実行

長時間タスクは必ず `--background` を使用：
```bash
/codex:rescue --background "大規模な実装タスク"
```

### 4. エラーハンドリング

Codex がエラーを出した場合：
1. `/codex:status` でエラー内容を確認
2. `result.md` に `status: failed` と記載
3. `blocked_reason` にエラー詳細を記録
4. Commander にエスカレーション

---

## セキュリティ注意事項

### API キーの管理

- `.codex/config.toml` に API キーを直接書かない
- 環境変数を使用：
  ```bash
  export OPENAI_API_KEY="sk-..."
  ```
- `.gitignore` に `.codex/` を追加（既に設定済み）

### Permissions の遵守

Worker は spec.md の `permissions` を厳守する必要があります：
- Codex に渡す指示に制約を明記
- 実行後、permissions 違反がないか確認

---

## 参考リンク

- [codex-plugin-cc GitHub](https://github.com/openai/codex-plugin-cc)
- [OpenAI API Documentation](https://platform.openai.com/docs)
- [Claude Code Documentation](https://claude.com/claude-code)

---

## 次のステップ

1. ✅ codex-plugin-cc をインストール
2. ✅ `.codex/config.toml` を設定
3. ✅ Worker セッションでテスト実行
4. → Worker CLAUDE.md を確認して実際のタスクを実行

Worker CLAUDE.md の詳細は `agents/worker/CLAUDE.md` を参照してください。

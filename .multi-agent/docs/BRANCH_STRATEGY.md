# ブランチ管理戦略

このドキュメントでは、multi-agent プロジェクトにおけるブランチ管理戦略を定義します。

## 戦略概要

**GitHub Flow** ベースのシンプルなブランチ戦略を採用します。

```
main (protected)
 ├── feature/task-decomposition-refactor
 ├── fix/observer-gate1-bug
 ├── docs/setup-guide-update
 └── test/codex-integration
```

### 主要な原則

1. **main ブランチは常にデプロイ可能な状態**
   - すべてのテストが通る
   - ドキュメントが最新
   - 動作確認済み

2. **機能開発・修正は専用ブランチで**
   - main から分岐
   - 作業完了後に main へマージ
   - マージ後は速やかに削除

3. **小さく頻繁にマージ**
   - 大きな機能は複数のブランチに分割
   - 1ブランチ = 1つの明確な目的

## ブランチ命名規則

### パターン

```
<type>/<description>
```

### Type 一覧

| Type | 用途 | 例 |
|------|------|-----|
| `feature/` | 新機能追加 | `feature/worker-parallel-execution` |
| `fix/` | バグ修正 | `fix/board-sync-race-condition` |
| `docs/` | ドキュメント更新 | `docs/architecture-diagram` |
| `refactor/` | リファクタリング | `refactor/skill-parameter-validation` |
| `test/` | テスト追加・修正 | `test/observer-gate2-scenarios` |
| `chore/` | ビルド・設定変更 | `chore/update-gitignore` |
| `perf/` | パフォーマンス改善 | `perf/eventlog-indexing` |

### 命名ガイドライン

- **小文字とハイフン**: `feature/codex-integration` ✓
- **簡潔で明確**: `fix/typo` より `fix/readme-typo` が良い
- **30文字以内を推奨**: 長すぎる場合は機能を分割検討

**悪い例**:
```
feature/add-new-feature-for-worker-that-supports-parallel-execution
fix/bug
update
```

**良い例**:
```
feature/worker-parallel-tasks
fix/observer-null-check
docs/codex-setup
```

## コミットメッセージ規約

**Conventional Commits** 形式を使用します。

### フォーマット

```
<type>: <subject>

<body>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Type 一覧

- `feat`: 新機能
- `fix`: バグ修正
- `docs`: ドキュメント変更
- `style`: コードフォーマット（機能変更なし）
- `refactor`: リファクタリング
- `test`: テスト追加・修正
- `chore`: ビルド・ツール・依存関係更新
- `perf`: パフォーマンス改善

### 例

```
feat: Worker に Codex 統合機能を追加

/codex:rescue コマンドでタスクを委譲可能に。
- .codex/config.toml でモデル選択
- バックグラウンド実行をデフォルト化
- タイムアウトを BOARD.md の設定と同期

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

## ワークフロー

### 1. 新しいブランチを作成

```bash
# main を最新に
git checkout main
git pull origin main

# 新しいブランチを作成
git checkout -b feature/observer-timeout-handling
```

### 2. 開発・コミット

```bash
# 変更を加える
# ...

# コミット
git add .
git commit -m "feat: Observer にタイムアウト処理を追加"
```

### 3. リモートにプッシュ

```bash
git push -u origin feature/observer-timeout-handling
```

### 4. Pull Request（推奨）

GitHub で Pull Request を作成:
- タイトル: ブランチ名をベースに
- 説明: 何を変更したか、なぜ変更したか
- レビュー: セルフレビューまたは他者レビュー

### 5. main へマージ

```bash
# PR マージ後、またはローカルマージ
git checkout main
git pull origin main

# ローカルマージの場合
git merge feature/observer-timeout-handling

# マージ済みブランチを削除
git branch -d feature/observer-timeout-handling
git push origin --delete feature/observer-timeout-handling
```

## マルチエージェント開発での考慮事項

このプロジェクトでは、Commander/Observer/Worker が並行して作業する可能性があります。

### ブランチ分離戦略

**シナリオ**: Commander が新タスクを分解し、Worker が実装する

```
main
 ├── task/implement-logger (Worker)
 │    └── tasks/task-003/  (実装成果物)
 └── feature/logger-spec (Commander)
      └── tasks/task-003/spec.md
```

**推奨アプローチ**:
1. Commander: `feature/task-003-logger-spec` で spec.md を作成
2. Commander: spec.md のみを main にマージ
3. Worker: main から `task/implement-task-003` を分岐
4. Worker: 実装完了後、result.md とともに main にマージ

### 競合回避

- **runtime/ ファイル**: 頻繁に変更されるため、こまめに pull
- **tasks/ ディレクトリ**: タスクIDで分離されるため、通常競合しない
- **システムファイル**: `.multi-agent/roles/`, `.claude/skills/` は慎重に変更

### Git Worktree の活用

マルチセッションで異なるブランチを同時に操作する場合:

```bash
# Commander セッション（main ブランチ）
cd /path/to/multi-agent

# Worker セッション（task ブランチを worktree で）
git worktree add ../multi-agent-worker task/implement-task-003
cd ../multi-agent-worker

# 作業完了後
cd /path/to/multi-agent
git worktree remove ../multi-agent-worker
```

## ブランチ保護ルール（推奨）

GitHub リポジトリ設定で main ブランチを保護:

```
Settings → Branches → Branch protection rules

[main]
☑ Require pull request reviews before merging
  ☐ Require approvals: 1 (チーム開発時のみ)
☑ Require status checks to pass before merging
  ☐ (テストCIがあれば追加)
☑ Require branches to be up to date before merging
☐ Require signed commits (オプション)
☑ Include administrators
```

個人開発の場合、最低限:
- Pull Request を作成する習慣
- セルフレビューを実施
- 動作確認してからマージ

## クイックリファレンス

### よく使うコマンド

```bash
# ブランチ一覧
git branch -a

# 現在のブランチ
git branch --show-current

# ブランチ切り替え
git checkout <branch-name>

# 新規ブランチ作成＆切り替え
git checkout -b feature/new-feature

# リモートの変更を取得
git fetch origin

# main を最新に更新
git checkout main && git pull origin main

# マージ済みブランチを削除
git branch --merged main | grep -v "^\* main" | xargs -n 1 git branch -d

# リモートのマージ済みブランチを削除
git push origin --delete <branch-name>
```

### トラブルシューティング

#### ブランチ名を間違えた

```bash
# ローカルブランチ名を変更
git branch -m old-name new-name

# リモートブランチ名を変更
git push origin :old-name new-name
git push origin -u new-name
```

#### main への誤コミット

```bash
# 最新コミットを新ブランチに移動
git branch feature/accidental-commit
git reset --hard HEAD~1
git checkout feature/accidental-commit
```

#### コンフリクト解決

```bash
# main から最新を取得
git checkout feature/my-branch
git fetch origin
git merge origin/main

# コンフリクトを手動解決後
git add <resolved-files>
git commit -m "chore: コンフリクト解決"
```

## 関連ドキュメント

- [マルチセッションワークフロー](MULTI_SESSION_WORKFLOW.md)
- [Codex セットアップ](CODEX_SETUP.md)
- [使い方ガイド](../docs/GUIDE.md)

## 改訂履歴

| 日付 | 変更内容 |
|------|---------|
| 2026-04-05 | 初版作成: GitHub Flow ベースのブランチ戦略を定義 |

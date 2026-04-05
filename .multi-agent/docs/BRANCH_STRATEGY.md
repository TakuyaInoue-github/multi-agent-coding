# ブランチ管理戦略

このドキュメントでは、multi-agent プロジェクトにおけるブランチ管理戦略を定義します。

## 戦略概要

**Git Flow** を採用します。main と develop の2本柱でリリースと開発を分離します。

```
main (protected)           # 本番リリース済みコード
 └── develop (protected)   # 次期リリース候補
      ├── feature/task-decomposition-refactor
      ├── fix/observer-gate1-bug
      ├── docs/setup-guide-update
      └── test/codex-integration
```

### 主要な原則

1. **main ブランチは本番リリース済みコード**
   - 常に安定版
   - すべてのテストが通る
   - タグでバージョン管理 (v1.0.0, v1.1.0...)
   - **直接コミット禁止**

2. **develop ブランチは次期リリース候補**
   - 開発中の最新コード
   - すべての機能ブランチはここから分岐
   - 機能完成後はここへマージ
   - **直接コミット禁止**（緊急時のみ許可）

3. **機能開発・修正は専用ブランチで**
   - develop から分岐
   - 作業完了後に develop へ PR
   - レビュー・テスト後に develop へマージ
   - マージ後は速やかに削除

4. **リリース時は develop → main**
   - develop が安定したら main へマージ
   - main でバージョンタグを作成
   - hotfix 以外は main への直接マージ禁止

5. **小さく頻繁にマージ**
   - 大きな機能は複数のブランチに分割
   - 1ブランチ = 1つの明確な目的

## ブランチ命名規則

### パターン

```
<type>/<description>
```

### Type 一覧

| Type | 用途 | 分岐元 | マージ先 | 例 |
|------|------|--------|----------|-----|
| `feature/` | 新機能追加 | develop | develop | `feature/worker-parallel-execution` |
| `fix/` | バグ修正 | develop | develop | `fix/board-sync-race-condition` |
| `docs/` | ドキュメント更新 | develop | develop | `docs/architecture-diagram` |
| `refactor/` | リファクタリング | develop | develop | `refactor/skill-parameter-validation` |
| `test/` | テスト追加・修正 | develop | develop | `test/observer-gate2-scenarios` |
| `chore/` | ビルド・設定変更 | develop | develop | `chore/update-gitignore` |
| `perf/` | パフォーマンス改善 | develop | develop | `perf/eventlog-indexing` |
| `hotfix/` | 本番緊急修正 | **main** | **main & develop** | `hotfix/critical-observer-crash` |
| `release/` | リリース準備 | develop | **main & develop** | `release/v1.2.0` |

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

### 日常の開発フロー（機能追加・バグ修正）

#### 1. develop から新しいブランチを作成

```bash
# develop を最新に
git checkout develop
git pull origin develop

# 新しいブランチを作成
git checkout -b feature/observer-timeout-handling
```

#### 2. 開発・コミット

```bash
# 変更を加える
# ...

# コミット
git add .
git commit -m "feat: Observer にタイムアウト処理を追加"
```

#### 3. リモートにプッシュ

```bash
git push -u origin feature/observer-timeout-handling
```

#### 4. Pull Request 作成

GitHub で Pull Request を作成:
- **Base**: `develop` ← **Compare**: `feature/observer-timeout-handling`
- タイトル: ブランチ名をベースに
- 説明: 何を変更したか、なぜ変更したか
- テンプレートに従ってチェックリスト記入

#### 5. develop へマージ

```bash
# PR で "Merge pull request" をクリック
# または、ローカルマージの場合:
git checkout develop
git merge feature/observer-timeout-handling
git push origin develop

# マージ済みブランチを削除
git branch -d feature/observer-timeout-handling
git push origin --delete feature/observer-timeout-handling
```

### リリースフロー（develop → main）

#### 1. リリースブランチを作成（オプション）

```bash
# リリース準備用のブランチ
git checkout develop
git checkout -b release/v1.2.0

# バージョン番号の更新、最終確認など
# ...

git commit -m "chore: バージョンを v1.2.0 に更新"
git push -u origin release/v1.2.0
```

#### 2. main へマージ

```bash
# リリースブランチを main へマージ
git checkout main
git merge release/v1.2.0

# タグを作成
git tag -a v1.2.0 -m "Release version 1.2.0"
git push origin main --tags
```

#### 3. develop へもマージ（変更を同期）

```bash
git checkout develop
git merge release/v1.2.0
git push origin develop

# リリースブランチを削除
git branch -d release/v1.2.0
git push origin --delete release/v1.2.0
```

**シンプルな方法**（リリースブランチなし）:
```bash
# develop を直接 main へマージ
git checkout main
git merge develop
git tag -a v1.2.0 -m "Release version 1.2.0"
git push origin main --tags
```

### Hotfix フロー（本番緊急修正）

#### 1. main から hotfix ブランチを作成

```bash
git checkout main
git pull origin main
git checkout -b hotfix/critical-observer-crash
```

#### 2. 修正・テスト

```bash
# バグ修正
# ...

git add .
git commit -m "fix: Observer のクラッシュを緊急修正"
git push -u origin hotfix/critical-observer-crash
```

#### 3. main と develop の両方へマージ

```bash
# main へマージ
git checkout main
git merge hotfix/critical-observer-crash
git tag -a v1.2.1 -m "Hotfix: Observer crash"
git push origin main --tags

# develop へもマージ（修正を反映）
git checkout develop
git merge hotfix/critical-observer-crash
git push origin develop

# hotfix ブランチを削除
git branch -d hotfix/critical-observer-crash
git push origin --delete hotfix/critical-observer-crash
```

## マルチエージェント開発での考慮事項

このプロジェクトでは、Commander/Observer/Worker が並行して作業する可能性があります。

### ブランチ分離戦略

**シナリオ**: Commander が新タスクを分解し、Worker が実装する

```
main
 └── develop
      ├── task/implement-logger (Worker)
      │    └── tasks/task-003/  (実装成果物)
      └── feature/logger-spec (Commander)
           └── tasks/task-003/spec.md
```

**推奨アプローチ**:
1. Commander: develop から `feature/task-003-logger-spec` を分岐、spec.md を作成
2. Commander: spec.md のみを develop にマージ
3. Worker: develop から `task/implement-task-003` を分岐
4. Worker: 実装完了後、result.md とともに develop にマージ
5. リリース時: develop → main へマージ、タグ付け

### 競合回避

- **runtime/ ファイル**: 頻繁に変更されるため、こまめに pull
- **tasks/ ディレクトリ**: タスクIDで分離されるため、通常競合しない
- **システムファイル**: `.multi-agent/roles/`, `.claude/skills/` は慎重に変更

### Git Worktree の活用

マルチセッションで異なるブランチを同時に操作する場合:

```bash
# Commander セッション（develop ブランチ）
cd /path/to/multi-agent
git checkout develop

# Worker セッション（task ブランチを worktree で）
git worktree add ../multi-agent-worker task/implement-task-003
cd ../multi-agent-worker

# 作業完了後
cd /path/to/multi-agent
git worktree remove ../multi-agent-worker
```

## ブランチ保護ルール

Git Flow では main と develop の両方を保護します。

> **注**: プライベートリポジトリでは GitHub Team プラン（有料）が必要です。Free プランではパブリックリポジトリのみブランチ保護が機能します。詳細は [SETUP_BRANCH_PROTECTION.md](SETUP_BRANCH_PROTECTION.md) を参照してください。

### GitHub での設定手順

1. リポジトリの **Settings** → **Branches** に移動
2. **Add branch protection rule** をクリック

### main ブランチの保護設定

```
Branch name pattern: main

☑ Require a pull request before merging
  ☑ Require approvals: 1 (推奨: セルフレビューでも承認必須)
  ☑ Dismiss stale pull request approvals when new commits are pushed
☑ Require status checks to pass before merging
  ☐ (テストCIがあれば追加: test, build など)
☑ Require conversation resolution before merging
☑ Require linear history (推奨: マージコミットを防ぐ)
☐ Require signed commits (セキュリティ重視なら有効化)
☑ Include administrators (自分も含める)
☐ Allow force pushes (無効のまま)
☐ Allow deletions (無効のまま)
```

### develop ブランチの保護設定

```
Branch name pattern: develop

☑ Require a pull request before merging
  ☐ Require approvals: 0 (または 1、個人開発では柔軟に)
☑ Require status checks to pass before merging
☑ Require conversation resolution before merging
☐ Require linear history (マージコミット許可でもOK)
☑ Include administrators
☐ Allow force pushes (無効のまま)
☐ Allow deletions (無効のまま)
```

### 設定のポイント

**main ブランチ**:
- **最も厳格**: リリース済みコードを保護
- PR 必須 + 承認必須
- 直接 push 不可
- force push 不可

**develop ブランチ**:
- **やや緩め**: 開発中のコード、頻繁にマージ
- PR 必須（承認は任意）
- 緊急時の直接コミット許可（非推奨だが可能）

**個人開発の場合**:
- main: 厳格に保護（PR + セルフレビュー必須）
- develop: PR 必須だが承認は任意
- 習慣化により品質を維持

### プライベートリポジトリでの運用（技術的強制力なし）

ブランチ保護が機能しない場合、以下の運用ルールで対応：

**基本ルール**:
1. **main/develop への直接コミット禁止**（自己規律）
2. **必ず feature ブランチを作成**
3. **PR を作成してセルフレビュー**
4. **GitHub でマージ**（Squash and merge 推奨）

**補助ツール（任意）**:
```bash
# pre-push hook で警告表示
cat > .git/hooks/pre-push << 'EOF'
#!/bin/bash
branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$branch" = "main" ] || [ "$branch" = "develop" ]; then
    echo "⚠️  WARNING: Pushing to $branch directly!"
    echo "Consider using a feature branch and PR instead."
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi
EOF
chmod +x .git/hooks/pre-push
```

**推奨フロー**:
```bash
# 常にこのフローを守る
git checkout develop
git checkout -b feature/my-feature
# ... 開発 ...
git push -u origin feature/my-feature
# GitHub で PR 作成 → セルフレビュー → Merge
```

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

# develop を最新に更新
git checkout develop && git pull origin develop

# main を最新に更新
git checkout main && git pull origin main

# develop にマージ済みのブランチを削除
git branch --merged develop | grep -v "^\* develop" | grep -v "main" | xargs -n 1 git branch -d

# リモートのマージ済みブランチを削除
git push origin --delete <branch-name>

# タグを作成（リリース時）
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# タグ一覧
git tag -l
```

### Git Flow 専用コマンド

```bash
# 機能開発開始
git checkout develop
git checkout -b feature/my-feature

# 機能完成、develop へマージ
git checkout develop
git merge feature/my-feature
git push origin develop
git branch -d feature/my-feature

# リリース開始
git checkout develop
git checkout -b release/v1.2.0
# バージョン更新など
git commit -m "chore: bump version to 1.2.0"

# リリース完了（main と develop へマージ）
git checkout main
git merge release/v1.2.0
git tag -a v1.2.0 -m "Release 1.2.0"
git push origin main --tags

git checkout develop
git merge release/v1.2.0
git push origin develop
git branch -d release/v1.2.0

# Hotfix 開始（main から）
git checkout main
git checkout -b hotfix/critical-bug

# Hotfix 完了（main と develop へマージ）
git checkout main
git merge hotfix/critical-bug
git tag -a v1.2.1 -m "Hotfix 1.2.1"
git push origin main --tags

git checkout develop
git merge hotfix/critical-bug
git push origin develop
git branch -d hotfix/critical-bug
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

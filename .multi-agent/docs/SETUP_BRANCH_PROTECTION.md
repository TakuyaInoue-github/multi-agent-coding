# GitHub ブランチ保護設定手順

このドキュメントでは、GitHub リポジトリに Git Flow 用のブランチ保護を設定する手順を説明します。

## ⚠️ プライベートリポジトリでの制限

**重要**: GitHub の仕様により、**プライベートリポジトリでブランチ保護を使用するには GitHub Team プラン（有料）が必要**です。

- **Free プラン**: パブリックリポジトリのみブランチ保護が機能
- **Team プラン**: プライベートでも機能（$4/user/month）

**このリポジトリの現状**:
- プライベートリポジトリとして運用中
- ブランチ保護設定は完了しているが、**技術的に強制されない**
- 将来パブリック化した際に自動的に有効化される
- 現在は**運用ルールで対応**（自己規律でブランチを保護）

## 前提条件

- GitHub リポジトリへの管理者権限
- `main` と `develop` ブランチが既に存在している
- パブリックリポジトリ、または GitHub Team プラン加入済み

## 設定手順

### 1. GitHub リポジトリにアクセス

1. https://github.com/TakuyaInoue-github/multi-agent-coding に移動
2. **Settings** タブをクリック
3. 左サイドバーの **Branches** をクリック

### 2. main ブランチの保護ルールを追加

#### 2.1. ルールを作成

1. **Add branch protection rule** をクリック
2. **Branch name pattern** に `main` を入力

#### 2.2. 保護設定を有効化

以下の項目にチェックを入れます：

```
☑ Require a pull request before merging
  ☑ Require approvals: 1
    - 個人開発でもセルフレビューの習慣化のため推奨
  ☑ Dismiss stale pull request approvals when new commits are pushed
    - 新しいコミットが追加されたら再承認が必要
  ☐ Require review from Code Owners
    - CODEOWNERS ファイルがあれば有効化（現状は不要）

☑ Require status checks to pass before merging
  ☐ Require branches to be up to date before merging
    - CI/CD があれば有効化（現状は任意）

  注: テストCIがあれば以下を追加
  - test
  - build
  - lint

☑ Require conversation resolution before merging
  - PR のコメントがすべて解決済みでないとマージ不可

☑ Require linear history
  - マージコミットを作らず、rebase または squash merge を強制
  - 履歴がクリーンに保たれる

☐ Require deployments to succeed before merging
  - デプロイメント環境があれば設定（現状は不要）

☐ Lock branch
  - ブランチを読み取り専用にする（リリース後の main 保護に使用可能）

☐ Do not allow bypassing the above settings
  - 管理者でもルールをバイパスできない（厳格運用の場合）

☑ Include administrators
  - 自分自身も保護ルールの対象にする（推奨）

☐ Allow force pushes
  - **無効のまま**（force push 禁止）

☐ Allow deletions
  - **無効のまま**（ブランチ削除禁止）
```

#### 2.3. ルールを保存

- **Create** ボタンをクリック

### 3. develop ブランチの保護ルールを追加

#### 3.1. ルールを作成

1. 再度 **Add branch protection rule** をクリック
2. **Branch name pattern** に `develop` を入力

#### 3.2. 保護設定を有効化

main より少し緩めの設定：

```
☑ Require a pull request before merging
  ☐ Require approvals: 0
    - 個人開発では任意（1 にすると厳格）
  ☑ Dismiss stale pull request approvals when new commits are pushed
  ☐ Require review from Code Owners

☑ Require status checks to pass before merging
  ☐ Require branches to be up to date before merging

☑ Require conversation resolution before merging

☐ Require linear history
  - develop ではマージコミット許可でもOK

☐ Lock branch

☐ Do not allow bypassing the above settings

☑ Include administrators

☐ Allow force pushes
  - **無効のまま**

☐ Allow deletions
  - **無効のまま**
```

#### 3.3. ルールを保存

- **Create** ボタンをクリック

## 設定後の確認

### 保護ルールの確認

1. **Settings** → **Branches** で以下が表示されていることを確認：
   - `main` - 保護ルール適用中
   - `develop` - 保護ルール適用中

### テスト

#### 直接 push が禁止されていることを確認

```bash
# main ブランチに直接 push を試みる（失敗するはず）
git checkout main
echo "test" >> test.txt
git add test.txt
git commit -m "test: direct push to main"
git push origin main
```

**期待される結果**:
```
remote: error: GH006: Protected branch update failed for refs/heads/main.
remote: error: Changes must be made through a pull request.
To github.com:TakuyaInoue-github/multi-agent-coding.git
 ! [remote rejected] main -> main (protected branch hook declined)
error: failed to push some refs to 'github.com:TakuyaInoue-github/multi-agent-coding.git'
```

#### PR 経由でマージできることを確認

```bash
# develop から feature ブランチを作成
git checkout develop
git checkout -b test/branch-protection
echo "test" >> test.txt
git add test.txt
git commit -m "test: ブランチ保護のテスト"
git push -u origin test/branch-protection

# GitHub で PR 作成
# develop ← test/branch-protection
# マージできることを確認
```

## トラブルシューティング

### 「自分が push できない」

**原因**: `Include administrators` が有効で、自分も保護ルールの対象になっている

**対処法**:
- 正常な動作です。PR 経由でマージしてください
- どうしても直接 push したい場合、一時的に保護ルールを無効化（非推奨）

### 「PR をマージできない」

**原因**:
1. 承認が不足している → PR を承認する
2. ステータスチェックが失敗 → CI を修正
3. コンフリクトがある → コンフリクトを解決
4. コメントが未解決 → すべてのコメントを Resolve

**対処法**: エラーメッセージに従って対応

### 「緊急で hotfix を main に push したい」

**方法**:
1. Settings → Branches → main の保護ルールを編集
2. 一時的に `Require a pull request before merging` のチェックを外す
3. hotfix を push
4. **すぐに保護ルールを再度有効化**

**推奨**: 緊急時でも hotfix ブランチ → PR → マージのフローを守る

## 参考リンク

- [GitHub Docs: ブランチ保護ルール](https://docs.github.com/ja/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [Git Flow ブランチ戦略](.multi-agent/docs/BRANCH_STRATEGY.md)

## 改訂履歴

| 日付 | 変更内容 |
|------|---------|
| 2026-04-05 | 初版作成: Git Flow 用のブランチ保護設定手順 |

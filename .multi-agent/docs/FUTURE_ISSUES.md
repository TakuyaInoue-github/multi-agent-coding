# 将来の課題

このドキュメントは現在の設計で意図的に先送りした課題をまとめたものです。
実装の優先度・タイミングは別途判断してください。

---

## Issue 1: ロール別の物理的権限強制

### 現状

全エージェントがメインプロジェクトディレクトリで起動しているため、
Claude Code の permissions はロール（セッション）を識別できない。
ロール別の書き込み制限は CLAUDE.md の自律制御と audit ログに委ねている。

### 問題

- Commander が誤って `result.md` を上書きできてしまう
- Worker が誤って `runtime/BOARD.md` を書き換えられてしまう
- 物理的な強制力がないため、エージェントの判断ミスが防げない

### 解決の方向性

permissions はセッションを識別できないため、以下のいずれかが必要：

1. **worktree 別起動の再検討**
   - 各エージェントをロール専用 worktree で起動
   - `runtime/` / `tasks/` の共有問題をパス設計で解決する
   - Claude Code の symlink パス解決の挙動が変わった場合に有効になる

2. **Claude Code の将来機能を活用**
   - セッション ID やロール識別が permissions に組み込まれれば直接解決できる

3. **hooks でロール識別**
   - `validate-bash.sh` / `protect-files.sh` に worktree ブランチ名や
     環境変数でロールを識別する仕組みを追加する

### 参照

- `.multi-agent/roles/*/settings.json` — ロール別権限の定義（適用待ち）
- `.multi-agent/docs/HARNESS.md` — 現状の設計思想と判断経緯

---

## Issue 2: エージェント起動の自動化（git worktree add）

### 現状

`launch-agents-worktree.sh` の worktree 作成（`git worktree add`）はグローバル
settings の allow に `Bash(git worktree *)` がないためエージェントから実行できない。
ユーザーが手動でスクリプトを実行する必要がある。

### 問題

- エージェントが自律的に worktree を作成・管理できない
- Codex がタスクブランチ用の worktree を自動作成する場面で詰まる

### 解決の方向性

1. **グローバル settings に追加**
   ```json
   "Bash(git worktree *)"
   ```
   ただし `git worktree add` は任意ディレクトリへの書き込みを伴うため、
   対象パスを限定するパターンの検討が必要。

2. **スクリプト経由に限定**
   ```json
   "Bash(bash .multi-agent/scripts/*)"
   ```
   worktree 操作をスクリプトにまとめ、スクリプト実行のみ allow する。

---

## Issue 3: runtime/ のロール別アクセス制御

### 現状

`runtime/BOARD.md` / `runtime/EVENTLOG.json` 等は全エージェントが Read/Write できる。
ロール別の書き込み制限は CLAUDE.md のルールのみで担保している。

### 問題

- Worker が `runtime/BOARD.md` のステータスを直接 `completed` に書き換えると
  Gate2 評価をスキップしてマージされる
- EVENTLOG の改ざんにより監査証跡が失われる

### 解決の方向性

Issue 1 の解決（ロール別物理権限）と連動する。
短期的には `log-activity.sh` の audit ログを定期的にレビューする運用で補完する。

---

## Issue 4: settings.local.json の競合管理

### 現状

複数エージェントが同じ `$PROJECT_DIR` で起動しているため、
`settings.local.json` は共有される。個人・端末固有の設定しか置けない。

### 問題

- ロール別の実験的 allow を `settings.local.json` で試したい場合、
  全エージェントに影響が出る

### 解決の方向性

Issue 1・2 の解決（worktree 別起動）と連動する。
worktree 別起動が実現すれば各 worktree に独立した `settings.local.json` を持てる。

---

## 優先度マトリクス

| Issue | 影響度 | 実装コスト | 優先度 |
|---|---|---|---|
| Issue 1: ロール別物理権限 | 高 | 高（設計変更） | 中 |
| Issue 2: worktree 自動化 | 中 | 低（allow 追加） | 高 |
| Issue 3: runtime アクセス制御 | 高 | 高（Issue 1 依存） | 中 |
| Issue 4: settings.local.json 競合 | 低 | 高（Issue 1 依存） | 低 |

---

## 関連ドキュメント

- `.multi-agent/docs/HARNESS.md` — 現状のハーネス設計と設計思想
- `.multi-agent/roles/*/settings.json` — ロール別権限定義（適用待ち）
- `.multi-agent/docs/MULTI_SESSION_WORKFLOW.md` — マルチセッション全体設計

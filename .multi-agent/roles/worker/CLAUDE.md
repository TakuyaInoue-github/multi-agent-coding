# Worker

あなたはこのプロジェクトの **Worker** です。
与えられた `spec.md` の指示に従い、タスクを実行してください。

実装は **Codex に委譲**します。あなた（Claude Code）は：
- spec.md を読んで理解する
- `/codex:rescue` で Codex にタスクを渡す
- Codex の実行結果を確認する
- result.md を作成して Commander に報告する

指示の範囲外のことは行わないでください。
判断に迷った場合は実行を止めて `result.md` に `blocked_reason` を記載してください。

---

## アクション一覧

各アクションの詳細手順はSkillを参照すること。

| 状況 | 使用するSkill / コマンド |
|-----|----------------------|
| タスクを開始する（事前確認・ブランチ作成・Codex委譲） | `/start-task task-xxx` |
| Codex の進捗を確認する | `/codex:status` |
| Codex に修正を依頼する | `/codex:rescue --resume "修正内容"` |
| Codex をキャンセルする | `/codex:cancel` |

---

## 前提条件: Codex Plugin のセットアップ（初回のみ）

```bash
/plugin marketplace add openai/codex-plugin-cc
/plugin install codex@openai-codex
/reload-plugins
/codex:setup
```

詳細は `.multi-agent/docs/CODEX_SETUP.md` を参照してください。

---

## 権限ルール

| 操作 | 可否 |
|-----|------|
| task/task-xxx ブランチの作成・コミット・プッシュ | ✅ |
| spec.md の `permissions` 範囲内のファイル書き込み | ✅ |
| パッケージインストール | ❌（Commander が事前に準備） |
| develop / main への操作 | ❌ |
| runtime/ ・ tasks/spec.md への書き込み | ❌ |

---

## /loop モード時のチェック順序

1. 担当中タスクの完了確認（`/codex:status` → result.md 作成 → `.assigned` 削除）
2. 担当タスクがない場合、`status: approved` かつ `.assigned` なしのタスクを1件取得
   - `.assigned` を作成し、自分の worker-id が書き込まれているか読み返して確認してから実装開始
3. 取得できるタスクがなければ何もしない

1サイクル1タスクを原則とする。Codex バックグラウンド実行中は完了確認のみ行う。

---

## 参照ドキュメント

- `.multi-agent/docs/CODEX_SETUP.md` — Codex セットアップ詳細
- `.multi-agent/templates/task/result.md` — result.md テンプレート
- `.multi-agent/docs/MULTI_SESSION_WORKFLOW.md` — マルチセッション全体設計
- `.multi-agent/docs/HARNESS.md` — permissions・hooks・ログ監視の設計と使い方

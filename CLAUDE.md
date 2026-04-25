# Multi-Agent Coding Support System

このプロジェクトは Commander / Observer / Worker の3エージェント構成で動作する。
セッション開始時は自分のロールの CLAUDE.md を読んでから作業を開始すること。

---

## ロール定義

- Commander: `.multi-agent/roles/commander/CLAUDE.md`
- Observer: `.multi-agent/roles/observer/CLAUDE.md`
- Worker: `.multi-agent/roles/worker/CLAUDE.md`

---

## ハーネス制約

このプロジェクトでは `.claude/settings.json` と hooks によって実行境界を設けている。
制約に引っかかった場合は、回避しようとせずユーザーに確認すること。

### 禁止コマンド（hooks でブロックされる）

| コマンド | 理由 |
|---|---|
| `rm -rf` | ローカル資産の破壊 |
| `git push --force` / `git reset --hard` / `git clean` | Git 履歴・作業ツリーの破壊 |
| `git checkout -- *` / `git checkout .` | 未コミット変更の破棄 |
| `curl` / `wget` / `ssh` / `scp` | 外部通信・秘密情報流出の経路 |
| `aws` / `gcloud` / `az` / `kubectl` | 本番・クラウドリソースの変更 |
| `terraform apply` / `terraform destroy` | インフラ状態の変更 |
| `python *` / `python3 *` | 任意コード実行 |

### 保護ファイル（hooks でブロックされる）

| 対象 | 理由 |
|---|---|
| `.env` / `.env.*` | 認証情報の漏えい防止 |
| `secrets/**` | 同上 |
| `.git/` 配下 | Git 内部状態の保護 |
| `.claude/settings.json` | ハーネス設定の勝手な変更防止 |

`.claude/settings.json` の変更が必要な場合はユーザーが手動で行う。

### ask（毎回確認が必要）

`npm install` / `pip install` / `uv add` / `git push` / `git merge` は自動実行されない。
必要な場合はユーザーに確認を求めること。

---

## ドキュメント

- `.multi-agent/docs/HARNESS.md` — ハーネス設計の詳細（hooks・permissions・監視手順）
- `.multi-agent/docs/GUIDE.md` — セットアップ・ファイル構成
- `.multi-agent/docs/MULTI_SESSION_WORKFLOW.md` — マルチセッション全体設計

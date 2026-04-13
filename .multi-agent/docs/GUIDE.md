# マルチエージェント構成 使い方ガイド

## 概要

```
Commander（Claude Code セッション1）
  タスク分解・Worker指示・一次評価・議論・上告

Observer（Claude Code セッション2）
  自律監視・Gate評価・fail起票・タイムアウト検知

Worker（Codex セッション3〜）
  コーディング・テスト・デバッグの実行
```

エージェント間の連携はすべて**ファイルベース**で行います。
メッセージングは使いません。各エージェントは自分の担当ファイルを読み書きします。

---

## セットアップ

### 1. ファイル構成

このリポジトリをクローンするだけで使えます。主要なファイルの場所：

```
your-project/
├── AGENTS.md                          # Codex向けプロジェクト共通設定
├── .claude/skills/                    # Claude Code Skills（Commander/Observer用）
├── .agents/skills/                    # Codex向けSkills（Worker用）
├── .multi-agent/
│   ├── roles/
│   │   ├── commander/CLAUDE.md        # Commander のシステムプロンプト
│   │   ├── observer/CLAUDE.md         # Observer のシステムプロンプト
│   │   └── worker/CLAUDE.md           # Worker のシステムプロンプト
│   ├── config/RULEBOOK.md             # Observer の評価基準
│   └── templates/task/                # タスクテンプレート
├── runtime/                           # セッション状態
└── tasks/                             # タスク実行結果
```

### 2. BOARD.md を初期設定する

`runtime/BOARD.md` を作成（または更新）して以下を設定します：

```yaml
session_id: session-001
base_branch: develop        # ユーザーが作業起点を指定
base_branch_created_by: user
started_at: 2026-04-01T10:00:00
```

`base_branch` はユーザーが事前に作成してから指定します。
Commander がマージできるのはこのブランチまでです。

### 3. CONTEXT.md にプロジェクト方針を書く

`runtime/CONTEXT.md` に以下を記載します：

```markdown
## プロジェクト方針
（ユーザーから受けた指示・全体目標）

## 技術スタック
language: Python  # または TypeScript / Go / Java
```

---

## セッションの起動方法

### Commander セッション

Claude Code を起動し、以下を伝えます：

```
.multi-agent/roles/commander/CLAUDE.md を読んで、
セッション開始手順に従ってください。
今回のタスクは：（ユーザーの指示）
```

### Observer セッション

Claude Code を別セッションで起動し、以下を伝えます：

```
.multi-agent/roles/observer/CLAUDE.md を読んで、
自律チェックを開始してください。
プロジェクトルートは（パス）です。
```

Observer は Commander・Worker とは独立して動きます。
定期的に手動で「チェックしてください」と声をかけるか、
Commander が `runtime/BOARD.md` の `observer_request` を更新することで呼び出せます。

### Worker セッション

Claude Code（Codex Plugin 使用）を起動し、以下を伝えます：

```
.multi-agent/roles/worker/CLAUDE.md を読んで、
tasks/task-xxx/spec.md に従って作業を開始してください。
```

Worker は spec.md を受け取るたびに新しいセッションを起動します。

---

## 通常の作業フロー

```
【1】ユーザーが Commander に指示を出す

【2】Commander がタスクを分解する
  → tasks/task-xxx/ を作成
  → spec.md を書く
  → tasks/task-xxx/AGENTS.md を書く（Codex 向け）
  → runtime/BOARD.md を更新する

【3】Observer が Gate1 評価を行う
  → tasks/task-xxx/observer_review.md を書く
  → pass → Commander が Worker に着手許可
  → fail → runtime/DISCUSSION.md に起票 → Commander と議論

【4】Worker がタスクを実行する
  → task/task-xxx ブランチで作業
  → Codex に実装を委譲
  → 完了したら result.md を最終報告として作成

【5】Commander が一次評価を行う
  → commander_review.md を書く

【6】Observer が Gate2 評価を行う
  → observer_review.md を書く
  → pass → Commander が base_branch にマージ
  → fail → runtime/DISCUSSION.md に起票 → Commander と議論

【7】次のタスクへ
```

---

## 議論・上告フロー

```
Observer が fail を起票（runtime/DISCUSSION.md）
　　↓
Commander が応答（最大 N 往復・runtime/BOARD.md の discussion_round_limit）
　　↓
合意 → フロー再開
未合意（N 往復到達）→ Commander が上告義務
　　↓
Commander がユーザーに状況を説明して決裁を求める

※ fail 記録は runtime/EVENTLOG.json に常時蓄積
   runtime/SUMMARY.md でユーザーに常時可視
   Commander が上告しなくても証拠として残る
```

---

## セッション切り替え

長時間タスクや意図的な中断時は以下の手順で切り替えます。

```
【終了時】
Commander：runtime/CONTEXT.md を更新して終了
  - 現時点の判断基準
  - 未解決事項
  - 次セッションへの申し送り

【再開時】
Commander：以下の順で読み込む
  1. runtime/CONTEXT.md
  2. runtime/BOARD.md
  3. runtime/EVENTLOG.json の末尾 20件
  4. runtime/SUMMARY.md の未解決イベント一覧
  5. suspended タスクの result.md
  6. runtime/BOARD.md の observer_request を確認
```

`runtime/CONTEXT.md` はタスク完了ごとに更新することを推奨します（クラッシュ対策）。

---

## タスクの作り方

`.multi-agent/templates/task/spec.md` をコピーして `tasks/task-xxx/spec.md` を作成します。
同時に `.multi-agent/templates/task/AGENTS.md` をコピーして `tasks/task-xxx/AGENTS.md` も作成します。

```
tasks/
  task-001/
    spec.md              ← Commander が作成
    AGENTS.md            ← Commander が作成（Codex向け設定）
    result.md            ← Worker が作成
    commander_review.md  ← Commander が作成
    observer_review.md   ← Observer が作成
```

### spec.md の重要フィールド

```yaml
depends_on: []               # 依存タスクの task_id リスト
parallel_ok: false           # 他タスクと並列実行できるか
output_artifacts: [src/x.py] # このタスクが生成するファイル
input_artifacts: []          # このタスクが必要とするファイル
environment_verified: true   # Commander が環境準備済みか
commander_reasoning: |       # タスク分解の根拠（Observer が Gate1 で確認）
  （理由）
```

`output_artifacts` が他タスクと重複していないことを Commander が確認します。
重複は Observer が Gate1 で検出します。

---

## ファイル別の書き込み権限

| ファイル | Commander | Observer | Worker |
|---------|----------|---------|--------|
| runtime/BOARD.md | ✅ | ❌ | ❌ |
| runtime/CONTEXT.md | ✅ | ❌ | ❌ |
| runtime/DISCUSSION.md | ✅ | ✅ | ❌ |
| runtime/EVENTLOG.json | ✅ | ✅ | ❌ |
| runtime/SUMMARY.md | ✅ | ✅ | ❌ |
| tasks/task-xxx/spec.md | ✅ | ❌ | ❌ |
| tasks/task-xxx/AGENTS.md | ✅ | ❌ | ❌ |
| tasks/task-xxx/result.md | ❌ | ❌ | ✅ |
| tasks/task-xxx/commander_review.md | ✅ | ❌ | ❌ |
| tasks/task-xxx/observer_review.md | ❌ | ✅ | ❌ |

---

## Git ルール

| 操作 | 権限 |
|-----|------|
| 作業起点ブランチの作成 | User |
| task/* ブランチの作成・コミット | Worker |
| task/* → 起点ブランチへのマージ | Commander（Gate2 pass 後のみ） |
| 起点ブランチより上流へのマージ | User のみ |

Worker のコミットメッセージ：
```
中間報告時：wip: task-001 （進捗概要）
完了時：    feat/fix/test: task-001 （作業概要）
失敗時：    wip: task-001 [FAILED] （理由）
```

---

## よくある操作

### Observer を今すぐ呼び出したい

`runtime/BOARD.md` の `observer_request` を更新します：

```yaml
observer_request:
  task_id: task-001
  reason: "途中成果物を早期確認してほしい"
  requested_at: "2026-04-01T11:00:00"
```

Observer セッションに「チェックしてください」と声をかけます。

### タスクが stuck している

`runtime/BOARD.md` で該当タスクの状態を確認します。
`observer_timeout` が `runtime/EVENTLOG.json` に記録されている場合は
Commander セッションに「task-xxx の状態を確認してください」と伝えます。

### セッションが突然終了した

`runtime/CONTEXT.md` と `runtime/BOARD.md` を読み込んだ新しい Commander セッションを起動します。
`suspended` タスクがあれば `result.md` を読んで `resume_action` を決定します。

### ユーザーが作業を中断したい

Commander セッションに「ここで一旦止めてください」と伝えます。
Commander が `runtime/CONTEXT.md` を更新して終了します。
Worker には spec.md に `status: suspended` が追記されます。

---

## ファイル構成まとめ

```
your-project/
├── AGENTS.md                          # Codex向けプロジェクト共通設定
│
├── .claude/skills/                    # Claude Code Skills（Commander/Observer用）
│   ├── task-decomposition/            # /decompose-task
│   ├── gate-evaluation/               # /evaluate-gate
│   ├── status-sync/                   # /sync-status
│   ├── code-reading/
│   ├── code-review/
│   └── {python,typescript,go,java}-{setup,quality-check}/
│
├── .agents/skills/                    # Codex向けSkills（Worker用）
│   └── {python,typescript,go,java}-{setup,quality-check}/
│
├── .multi-agent/
│   ├── roles/
│   │   ├── commander/CLAUDE.md        # Commander のシステムプロンプト
│   │   ├── observer/CLAUDE.md         # Observer のシステムプロンプト
│   │   └── worker/CLAUDE.md           # Worker のシステムプロンプト
│   ├── config/
│   │   ├── RULEBOOK.md                # Observer の評価基準
│   │   └── languages/                 # 言語固有の設定
│   ├── templates/task/                # タスクテンプレート
│   │   ├── spec.md
│   │   ├── AGENTS.md                  # Codex向けタスク設定テンプレート
│   │   ├── result.md
│   │   ├── commander_review.md
│   │   └── observer_review.md
│   └── docs/
│       ├── GUIDE.md                   # このファイル
│       ├── MIGRATION.md               # ファイル構成の変更履歴
│       └── ...
│
├── runtime/                           # セッション状態
│   ├── BOARD.md                       # タスク状態・依存グラフ・policy
│   ├── CONTEXT.md                     # セッション引き継ぎ
│   ├── DISCUSSION.md                  # Commander-Observer 議論ログ
│   ├── EVENTLOG.json                  # 全イベント記録（機械処理用）
│   └── SUMMARY.md                     # 人間向け進捗サマリー
│
└── tasks/                             # タスク実行結果
    └── task-xxx/
        ├── spec.md
        ├── AGENTS.md
        ├── result.md
        ├── commander_review.md
        └── observer_review.md
```

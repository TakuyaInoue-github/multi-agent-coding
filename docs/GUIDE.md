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

### 1. ファイルを配置する

```
your-project/
  CLAUDE.md          ← CLAUDE_COMMANDER.md をリネームして配置
  RULEBOOK.md
  BOARD.md
  CONTEXT.md
  DISCUSSION.md
  EVENTLOG.json
  SUMMARY.md
  tasks/
    spec_template.md
    result_template.md
    commander_review_template.md
    observer_review_template.md
  archive/
  （既存のプロジェクトファイル）
```

Observer・Worker 用の CLAUDE.md は別途保管しておき、
各セッション開始時にシステムプロンプトとして渡します。

### 2. BOARD.md を初期設定する

```yaml
session_id: session-001
base_branch: develop        # ユーザーが作業起点を指定
base_branch_created_by: user
started_at: 2026-03-31T10:00:00
```

`base_branch` はユーザーが事前に作成してから指定します。
Commander がマージできるのはこのブランチまでです。

### 3. CONTEXT.md にプロジェクト方針を書く

```markdown
## プロジェクト方針
（ユーザーから受けた指示・全体目標）
```

---

## セッションの起動方法

### Commander セッション

Claude Code を起動し、以下を伝えます：

```
CLAUDE.md（CLAUDE_COMMANDER.md）を読んで、
セッション開始手順に従ってください。
今回のタスクは：（ユーザーの指示）
```

### Observer セッション

Claude Code を別セッションで起動し、以下を伝えます：

```
（CLAUDE_OBSERVER.md の内容を貼り付ける）

自律チェックを開始してください。
プロジェクトルートは（パス）です。
```

Observer は Commander・Worker とは独立して動きます。
定期的に手動で「チェックしてください」と声をかけるか、
Commander が `BOARD.md` の `observer_request` を更新することで呼び出せます。

### Worker セッション

Codex を起動し、以下を伝えます：

```
（CLAUDE_WORKER.md の内容を貼り付ける）

tasks/task-xxx/spec.md を読んで作業を開始してください。
```

Worker は spec.md を受け取るたびに新しいセッションを起動します。

---

## 通常の作業フロー

```
【1】ユーザーが Commander に指示を出す

【2】Commander がタスクを分解する
  → tasks/task-xxx/ を作成
  → spec.md を書く
  → BOARD.md を更新する

【3】Observer が Gate1 評価を行う
  → tasks/task-xxx/observer_review.md を書く
  → pass → Commander が Worker に着手許可
  → fail → DISCUSSION.md に起票 → Commander と議論

【4】Worker がタスクを実行する
  → task/task-xxx ブランチで作業
  → 中間報告を result.md に追記
  → 完了したら result.md を最終報告に更新

【5】Commander が一次評価を行う
  → commander_review.md を書く

【6】Observer が Gate2 評価を行う
  → observer_review.md を書く
  → pass → Commander が base_branch にマージ
  → fail → DISCUSSION.md に起票 → Commander と議論

【7】次のタスクへ
```

---

## 議論・上告フロー

```
Observer が fail を起票（DISCUSSION.md）
　　↓
Commander が応答（最大 N 往復・BOARD.md の discussion_round_limit）
　　↓
合意 → フロー再開
未合意（N 往復到達）→ Commander が上告義務
　　↓
Commander がユーザーに状況を説明して決裁を求める

※ fail 記録は EVENTLOG.json に常時蓄積
   SUMMARY.md でユーザーに常時可視
   Commander が上告しなくても証拠として残る
```

---

## セッション切り替え

長時間タスクや意図的な中断時は以下の手順で切り替えます。

```
【終了時】
Commander：CONTEXT.md を更新して終了
  - 現時点の判断基準
  - 未解決事項
  - 次セッションへの申し送り

【再開時】
Commander：以下の順で読み込む
  1. CONTEXT.md
  2. BOARD.md
  3. EVENTLOG.json の末尾 20件
  4. SUMMARY.md の未解決イベント一覧
  5. suspended タスクの result.md
  6. BOARD.md の observer_request を確認
```

CONTEXT.md はタスク完了ごとに更新することを推奨します（クラッシュ対策）。

---

## タスクの作り方

`tasks/spec_template.md` をコピーして `tasks/task-xxx/spec.md` を作成します。

```
tasks/
  task-001/
    spec.md              ← Commander が作成
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
| BOARD.md | ✅ | ❌ | ❌ |
| CONTEXT.md | ✅ | ❌ | ❌ |
| DISCUSSION.md | ✅ | ✅ | ❌ |
| EVENTLOG.json | ✅ | ✅ | ❌ |
| SUMMARY.md | ✅ | ✅ | ❌ |
| spec.md | ✅ | ❌ | ❌ |
| result.md | ❌ | ❌ | ✅ |
| commander_review.md | ✅ | ❌ | ❌ |
| observer_review.md | ❌ | ✅ | ❌ |

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

`BOARD.md` の `observer_request` を更新します：

```yaml
observer_request:
  task_id: task-001
  reason: "途中成果物を早期確認してほしい"
  requested_at: "2026-03-31T11:00:00"
```

Observer セッションに「チェックしてください」と声をかけます。

### タスクが stuck している

`BOARD.md` で該当タスクの状態を確認します。
`observer_timeout` が EVENTLOG.json に記録されている場合は
Commander セッションに「task-xxx の状態を確認してください」と伝えます。

### セッションが突然終了した

`CONTEXT.md` と `BOARD.md` を読み込んだ新しい Commander セッションを起動します。
`suspended` タスクがあれば `result.md` を読んで `resume_action` を決定します。

### ユーザーが作業を中断したい

Commander セッションに「ここで一旦止めてください」と伝えます。
Commander が `CONTEXT.md` を更新して終了します。
Worker には spec.md に `status: suspended` が追記されます。

---

## ファイル構成まとめ

```
your-project/
  CLAUDE.md                    # Commander 用（CLAUDE_COMMANDER.md をリネーム）
  RULEBOOK.md                  # Observer の評価基準
  BOARD.md                     # タスク状態・依存グラフ・policy
  CONTEXT.md                   # セッション引き継ぎ
  DISCUSSION.md                # Commander-Observer 議論ログ
  EVENTLOG.json                # 全イベント記録（機械処理用）
  SUMMARY.md                   # 人間向け進捗サマリー

  tasks/
    spec_template.md           # タスク指示書テンプレート
    result_template.md         # 成果物報告テンプレート
    commander_review_template.md
    observer_review_template.md
    task-001/
      spec.md
      result.md
      commander_review.md
      observer_review.md

  archive/
    DISCUSSION_archive_001.md  # DISCUSSION 肥大化時の退避先
    CONTEXT_archive_001.md     # 古いセッションの CONTEXT

  （既存のプロジェクトファイル）
```

---

## 別途保管するファイル（プロジェクトルートには置かない）

```
CLAUDE_OBSERVER.md   # Observer セッション開始時にシステムプロンプトとして渡す
CLAUDE_WORKER.md     # Worker セッション開始時にシステムプロンプトとして渡す
```

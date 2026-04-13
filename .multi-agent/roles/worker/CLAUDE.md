# CLAUDE.md - Worker

あなたはこのプロジェクトの **Worker** です。
与えられた `spec.md` の指示に従い、タスクを実行してください。

**重要**: Worker は **Codex に実装を委譲**します。あなた（Claude Code）は：
- spec.md を読んで理解する
- `/codex:rescue` コマンドで Codex にタスクを渡す
- Codex の実行結果を確認する
- result.md を作成して報告する

指示の範囲外のことは行わないでください。
判断に迷った場合は実行を止めて `result.md` に `blocked_reason` を記載してください。

---

## 前提条件: Codex Plugin のセットアップ

**初回のみ実行してください**:

```bash
# 1. プラグインをインストール
/plugin marketplace add openai/codex-plugin-cc
/plugin install codex@openai-codex
/reload-plugins

# 2. セットアップ
/codex:setup
```

詳細は `.multi-agent/docs/CODEX_SETUP.md` を参照してください。

---

## タスク開始時の手順

1. `tasks/task-xxx/spec.md` を読む
2. `permissions` を確認する（書き込み可能なパス・実行可能なコマンド）
3. `required_packages` が環境に揃っているか確認する（揃っていない場合は blocked）
4. `input_artifacts` が存在するか確認する（存在しない場合は blocked）
5. `task/task-xxx` ブランチに切り替える（なければ作成する）
6. Codex にタスクを委譲する（次のセクション参照）

---

## Codex へのタスク委譲

### 基本的な委譲フロー

1. **spec.md の内容を整形**
   ```
   spec.md から以下を抽出：
   - 指示内容
   - 期待する成果物（output_artifacts）
   - 注意事項
   - permissions の制約
   ```

2. **Codex にタスクを委譲**

   **重要**: `tasks/task-xxx/AGENTS.md` が存在する場合、Codex はそれを自動的に読み込む。
   プロンプトは簡潔に保ち、詳細は AGENTS.md に委ねる。

   ```bash
   /codex:rescue --background "
   tasks/[task_id]/spec.md と tasks/[task_id]/AGENTS.md に従って実装してください。

   ## タスク: [task_id]

   ### 指示内容
   [spec.md の「指示内容」セクションをそのまま貼り付け]

   ### 期待する成果物
   [output_artifacts のリスト]
   - path/to/file1.js
   - path/to/file2.css

   ### 重要
   - 実装後、tasks/[task_id]/AGENTS.md の品質チェックをすべて実行すること
   - 全通過してからコミットすること
   - チェックが通らない場合は自分で修正してから再実行すること
   "
   ```

3. **進捗を監視**
   ```bash
   # バックグラウンド実行の状態を確認
   /codex:status
   ```

4. **完了を確認**
   - Codex が生成したファイルを確認
   - 成功基準を1つずつチェック
   - 問題があれば `/codex:rescue --resume` で修正依頼

### Codex コマンドのオプション

#### タスク委譲
```bash
# バックグラウンド実行（推奨）
/codex:rescue --background "タスク内容"

# 完了まで待機（短時間タスク）
/codex:rescue --wait "タスク内容"

# モデル指定
/codex:rescue --model gpt-4o-mini "簡単なタスク"

# 前回の続き
/codex:rescue --resume "前回の修正を適用"
```

#### 進捗確認
```bash
/codex:status
```

#### タスクキャンセル
```bash
/codex:cancel
```

### モデル選択のガイドライン

| タスクの複雑度 | 推奨モデル | 理由 |
|--------------|-----------|------|
| 簡単な実装 | `gpt-4o-mini` | コスト効率が良い |
| 標準的な実装 | `gpt-4o` | バランスが良い |
| 複雑なロジック | `o1-mini` | 推論能力が高い |
| アルゴリズム | `o3-mini` | 最高性能 |

spec.md に記載がない場合はデフォルト（`.codex/config.toml` の設定）を使用。

---

## 中間報告の手順

以下のタイミングで `result.md` に追記する：

- 作業の区切り（サブタスク完了時）
- 問題・ブロッカーを発見した時
- 長時間作業の場合は定期的に

```yaml
---
task_id: task-xxx
status: in_progress
attempt: 1
branch: task/task-xxx
merge_status: pending
commit: （現時点のコミットハッシュ）
timestamp: （現在時刻）
---

## 中間報告 Round N
（自然言語）
```

コミットは以下の形式で行う：
```
wip: task-xxx （進捗概要）
```

---

## タスク完了時の手順

1. **Codex の実行結果を確認**
   ```bash
   # 進捗状態を確認
   /codex:status

   # 生成されたファイルを確認
   ls [output_artifacts のパス]

   # 成功基準をチェック
   [spec.md の成功基準を1つずつ確認]
   ```

2. **Git コミットを確認**
   ```bash
   # Codex が自動的にコミットしている場合が多い
   git log -1

   # コミットメッセージが不適切な場合は修正
   git commit --amend -m "feat: task-xxx （作業概要）"
   ```

   Codex がコミットしていない場合は手動でコミット：
   ```bash
   git add [変更ファイル]
   git commit -m "feat: task-xxx （作業概要）"
   ```

3. **result.md を作成**
   `result.md` を最終報告として作成する（`status: completed`）
   `.multi-agent/templates/task/result.md` の全セクションを埋める

4. **Commander に完了を報告**

**Human Control モード時の出力:**
```markdown
---
✅ **タスク完了**

task-xxx の実装が完了しました。

📋 **次のステップ (Human Control)**:
1. 別のターミナルで `tmux attach-session -t commander` を実行
2. Commanderに以下を依頼: "task-xxx の Worker 実装が完了しました。一次評価（commander_review.md作成）を実施してください"
3. Commander が一次評価を完了したら、Observer セッションへ移動

📂 **確認すべきファイル**:
- `tasks/task-xxx/result.md`: 完了報告
- output_artifacts（成果物）: spec.md に記載されているファイル
- git log: コミット履歴
---
```

---

## タスク失敗時の手順

1. **Codex のエラーを確認**
   ```bash
   # エラー内容を確認
   /codex:status

   # 必要に応じて修正を試みる
   /codex:rescue --resume "エラーを修正してください: [エラー内容]"
   ```

2. **修正不可能な場合は失敗として報告**

   失敗のコミットを行う（Codex がコミットしていない場合）：
   ```bash
   git add .
   git commit -m "wip: task-xxx [FAILED] （理由）"
   ```

3. **result.md を作成**
   - `status: failed`
   - `未達・問題` セクションに失敗理由を詳細に記載
   - Codex のエラーメッセージを含める
   - `申し送り` セクションに次の attempt への情報を記載

4. **Commander に失敗を報告**

**Human Control モード時の出力:**
```markdown
---
❌ **タスク失敗**

task-xxx の実装に失敗しました。

📋 **次のステップ (Human Control)**:
1. 別のターミナルで `tmux attach-session -t commander` を実行
2. Commanderに以下を依頼: "task-xxx が失敗しました。result.md を確認して、リトライまたは仕様変更を判断してください"
3. Commander の判断を待つ

📂 **確認すべきファイル**:
- `tasks/task-xxx/result.md`: 失敗理由と申し送り
- git log: 失敗時点のコミット
- `runtime/BOARD.md`: retry_limit の残数
---
```

---

## blocked 時の手順

以下の場合は即座に作業を止めて報告する：

- `required_packages` が存在しない
- `input_artifacts` が存在しない
- `permissions` の範囲外の操作が必要になった
- 仕様が不明確で判断できない
- Codex が繰り返しエラーを出す（3回以上）

**手順**:

1. **実行中の Codex タスクをキャンセル**
   ```bash
   /codex:cancel
   ```

2. **result.md を作成**
   - `status: blocked`
   - `未達・問題` セクションに `blocked_reason` を明記
   - Codex を実行した場合はそのログも含める

3. **Commander にエスカレーション**

**Human Control モード時の出力:**
```markdown
---
🚫 **タスクブロック**

task-xxx がブロックされました。

📋 **次のステップ (Human Control)**:
1. 別のターミナルで `tmux attach-session -t commander` を実行
2. Commanderに以下を依頼: "task-xxx がブロックされました。result.md を確認して、環境整備または仕様変更を実施してください"
3. Commander がブロックを解消したら、このセッションに戻って再開

📂 **確認すべきファイル**:
- `tasks/task-xxx/result.md`: ブロック理由（blocked_reason）
- `tasks/task-xxx/spec.md`: 仕様（修正が必要な場合）
- `runtime/BOARD.md`: タスクステータス
---
```

---

## 権限ルール

`spec.md` の `permissions` に従い厳守する：

| 操作 | 確認先 |
|-----|-------|
| ファイル書き込み | permissions.filesystem.write に含まれるパスのみ |
| コマンド実行 | permissions.execution.allowed に含まれるもののみ |
| ネットワーク | permissions.network.disallowed に含まれないもののみ |
| パッケージインストール | 禁止（Commander が事前に準備する） |
| develop/main への操作 | 禁止 |
| runtime/BOARD.md 等プロジェクトファイルへの書き込み | 禁止 |

---

## Git ルール

| 操作 | 可否 |
|-----|------|
| task/task-xxx ブランチの作成・コミット | ✅ |
| task/task-xxx へのプッシュ | ✅ |
| 他のブランチへの操作 | ❌ |
| develop / main へのマージ | ❌ |

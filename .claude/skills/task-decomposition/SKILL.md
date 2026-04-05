---
name: decompose-task
description: ユーザー指示を依存関係を持つ並列可能なサブタスクに分解するCommanderワークフロー
disable-model-invocation: false
user-invocable: true
allowed-tools: [editor, bash]
---

# タスク分解 Skill

Commanderがユーザー指示をWorkerエージェント用の実行可能なサブタスクに分解するために使用します。

## 使用方法

```bash
/decompose-task "アプリにOAuth2認証を追加" "web-app"
/decompose-task "$ARGUMENTS"  # 完全なユーザー指示を渡す
```

## 引数

- `$0` = ユーザー指示（要求された機能や変更）
- `$1` = プロジェクト種別（オプション: web-app, lib, cli, data-pipeline）
- `$2` = コンテキストヒント（オプション: 追加のコンテキスト情報）

## 出力形式

以下の構造でYAMLドキュメントを作成：

```yaml
decomposition:
  instruction_summary: （指示の簡潔な再記述）
  project_type: $1
  task_count: N
  has_sequential_dependency: true|false
  critical_path_length: N

  tasks:
    - task_id: task-001
      name: "明確で具体的なタスク名"
      description: "何が成果物として得られるか"
      depends_on: []  # 他のタスクID
      parallel_ok: true
      worker_type: coding|testing|debugging|refactoring

      input_artifacts:
        - path/to/config.json
        - path/to/existing/code

      output_artifacts:
        - path/to/generated/file
        - path/to/modified/file

      required_packages:
        - package@version

      permissions:
        filesystem:
          write: [src/, config/]
          read: [., docs/]
        execution:
          allowed: [npm, node, git]
          disallowed: [rm -rf]  # 破壊的操作
        network:
          disallowed: []

      estimated_complexity: simple|medium|complex
      estimated_duration_minutes: 15

      success_criteria:
        - テストがすべてパス
        - 出力ファイルが存在し、有効である
        - リグレッションがない

      risks: []

  dependency_analysis:
    sequential_groups:
      - [task-001]
      - [task-002, task-003]  # 並列実行可能
      - [task-004]

    critical_path: [task-001 -> task-004]
    parallelizable_tasks: [task-002, task-003]

  commander_reasoning: |
    なぜこのように分解したかを説明する。
    - なぜこのタスク境界にしたか？
    - なぜこれらの依存関係があるか？
    - どれが並列化できるか？
    - 並列化した場合のリスクは？
```

## 分解の原則

### 1. タスク粒度の決定

**適切な粒度:**
- 最小: 50行以上のコード、または3時間以上の作業
- 最大: 500行以下のコード、または2日以下の作業

**避けるべき粒度:**
- 「ファイルを1行変更」のような過度に小さいタスク
- 「アプリ全体を実装」のような過度に大きいタスク

### 2. 依存関係の識別

**depends_on に含めるべき:**
- 前のタスクの output_artifacts を input_artifacts として使う場合
- 前のタスクで設定した環境が必要な場合
- 前のタスクのロジックに依存する実装の場合

**parallel_ok = true にできる条件:**
- output_artifacts が他のタスクと重複しない
- 互いに依存していない
- 同じファイルを編集しない

### 3. 成功基準の明確化

各タスクに以下を含める：
- 機能的な成功基準（「ユーザーがログインできる」）
- 技術的な成功基準（「テストカバレッジ80%以上」）
- 品質基準（「リンターエラーなし」）

## 関連ファイル

Workerが実際に実行する形式は `.multi-agent/templates/task/spec.md` を参照。
実際の分解例は `examples/` を参照。
Gate1評価基準は `.multi-agent/config/RULEBOOK.md` を参照。

## マルチエージェントシステムとの統合

分解後の流れ：
1. Commander が出力をレビュー
2. Commander が `/sync-status sync-board` を呼び出して BOARD.md を更新
3. Commander が各タスクに対して `/evaluate-gate 1 task-001 spec_review` を呼び出す（実際はObserverが自律的に実行）
4. Gate1がpassしたら、Commanderがこの分解から `tasks/task-xxx/spec.md` を作成
5. Workerが `spec.md` を読んで実行

## テンプレート参照

`.multi-agent/templates/task-spec.md` から `tasks/task-xxx/spec.md` を作成する際の変換マッピング：

- `decomposition.tasks[].task_id` → `spec.md` の `task_id`
- `decomposition.tasks[].permissions` → `spec.md` の `permissions`
- `decomposition.tasks[].required_packages` → `spec.md` の `required_packages`
- `decomposition.tasks[].description` → `spec.md` の「指示内容」セクション
- `decomposition.tasks[].output_artifacts` → `spec.md` の「期待する成果物」セクション

## 例

### 簡単なタスク分解

**ユーザー指示:** 「READMEにインストール手順を追加」

**分解:**
```yaml
decomposition:
  instruction_summary: "READMEファイルにインストール手順セクションを追加"
  task_count: 1
  has_sequential_dependency: false

  tasks:
    - task_id: task-001
      name: "READMEにインストール手順を追加"
      description: "READMEにインストール手順のセクションを記述する"
      depends_on: []
      parallel_ok: true
      worker_type: coding

      input_artifacts: [README.md]
      output_artifacts: [README.md]
      required_packages: []

      permissions:
        filesystem:
          write: [README.md]

      estimated_complexity: simple
      estimated_duration_minutes: 10
```

### 複雑なタスク分解

**ユーザー指示:** 「ユーザー認証機能を追加」

**分解:**
```yaml
decomposition:
  instruction_summary: "OAuth2ベースのユーザー認証システムを実装"
  task_count: 4
  has_sequential_dependency: true
  critical_path_length: 4

  tasks:
    - task_id: task-001
      name: "認証データモデルの作成"
      description: "ユーザー、セッション、トークンのモデルを定義"
      depends_on: []
      parallel_ok: true
      worker_type: coding

      output_artifacts: [src/models/user.js, src/models/session.js]
      required_packages: [bcrypt@5.0.0]

      permissions:
        filesystem:
          write: [src/models/]

      estimated_complexity: medium
      estimated_duration_minutes: 60

    - task_id: task-002
      name: "認証APIエンドポイントの実装"
      description: "/login, /logout, /refresh エンドポイントを作成"
      depends_on: [task-001]
      parallel_ok: false
      worker_type: coding

      input_artifacts: [src/models/user.js]
      output_artifacts: [src/routes/auth.js]

      estimated_complexity: complex
      estimated_duration_minutes: 120

    - task-003:
      name: "認証ミドルウェアの作成"
      description: "リクエストの認証を検証するミドルウェア"
      depends_on: [task-001]
      parallel_ok: true  # task-002と並列実行可能
      worker_type: coding

      estimated_complexity: medium
      estimated_duration_minutes: 45

    - task_id: task-004
      name: "認証機能のテスト"
      description: "ユニットテストと統合テストを作成"
      depends_on: [task-002, task-003]
      parallel_ok: false
      worker_type: testing

      estimated_complexity: complex
      estimated_duration_minutes: 90

  dependency_analysis:
    sequential_groups:
      - [task-001]
      - [task-002, task-003]  # 並列実行可能
      - [task-004]

    critical_path: [task-001 -> task-002 -> task-004]
    parallelizable_tasks: [task-002, task-003]

  commander_reasoning: |
    タスク001でデータモデルを確立してから、それを使用する機能を実装する。
    task-002（API）とtask-003（ミドルウェア）は異なるファイルを編集するため並列実行可能。
    すべてが完成してからテスト（task-004）を実行する。
```

## 自己チェックリスト

分解完了後、以下を確認：

- [ ] すべてのタスクに一意の task_id がある
- [ ] depends_on に存在しないタスクIDが含まれていない
- [ ] output_artifacts が他タスクと重複していない
- [ ] input_artifacts が depends_on によって保証されている
- [ ] required_packages が明記されている
- [ ] commander_reasoning が明記されている
- [ ] parallel_ok = true のタスクが実際に並列実行可能である
- [ ] タスク粒度が適切（最小50行・3時間、最大500行・2日）

このチェックリストは Gate1 評価でObserverが確認する項目と同じです。

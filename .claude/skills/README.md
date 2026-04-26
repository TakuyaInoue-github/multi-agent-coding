# Multi-Agent System Skills

Commander / Observer / Worker が使用するSkillsです。

**設計方針**: CLAUDE.mdには役割・権限ルールのみを定義し、「どうやるか」の手順はすべてSkillに集約しています。

---

## Skill一覧

### Commander 用

| Skill | 目的 | 呼び出し方 |
|-------|------|----------|
| `decompose-task` | ユーザー指示をサブタスクに分解 | `/decompose-task "指示内容"` |
| `assign-worker` | Gate1通過タスクをWorkerに割り当て | `/assign-worker task-xxx` |
| `review-result` | Workerの成果物を一次評価 | `/review-result task-xxx` |
| `handle-discussion` | ObserverのDISCUSSION起票に応答 | `/handle-discussion task-xxx` |
| `sync-status` | BOARD・EVENTLOGの更新 | `/sync-status action task-xxx details` |

### Observer 用

| Skill | 目的 | 呼び出し方 |
|-------|------|----------|
| `evaluate-gate` | spec/result の品質評価（Gate1/Gate2） | `/evaluate-gate 1 task-xxx spec_review` |
| `sync-status` | EVENTLOGの記録（append-event のみ） | `/sync-status append-event task-xxx details` |

### Worker 用

| Skill | 目的 | 呼び出し方 |
|-------|------|----------|
| `start-task` | 事前確認・ブランチ作成・Codex委譲 | `/start-task task-xxx` |

### 汎用（全エージェント）

| Skill | 目的 | 呼び出し方 |
|-------|------|----------|
| `code-reading` | コードの理解・読解 | `/code-reading "対象ファイル"` |
| `code-review` | コードレビュー | `/code-review "対象ファイル"` |

---

## 関連ドキュメント

- `.multi-agent/roles/commander/CLAUDE.md` — Commanderの役割・権限
- `.multi-agent/roles/observer/CLAUDE.md` — Observerの役割・権限
- `.multi-agent/roles/worker/CLAUDE.md` — Workerの役割・権限
- `.multi-agent/config/RULEBOOK.md` — 評価基準

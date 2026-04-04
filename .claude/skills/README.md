# Multi-Agent System Skills

マルチエージェントシステム（Commander / Observer / Worker）で使用するSkillsです。

## Skill一覧

| Skill | 目的 | 対象エージェント | 呼び出し方 |
|-------|------|---------------|-----------|
| `decompose-task` | ユーザー指示をサブタスクに分解 | Commander | `/decompose-task "指示内容" "プロジェクト種別"` |
| `evaluate-gate` | spec/result の品質評価 | Observer | `/evaluate-gate 1 task-id spec_review` |
| `status-sync` | ランタイムファイルの更新 | Commander | `/sync-status action task-id details` |

## Skillsの配置

Skillsは `.claude/skills/` に配置され、Claude Codeによって自動的に検出されます。

### 手動呼び出し

```bash
/decompose-task "認証機能を追加" "web-app"
/evaluate-gate 1 task-001 spec_review
/sync-status sync-board task-001 '{"status":"completed"}'
```

### 自動呼び出し

必要な内容を伝えると、Claudeが自動的に適切なSkillを読み込みます：
- 「このタスクを分解してください」 → `/decompose-task` を自動読み込み
- 「Gate1評価をしてください」 → `/evaluate-gate` を自動読み込み

## ベストプラクティス

1. `/sync-status` を使用してEVENTLOG.jsonの整合性を保つ
2. 判断前に `runtime/BOARD.md` を参照
3. 実際の使用例は各Skillの `examples/` を参照
4. SKILL.mdの指示は明確かつ簡潔に保つ

## ディレクトリ構造

```
.claude/skills/
├── README.md（このファイル）
├── task-decomposition/
│   ├── SKILL.md
│   ├── templates/
│   └── examples/
├── gate-evaluation/
│   ├── SKILL.md
│   ├── checklists/
│   └── examples/
└── status-sync/
    └── SKILL.md
```

## 関連ドキュメント

- [agents/commander/CLAUDE.md](../../agents/commander/CLAUDE.md) - Commander用プロンプト（Skillsの使い方を含む）
- [agents/observer/CLAUDE.md](../../agents/observer/CLAUDE.md) - Observer用プロンプト（Skillsの使い方を含む）
- [config/RULEBOOK.md](../../config/RULEBOOK.md) - 評価基準
- [templates/task/](../../templates/task/) - タスクテンプレート

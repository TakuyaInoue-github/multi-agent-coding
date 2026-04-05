# ファイル構成の移行ガイド

**移行日**: 2026-04-04
**バージョン**: 1.0 → 2.0

## 変更概要

プロジェクトのファイル構成を再設計し、関心の分離に基づいた整理を行いました。

## 変更前後の対応表

### エージェント定義ファイル

| 旧パス | 新パス |
|-------|-------|
| `CLAUDE_COMMANDER.md` | `.multi-agent/roles/commander/CLAUDE.md` |
| `CLAUDE_OBSERVER.md` | `.multi-agent/roles/observer/CLAUDE.md` |
| `CLAUDE_WORKER.md` | `.multi-agent/roles/worker/CLAUDE.md` |

### 設定・ルールファイル

| 旧パス | 新パス |
|-------|-------|
| `RULEBOOK.md` | `.multi-agent/.multi-agent/config/RULEBOOK.md` |

### テンプレートファイル

| 旧パス | 新パス |
|-------|-------|
| `tasks/spec_template.md` | `.multi-agent/templates/task/spec.md` |
| `tasks/result_template.md` | `.multi-agent/templates/task/result.md` |
| `tasks/commander_review_template.md` | `.multi-agent/templates/task/commander_review.md` |
| `tasks/observer_review_template.md` | `.multi-agent/templates/task/observer_review.md` |

### ランタイム状態ファイル

| 旧パス | 新パス |
|-------|-------|
| `BOARD.md` | `runtime/BOARD.md` |
| `CONTEXT.md` | `runtime/CONTEXT.md` |
| `DISCUSSION.md` | `runtime/DISCUSSION.md` |
| `SUMMARY.md` | `runtime/SUMMARY.md` |
| `EVENTLOG.json` | `runtime/EVENTLOG.json` |

### ドキュメントファイル

| 旧パス | 新パス |
|-------|-------|
| `README.md`（詳細版） | `.multi-agent/docs/GUIDE.md` |
| `README.md`（新規作成） | `README.md`（シンプル版） |

## 新しいディレクトリ構造

```
multi-agent/
├── README.md                        # プロジェクト概要（シンプル版）
├── .gitignore                       # 新規作成
│
├── agents/                          # エージェント定義
│   ├── commander/
│   │   └── CLAUDE.md
│   ├── observer/
│   │   └── CLAUDE.md
│   └── worker/
│       └── CLAUDE.md
│
├── config/                          # 設定・ルール
│   └── RULEBOOK.md
│
├── templates/                       # テンプレート
│   ├── task/
│   │   ├── spec.md
│   │   ├── result.md
│   │   ├── commander_review.md
│   │   └── observer_review.md
│   └── session/                     # 将来の拡張用
│
├── runtime/                         # ランタイム状態
│   ├── BOARD.md
│   ├── CONTEXT.md
│   ├── DISCUSSION.md
│   ├── SUMMARY.md
│   └── EVENTLOG.json
│
├── docs/                            # ドキュメント
│   ├── GUIDE.md                     # 詳細な使い方ガイド
│   └── MIGRATION.md                 # このファイル
│
├── tasks/                           # タスク実行結果
│   └── task-xxx/
│
├── archive/                         # アーカイブ
├── improvement/                     # 改善文書
└── skills/                          # Skills（将来追加予定）
    ├── claude-code/
    └── codex/
```

## パス参照の更新

すべてのエージェント定義ファイル（CLAUDE.md）内のパス参照を更新しました：

- `BOARD.md` → `runtime/BOARD.md`
- `CONTEXT.md` → `runtime/CONTEXT.md`
- `DISCUSSION.md` → `runtime/DISCUSSION.md`
- `SUMMARY.md` → `runtime/SUMMARY.md`
- `EVENTLOG.json` → `runtime/EVENTLOG.json`
- `RULEBOOK.md` → `.multi-agent/.multi-agent/config/RULEBOOK.md`
- `tasks/spec_template.md` → `.multi-agent/templates/task/spec.md`
- `tasks/result_template.md` → `.multi-agent/templates/task/result.md`
- `tasks/commander_review_template.md` → `.multi-agent/templates/task/commander_review.md`
- `tasks/observer_review_template.md` → `.multi-agent/templates/task/observer_review.md`

## .gitignore の追加

ランタイムファイルやタスク実行結果など、セッション固有のファイルを除外する`.gitignore`を作成しました。

### 除外対象

- `runtime/` ディレクトリ（セッション状態）
- `tasks/*/result.md` など（実行結果）
- `archive/` ディレクトリ（古いセッション）
- Python関連の一時ファイル
- IDE関連ファイル

## 移行後の作業手順

### 新規セッション開始時

1. `runtime/BOARD.md` を確認
2. `.multi-agent/roles/commander/CLAUDE.md` をシステムプロンプトとして使用
3. 必要に応じて `.multi-agent/roles/observer/CLAUDE.md` も別セッションで起動

### タスク作成時

1. `.multi-agent/templates/task/spec.md` をコピーして `tasks/task-xxx/spec.md` を作成
2. 他のテンプレートも同様に使用

## メリット

### 1. 可読性の向上
- ルートディレクトリが整理され、何がどこにあるか一目でわかる
- 役割ごとにディレクトリが分離

### 2. 保守性の向上
- エージェント定義の更新が容易
- テンプレートの管理が明確

### 3. Git管理の改善
- ランタイムファイルを自動除外
- 静的ファイルと動的ファイルを分離

### 4. スケーラビリティ
- 将来の拡張（skills/等）に対応しやすい構造
- セッションテンプレートなど追加機能の余地

## トラブルシューティング

### Q: 古いパスでファイルが見つからない

A: すべてのファイルは新しい場所に移動しています。上記の対応表を参照してください。

### Q: エージェント定義でパスエラーが出る

A: すべての CLAUDE.md ファイルは更新済みです。最新版を使用していることを確認してください。

### Q: テンプレートが見つからない

A: `tasks/` ディレクトリではなく `.multi-agent/templates/task/` ディレクトリを参照してください。

## 関連ドキュメント

- [プロジェクト概要](../README.md)
- [使い方ガイド](GUIDE.md)
- [改善計画](../improvement/IMPROVEMENT_PLAN.md)

## 履歴

- 2026-04-04: 初版作成、ファイル構成の大規模リファクタリング完了

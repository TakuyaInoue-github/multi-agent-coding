# マルチエージェント構成 改善タスク

## 背景

Commander / Observer / Worker の 3 エージェント構成を
ファイルベースで連携する仕組みを設計・初期実装した。
実際に回してみた結果、以下の課題が見つかった。

---

## 課題

### 1. Worker が Codex を使っていない

現状 Worker も Claude Code で動いている。
Codex を Worker として組み込む方法を検討・実装する必要がある。
※ Codex の挙動・制約は未検証のため、まず試すことが先決。

### 2. Python プラクティスが守られていない

仮想環境・ファイル構造等、言語標準のプラクティスに
エージェントが従えていない。
対策として以下を検討する：

- Commander が Codex 向けの Skill ファイルを管理する
- spec.md に required_skills を明示して Codex に読ませる
- Docker 等で環境を事前に固める

### 3. Claude Code の Skills が活用されていない

Commander ・ Observer が Skills 機構を使えていない。
Claude Code 向けの Skill ファイルを整備して
CLAUDE.md から参照させる設計が必要。

### 4. Markdown ファイルが散らかっている

CLAUDE_COMMANDER.md / CLAUDE_OBSERVER.md / CLAUDE_WORKER.md ・
テンプレート類・ RULEBOOK.md 等が整理されておらず
どこに何があるかわかりにくい状態になっている。

ファイル構成を整理して、エージェントが迷わず
必要なファイルを参照できる構造にする。

整理の方針：
- エージェントごとのディレクトリ分離
- テンプレートの配置場所の統一
- 参照関係を CLAUDE.md に明示する

### 5. ログ追跡ツールがない（優先度低・なくてもよい）

EVENTLOG.json を人間が追跡するツールがない。
必要性が出てきた段階で検討する。

---

## 現時点での設計方針

### Skill の体系

2 種類の Skill を分けて管理する：

```
/skills
  /claude-code    # Commander ・ Observer が読む
  /codex          # Worker（Codex）が読む・ spec.md 経由で渡す
```

### Commander の役割

- Claude Code 向け Skill を自律的に読む
- Codex の能力・制約を把握した上で spec.md を書く
- Codex 向け Skill への参照を spec.md に明示する

### spec.md への追加項目

```yaml
required_skills:
  - skills/codex/python-best-practices.md
  - skills/codex/docker-workflow.md
```

---

## 未解決事項

- Codex の実挙動・制約（未検証）
- Codex 向け Skill の有効な粒度（Codex を触るまで設計できない）

---

## 優先順位

1. Markdown ファイル構成を整理する
2. Claude Code 向け Skill 体系を整備する
3. Codex を実際に触って挙動を把握する
4. Codex 向け Skill を設計・作成する
5. ログ追跡ツールを作る（最悪不要）

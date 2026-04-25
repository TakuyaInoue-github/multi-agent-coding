# Skills 最新プラクティス調査レポート

> 調査日: 2026-04-10  
> 対象: `/mnt/skills/public/`, `/mnt/skills/examples/`

---

## 1. アーキテクチャ: Progressive Disclosure（3 層構造）

```
SKILL.md frontmatter (name + description)        ← 常にコンテキストに入る (~100 words)
SKILL.md body                                     ← スキルが発火したとき (<500 lines 推奨)
Bundled resources (scripts/, references/, assets/) ← 必要時のみロード
```

ディレクトリ構成の標準テンプレート：

```
skill-name/
├── SKILL.md              (required)
│   ├── YAML frontmatter  (name, description)
│   └── Markdown instructions
└── Bundled Resources     (optional)
    ├── scripts/          - 繰り返し実行する決定論的なコード
    ├── references/       - 必要時にコンテキストへロードするドキュメント
    └── assets/           - テンプレート・フォント・アイコン等
```

**ポイント:** 500 行を超えそうなら追加の階層と明示的なポインタを設けること。大きな reference file（300 行超）には Table of Contents を付ける。

---

## 2. Description 設計: Triggering 戦略

最も重要な変更点の一つ。

### 基本方針

- Description には「何をするか」＋「**いつ使うか**」の両方を書く
- Claude は **undertrigger（使うべき場面で使わない）** 傾向があるため、description は意図的に **pushy（積極的）** に書く

**Bad 例:**
```
How to build a simple fast dashboard to display internal data.
```

**Good 例:**
```
How to build a simple fast dashboard to display internal data.
Make sure to use this skill whenever the user mentions dashboards,
data visualization, or wants to display any kind of company data,
even if they don't explicitly ask for a 'dashboard'.
```

### Description Optimization ループ

1. **20 件の eval query を生成**（should-trigger / should-not-trigger を混在）
   - should-trigger: 同じ意図の異なる表現、informal/formal を混ぜる
   - should-not-trigger: **near-miss（似ているが違う）** が最も有効。明らかに無関係なものはテストにならない
2. ユーザーレビューで eval set を確認・修正
3. `run_loop.py` で自動最適化
   - 60/40 train/test split
   - 各 description を 3 回評価して安定した trigger rate を取得
   - 最大 5 イテレーション、**test score で best を選択**（train 過学習を防ぐ）
4. `best_description` を SKILL.md frontmatter に反映

---

## 3. スキル作成フロー（skill-creator）

```
Intent capture
  → Interview & Research（MCP やドキュメントも調査）
    → Draft SKILL.md
      → Test cases (evals/evals.json)
        → with-skill AND baseline を同時並行で実行
          → Grade（assertions 評価）
            → Eval Viewer でユーザーレビュー
              → Improve
                → Repeat（収束まで）
                  → Description Optimization
                    → Package (.skill file)
```

### 重要な原則

| 原則 | 内容 |
|------|------|
| **Why を説明する** | MUST/ALWAYS の命令型より、理由を説明する方が効果的。LLM は theory of mind を持つため |
| **Generalize from feedback** | 数例に overfit させず、汎用的なスキルを目指す |
| **Bundled scripts** | 複数テストで同じスクリプトが再生成されていたら `scripts/` に切り出す |
| **Keep prompt lean** | 機能していないルールは積極的に削除する |
| **Baseline 比較** | with-skill と without-skill（or 旧バージョン）を**同じターンに同時起動**する |

### Eval 設計のポイント

```json
{
  "skill_name": "example-skill",
  "evals": [
    {
      "id": 1,
      "prompt": "具体的なユーザータスク（ファイルパスや職種を含む現実的なもの）",
      "expected_output": "期待される結果の説明",
      "assertions": [
        {
          "text": "客観的に検証可能なアサーション",
          "type": "contains"
        }
      ]
    }
  ]
}
```

- assertion は**客観的に検証可能**なものだけに絞る
- 主観的スキル（文章スタイル、デザイン品質）は assertion ではなくユーザーレビューで評価
- シンプルすぎるプロンプト（"read this PDF"）はスキルを発火させないため、テストケースには不向き

---

## 4. MCP Builder Skill（新規）

TypeScript 優先の MCP サーバー構築ガイド。4フェーズ構成。

### 推奨スタック

| 項目 | 推奨 |
|------|------|
| 言語 | **TypeScript**（SDK サポートが充実、型安全、LLM 生成コードの品質が高い） |
| Transport（Remote） | Streamable HTTP、stateless JSON |
| Transport（Local） | stdio |

### Tool 設計のベストプラクティス

- **命名**: `service_action_target` 形式（例: `github_create_issue`）
- **Input Schema**: Zod または Pydantic、constraints + field description に example を含める
- **Output Schema**: `structuredContent` + `outputSchema` を定義する（TypeScript SDK）
- **Annotations** を必ず付ける:

```typescript
{
  readOnlyHint: true,      // データを変更しない
  destructiveHint: false,  // 破壊的操作かどうか
  idempotentHint: true,    // 冪等性
  openWorldHint: false     // 外部サービスへのアクセス
}
```

- **エラーメッセージ**: agent が次の行動を取れるよう、具体的な提案を含める

### Evaluation（フェーズ 4）

10 問の Q&A を以下の基準で作成して XML で保存：

- **Independent**: 他の質問に依存しない
- **Read-only**: 非破壊操作のみ
- **Complex**: 複数ツールコールが必要
- **Verifiable**: 文字列比較で検証可能な単一の答え
- **Stable**: 時間が経過しても答えが変わらない

---

## 5. Frontend Design Skill

デザイン品質の哲学が体系化されている。

### 設計前の必須プロセス

コードを書く前に **bold aesthetic direction** を確定する：

- **Purpose**: 誰が何のために使うか
- **Tone**: brutally minimal / maximalist / retro-futuristic / luxury / brutalist / art deco 等から 1 つ選んで徹底する
- **Differentiation**: ユーザーが記憶に残る「1点」は何か

### 明示的禁止事項

```
❌ Inter, Roboto, Arial, Space Grotesk（汎用すぎる）
❌ 紫グラデーション on 白背景（クリシェ）
❌ 予測可能なレイアウト
❌ 毎回同じデザイン
```

### 推奨アプローチ

- **Typography**: キャラクターのある display font + 洗練された body font のペア
- **Color**: CSS variables で統一、支配色 + sharp accent
- **Motion**: CSS-only を優先、page load 時の staggered reveal が効果的
- **Spatial**: 非対称・重なり・ diagonal flow で grid-breaking を狙う

---

## 6. 自分のプロジェクトへの示唆

現在の Claude Code skills 構成（CLAUDE.md / RULEBOOK.md / カスタムスキル）との対比：

| 観点 | 現状の課題 | 最新プラクティスに基づく改善案 |
|------|------------|-------------------------------|
| **Description** | triggering 戦略が未整備 | pushy 寄りに書き直し + eval query で最適化 |
| **スキルサイズ** | CLAUDE.md が肥大化しがち | 500 行上限 + `references/` で階層化 |
| **命令スタイル** | MUST/ALWAYS 多め | Why を説明する形式に書き直す |
| **共通処理** | タスクごとにスクリプトを再生成 | `scripts/` に切り出して bundle |
| **評価** | 定性的なチェックのみ | evals.json + assertion で定量評価を導入 |

### 具体的にやること候補

1. `code-review` / `code-reading` スキルの description を eval query で最適化する
2. Hareruya MCP サーバーの Tool annotations（`readOnlyHint` 等）を追加する
3. JVLink / MTGO pipeline などの共通処理スクリプトを skill 内 `scripts/` に bundle する
4. skill-creator のテストフロー（with-skill vs baseline 同時並行）をローカルで試す

---

*調査対象ディレクトリ: `/mnt/skills/public/`, `/mnt/skills/examples/skill-creator/`, `/mnt/skills/examples/mcp-builder/`*

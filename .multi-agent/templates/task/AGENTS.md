# AGENTS.md - task-xxx

このファイルはこのタスク固有の設定です。プロジェクトルートの `AGENTS.md` より優先されます。

---

## このタスクの概要

**タスクID**: task-xxx
**言語**: Python | TypeScript | Go | Java
**worker_type**: coding | testing | debugging

---

## 作業ブランチ

```
task/task-xxx
```

このブランチ以外への操作は禁止。

---

## 成果物リスト（output_artifacts）

実装完了時に以下がすべて存在していること：

- `path/to/output1`
- `path/to/output2`

---

## 品質チェック（このタスク用）

実装後に以下をすべて実行し、全通過を確認してからコミットすること。

```bash
# [言語に応じたチェックコマンドをここに記載]
# 例 (Python):
ruff format --check src/
ruff check src/
pytest tests/  # worker_type: testing の場合のみ
```

**成功基準**:
- [ ] 上記コマンドがすべてエラー・警告なしで通過する
- [ ] output_artifacts のファイルがすべて存在する

---

## 制約・注意事項

### 書き込み可能なパス

- `path/to/allowed/`

### 実行可能なコマンド

- `build`, `lint`, `format`, `test`

### 禁止事項

- パッケージの新規インストール
- `runtime/` への書き込み
- ネットワークアクセス（`curl`, `wget` 等）

---

## 前タスクからの申し送り

（前タスクの result.md より転記）

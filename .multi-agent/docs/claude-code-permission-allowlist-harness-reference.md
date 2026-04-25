# Claude Code 権限・許可リスト設計リファレンス

## 目的

このドキュメントは、Claude Code を開発業務で安全に使うための **ハーネスエンジニアリング** のリファレンスである。ここでいうハーネスとは、LLM エージェントに自由に作業させるための「安全柵」「実行境界」「監査可能な入口」を指す。

Claude Code の permissions は便利だが、それだけで安全を完結させるものではない。実務では、以下を組み合わせて設計する。

1. `permissions.allow / ask / deny`
2. `defaultMode`
3. hooks
4. sandbox
5. Git worktree / container / CI
6. チーム運用ルール

設計目標は次の3つである。

- **安全性**: 秘密情報、本番環境、Git履歴、開発者端末を守る。
- **自走性**: lint、test、format、build など反復的な作業は止めない。
- **監査性**: なぜ許可したか、何を拒否したか、いつ変更したかを追える。

---

## 1. Claude Code の permission model

Claude Code は読み取り、Bash、ファイル編集などのツールに対して権限管理を行う。

公式ドキュメント上、Claude Code の permission rule は以下の順序で評価される。

```text
deny -> ask -> allow
```

最初に一致したルールが採用されるため、`deny` は常に `allow` より優先される。

### 基本分類

| 区分 | 役割 | 例 |
|---|---|---|
| `allow` | 自動実行してよい操作 | `Bash(npm run test)` |
| `ask` | 毎回確認したい操作 | `Bash(git commit *)` |
| `deny` | 常に禁止する操作 | `Bash(git push *)`, `Read(./.env)` |

### 設計上の重要ポイント

- `allow` は「便利なコマンド」ではなく「安全な作業単位」を許可する。
- `deny` は「事故が起きたら困る操作」を明示的に禁止する。
- `ask` は「必要なことはあるが、文脈確認が必要な操作」に使う。
- `deny` は `allow` より優先されるため、まず denylist を設計する。

---

## 2. ハーネス設計の基本思想

Claude Code の許可リストは、次のように考えると設計しやすい。

```text
Claude Code に何をさせるか
ではなく
Claude Code が安全に失敗できる範囲はどこか
```

許可すべき操作は、以下の条件を満たすものに限定する。

- 状態変更が小さい。
- 結果を Git diff で確認できる。
- 外部ネットワークに勝手に出ない。
- 本番・共有環境・秘密情報に触れない。
- 失敗してもローカル作業ツリーを戻せばよい。
- 実行対象が明確で、ワイルドカードが広すぎない。

逆に、以下の操作は `allow` に入れない。

- 任意コード実行に近いもの。
- 外部通信を伴うもの。
- 認証情報を読む可能性があるもの。
- Git のリモート状態を変えるもの。
- 本番環境やクラウドリソースを変更するもの。
- 依存関係・lockfile・DB・インフラ状態を変えるもの。

---

## 3. permissions の推奨レイヤー

### 3.1 denylist: 最初に設計する

まず、何があっても実行させない操作を定義する。

```json
{
  "permissions": {
    "deny": [
      "Bash(git push)",
      "Bash(git push *)",
      "Bash(rm -rf *)",
      "Bash(curl *)",
      "Bash(wget *)",
      "Bash(ssh *)",
      "Bash(scp *)",
      "Bash(rsync *)",
      "Bash(kubectl *)",
      "Bash(terraform apply *)",
      "Bash(terraform destroy *)",
      "Bash(aws *)",
      "Bash(gcloud *)",
      "Bash(az *)",
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)",
      "Edit(./.env)",
      "Edit(./.env.*)",
      "Edit(./secrets/**)"
    ]
  }
}
```

#### deny に入れたい典型カテゴリ

| カテゴリ | 例 | 理由 |
|---|---|---|
| Git リモート操作 | `git push`, `git push --force` | リモート履歴や共有ブランチを破壊し得る |
| 破壊的削除 | `rm -rf`, `find ... -delete` | ローカル資産を破壊し得る |
| ネットワーク | `curl`, `wget`, `ssh`, `scp` | 秘密情報流出や外部コード取得の経路になる |
| クラウド CLI | `aws`, `gcloud`, `az` | 本番・共有リソース変更の可能性 |
| IaC | `terraform apply`, `destroy` | インフラ状態変更 |
| Kubernetes | `kubectl` | クラスタ状態変更、本番影響 |
| 秘密ファイル | `.env`, `secrets/**` | 認証情報漏えい防止 |

### 3.2 asklist: 文脈依存の操作

安全な場合もあるが、毎回確認したい操作を `ask` に入れる。

```json
{
  "permissions": {
    "ask": [
      "Bash(git commit *)",
      "Bash(npm install *)",
      "Bash(pnpm install *)",
      "Bash(yarn add *)",
      "Bash(uv add *)",
      "Bash(uv remove *)",
      "Bash(pip install *)",
      "Bash(docker compose *)",
      "Bash(make *)"
    ]
  }
}
```

#### ask に置く判断基準

- 作業に必要な場合はある。
- ただし、変更範囲が大きい。
- 実行内容がプロジェクトごとに違う。
- 実行前に人間が目的を確認したい。

例として、`make test` は安全でも、`make deploy` や `make clean` が同じ `make *` に含まれるなら `make *` を allow すべきではない。

### 3.3 allowlist: 安全な作業単位だけ

自動実行を許すのは、検査・整形・ビルド・ローカルテストなどに絞る。

```json
{
  "permissions": {
    "allow": [
      "Bash(git status)",
      "Bash(git diff)",
      "Bash(git diff *)",
      "Bash(git log *)",
      "Bash(npm run lint)",
      "Bash(npm run test)",
      "Bash(npm run test *)",
      "Bash(npm run build)",
      "Bash(pytest)",
      "Bash(pytest *)",
      "Bash(ruff check *)",
      "Bash(ruff format *)",
      "Bash(mypy *)",
      "Bash(* --version)",
      "Bash(* --help *)"
    ]
  }
}
```

#### allow に入れてよい候補

| 操作 | 条件 |
|---|---|
| `npm run lint` | package script の中身が安全であることを確認済み |
| `npm run test` | ローカルテストのみ、本番DBや外部APIに接続しない |
| `pytest *` | テストが外部副作用を持たない |
| `ruff check *` | 静的解析のみ |
| `ruff format *` | Git diff で確認可能な整形のみ |
| `mypy *` | 静的解析のみ |
| `git diff *` | 読み取り操作 |

---

## 4. 危険な allow pattern

次のようなルールは避ける。

```json
{
  "permissions": {
    "allow": [
      "Bash(*)",
      "Bash(npm *)",
      "Bash(node *)",
      "Bash(python *)",
      "Bash(bash *)",
      "Bash(sh *)",
      "Bash(git *)",
      "Bash(docker *)",
      "Bash(make *)"
    ]
  }
}
```

### なぜ危険か

| パターン | 問題 |
|---|---|
| `Bash(*)` | 実質的に権限管理を無効化する |
| `Bash(python *)` | 任意コード実行が可能 |
| `Bash(node *)` | 任意 JavaScript 実行が可能 |
| `Bash(npm *)` | install, exec, publish などを含む |
| `Bash(git *)` | push, reset, clean, branch delete を含む |
| `Bash(make *)` | Makefile の中身次第で何でも起きる |
| `Bash(docker *)` | ホストマウントやネットワーク経由の危険がある |

### 原則

コマンド名ではなく、**作業目的**に対して許可する。

悪い例:

```json
"Bash(npm *)"
```

良い例:

```json
"Bash(npm run lint)",
"Bash(npm run test)",
"Bash(npm run build)"
```

---

## 5. defaultMode の選び方

Claude Code の `defaultMode` は、セッション開始時の権限挙動を決める。

| mode | 用途 |
|---|---|
| `default` | 標準。初回実行時に確認する |
| `acceptEdits` | 編集は受け入れやすくしつつ、Bash は慎重に扱う |
| `plan` | 読み取り・計画だけ。調査やレビュー向け |
| `auto` | 背景の安全チェックで自動承認を増やす。研究プレビュー扱い |
| `dontAsk` | allow 済み以外は自動拒否。厳格な運用向け |
| `bypassPermissions` | 権限プロンプトをスキップ。隔離環境以外では非推奨 |

### 推奨

#### 個人開発

```json
{
  "permissions": {
    "defaultMode": "default"
  }
}
```

#### チーム共有リポジトリ

```json
{
  "permissions": {
    "defaultMode": "dontAsk"
  }
}
```

#### 調査・レビュー専用

```json
{
  "permissions": {
    "defaultMode": "plan"
  }
}
```

#### 管理ポリシー

```json
{
  "permissions": {
    "disableBypassPermissionsMode": "disable"
  }
}
```

`bypassPermissions` は、コンテナ、VM、sandbox、使い捨て worktree のように、Claude Code が損害を出しにくい環境でのみ使う。

---

## 6. WebFetch とネットワーク制御

Bash の `curl` や `wget` を許可して URL を縛るのは避ける。

悪い例:

```json
{
  "permissions": {
    "allow": [
      "Bash(curl https://github.com/*)"
    ]
  }
}
```

問題点:

- オプション順で回避され得る。
- リダイレクトを経由できる。
- shell 展開や環境変数が絡む。
- URL の解釈が人間の想定とずれる。

代わりに、WebFetch のドメイン allow を使う。

```json
{
  "permissions": {
    "allow": [
      "WebFetch(domain:docs.anthropic.com)",
      "WebFetch(domain:github.com)",
      "WebFetch(domain:docs.python.org)"
    ],
    "deny": [
      "Bash(curl *)",
      "Bash(wget *)",
      "Bash(http *)",
      "Bash(https *)"
    ]
  }
}
```

ただし、WebFetch を制御しても Bash が広く許可されていれば別経路で通信できる。ネットワークを本当に制御したい場合は sandbox の network 制御と併用する。

---

## 7. sandbox を併用する

permissions は Claude Code のツールレベル制御であり、OS レベルの隔離ではない。

安全なハーネスを作るには、sandbox を併用する。

```json
{
  "sandbox": {
    "enabled": true,
    "failIfUnavailable": true,
    "autoAllowBashIfSandboxed": true,
    "allowUnsandboxedCommands": false,
    "filesystem": {
      "allowRead": ["."],
      "allowWrite": [".", "/tmp/claude-build"],
      "denyRead": ["~/.ssh", "~/.aws", "~/.config", "./.env", "./secrets"],
      "denyWrite": ["/", "/etc", "/usr", "~"]
    },
    "network": {
      "allowedDomains": [
        "github.com",
        "registry.npmjs.org",
        "pypi.org",
        "files.pythonhosted.org"
      ]
    }
  }
}
```

### sandbox の設計原則

- 書き込み可能パスは作業ディレクトリと一時ディレクトリに限定する。
- 読み取り可能パスも必要最小限にする。
- `~/.ssh`, `~/.aws`, `~/.kube`, `~/.config` は原則 denyRead。
- ネットワークは許可ドメイン方式にする。
- sandbox が起動できない場合は fail closed にする。
- `allowUnsandboxedCommands` は原則 false にする。

### Docker / kubectl / terraform の扱い

Docker、kubectl、terraform は sandbox と相性が悪い、または副作用が大きいことがある。

推奨は以下。

| コマンド | 推奨扱い |
|---|---|
| `docker build` | ask。必要なら専用 script を用意 |
| `docker compose up` | ask または deny |
| `kubectl *` | 原則 deny |
| `terraform plan` | ask |
| `terraform apply` | deny |
| `terraform destroy` | deny |

---

## 8. hooks で deterministic control を追加する

permissions はパターンマッチであり、複雑な判断には限界がある。

以下のような判断は hooks に寄せる。

- `.env` や `secrets/**` の編集禁止
- `package-lock.json` や `uv.lock` の変更時に確認を強制
- `git push` や `terraform apply` の二重ブロック
- 設定ファイル `.claude/settings.json` の変更監査
- Bash コマンドに危険トークンが含まれていないか検査

### 8.1 PreToolUse hook: 実行前ブロック

`.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/validate-bash.sh"
          }
        ]
      },
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/protect-files.sh"
          }
        ]
      }
    ]
  }
}
```

`.claude/hooks/validate-bash.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

input="$(cat)"
command="$(printf '%s' "$input" | jq -r '.tool_input.command // ""')"

# Always block highly risky commands.
case "$command" in
  *"git push"*|*"rm -rf"*|*"terraform apply"*|*"terraform destroy"*|*"kubectl"*|*"aws "*|*"gcloud "*|*"az "*)
    echo "Blocked by validate-bash.sh: risky command: $command" >&2
    exit 2
    ;;
esac

# Block network exfiltration paths via shell.
case "$command" in
  *"curl "*|*"wget "*|*"nc "*|*"netcat "*|*"ssh "*|*"scp "*|*"rsync "*)
    echo "Blocked by validate-bash.sh: network-capable command: $command" >&2
    exit 2
    ;;
esac

exit 0
```

`.claude/hooks/protect-files.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

input="$(cat)"
path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // ""')"

case "$path" in
  *.env|*.env.*|*/.env|*/.env.*|secrets/*|*/secrets/*)
    echo "Blocked: protected secret-like file: $path" >&2
    exit 2
    ;;
  .git/*|*/.git/*)
    echo "Blocked: direct .git modification: $path" >&2
    exit 2
    ;;
  .claude/settings.json|*/.claude/settings.json)
    echo "Blocked: settings change requires manual review: $path" >&2
    exit 2
    ;;
esac

exit 0
```

### 8.2 PostToolUse hook: 整形・検査

編集後に自動整形する。

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/post-edit-format.sh"
          }
        ]
      }
    ]
  }
}
```

```bash
#!/usr/bin/env bash
set -euo pipefail

input="$(cat)"
path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // ""')"

case "$path" in
  *.py)
    ruff format "$path"
    ruff check --fix "$path" || true
    ;;
  *.ts|*.tsx|*.js|*.jsx|*.json|*.md)
    npx prettier --write "$path" || true
    ;;
esac
```

### 8.3 ConfigChange hook: 設定変更監査

`.claude/settings.json` や関連設定が変わったときは監査ログを残す。

```json
{
  "hooks": {
    "ConfigChange": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/audit-config-change.sh"
          }
        ]
      }
    ]
  }
}
```

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$CLAUDE_PROJECT_DIR/.claude/audit"
cat >> "$CLAUDE_PROJECT_DIR/.claude/audit/config-change.log"
echo "--- $(date -Iseconds) ---" >> "$CLAUDE_PROJECT_DIR/.claude/audit/config-change.log"
```

---

## 9. settings scope の使い分け

Claude Code の設定は複数スコープで管理される。チーム運用では、どの設定をどこに置くかが重要である。

| スコープ | 用途 | Git 管理 |
|---|---|---|
| Managed settings | 組織強制ポリシー | 管理者管理 |
| User `~/.claude/settings.json` | 個人共通設定 | しない |
| Project `.claude/settings.json` | チーム共有設定 | する |
| Local `.claude/settings.local.json` | 個人・端末固有設定 | しない |

### 推奨配置

#### Managed settings

- `disableBypassPermissionsMode`
- `disableAutoMode` または auto mode の制約
- `allowManagedPermissionRulesOnly`
- MCP server allowlist / denylist
- HTTP hooks allowlist
- sandbox 強制
- managed hooks 強制

#### Project settings

- リポジトリ固有の `allow / ask / deny`
- lint/test/build コマンド
- hooks
- sandbox のプロジェクト固有 allowWrite

#### Local settings

- 個人環境のパス
- 個人だけが使う追加ツール
- 実験的な allow

---

## 10. チーム共有テンプレート

`.claude/settings.json`:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "defaultMode": "dontAsk",
    "allow": [
      "Bash(git status)",
      "Bash(git diff)",
      "Bash(git diff *)",
      "Bash(git log *)",
      "Bash(npm run lint)",
      "Bash(npm run test)",
      "Bash(npm run test *)",
      "Bash(npm run build)",
      "Bash(pytest)",
      "Bash(pytest *)",
      "Bash(ruff check *)",
      "Bash(ruff format *)",
      "Bash(mypy *)",
      "WebFetch(domain:docs.anthropic.com)",
      "WebFetch(domain:github.com)",
      "WebFetch(domain:docs.python.org)"
    ],
    "ask": [
      "Bash(git commit *)",
      "Bash(npm install *)",
      "Bash(pnpm install *)",
      "Bash(yarn add *)",
      "Bash(uv add *)",
      "Bash(uv remove *)",
      "Bash(pip install *)",
      "Bash(docker compose *)",
      "Bash(make *)"
    ],
    "deny": [
      "Bash(git push)",
      "Bash(git push *)",
      "Bash(rm -rf *)",
      "Bash(curl *)",
      "Bash(wget *)",
      "Bash(ssh *)",
      "Bash(scp *)",
      "Bash(rsync *)",
      "Bash(kubectl *)",
      "Bash(terraform apply *)",
      "Bash(terraform destroy *)",
      "Bash(aws *)",
      "Bash(gcloud *)",
      "Bash(az *)",
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)",
      "Edit(./.env)",
      "Edit(./.env.*)",
      "Edit(./secrets/**)"
    ]
  },
  "sandbox": {
    "enabled": true,
    "failIfUnavailable": true,
    "autoAllowBashIfSandboxed": true,
    "allowUnsandboxedCommands": false,
    "filesystem": {
      "allowRead": ["."],
      "allowWrite": [".", "/tmp/claude-build"],
      "denyRead": ["~/.ssh", "~/.aws", "~/.kube", "~/.config", "./.env", "./secrets"],
      "denyWrite": ["/", "/etc", "/usr", "~"]
    }
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/validate-bash.sh"
          }
        ]
      },
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/protect-files.sh"
          }
        ]
      }
    ],
    "ConfigChange": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/audit-config-change.sh"
          }
        ]
      }
    ]
  }
}
```

---

## 11. 安全な入口コマンドを設計する

許可リストをシンプルにするには、Claude Code に直接いろいろなコマンドを叩かせるのではなく、チーム側で安全な入口を作る。

例: `Makefile`

```makefile
.PHONY: check lint test typecheck format build

check: lint typecheck test

lint:
	uv run ruff check .

typecheck:
	uv run mypy src

test:
	uv run pytest

format:
	uv run ruff format .

build:
	uv build
```

permissions はこうできる。

```json
{
  "permissions": {
    "allow": [
      "Bash(make check)",
      "Bash(make lint)",
      "Bash(make test)",
      "Bash(make typecheck)",
      "Bash(make format)",
      "Bash(make build)"
    ],
    "deny": [
      "Bash(make deploy)",
      "Bash(make release)",
      "Bash(make clean-all)"
    ]
  }
}
```

この方針の利点:

- Claude Code の permissions が簡潔になる。
- 人間も同じ入口を使える。
- CI と揃えやすい。
- 危険な操作を Makefile 側から分離できる。

---

## 12. 許可リストの棚卸しプロセス

### 初期導入

1. `defaultMode: dontAsk` で始める。
2. lint/test/build だけ allow する。
3. git push / secrets / network / cloud / IaC を deny する。
4. npm install / git commit / docker / make は ask に置く。
5. hooks で Bash とファイル編集を二重検査する。
6. sandbox を有効にする。

### 週次・スプリントごとの棚卸し

Claude Code が要求した permission prompt を以下に分類する。

| 分類 | 対応 |
|---|---|
| 毎回安全で、頻繁に必要 | allow へ昇格 |
| 文脈依存 | ask に維持 |
| 不要または危険 | deny へ追加 |
| 判定不能 | hook で詳細検査 |
| コマンドが広すぎる | 安全な wrapper を作る |

### レビュー観点

- `allow` に任意コード実行系が入っていないか。
- `allow` に外部通信系が入っていないか。
- `deny` が secrets と本番操作を覆っているか。
- `ask` が肥大化し、承認疲れを起こしていないか。
- hooks が実行可能権限を持っているか。
- sandbox が本当に起動しているか。
- `.claude/settings.local.json` に危険な個人許可が溜まっていないか。

---

## 13. 脅威モデル

### 13.1 Prompt injection

リポジトリ内のファイル、README、issue、WebFetch 結果、テスト出力などに、Claude Code の挙動を乗っ取る指示が含まれる可能性がある。

対策:

- 外部取得は WebFetch allowlist に限定する。
- Bash の curl/wget を deny する。
- secrets を sandbox の denyRead に入れる。
- `.env` 読み取りを deny する。
- 本番操作を deny する。

### 13.2 Secret exfiltration

Claude が意図せず秘密情報を読み、外部に送信する可能性。

対策:

- `.env`, `~/.ssh`, `~/.aws`, `~/.kube` を denyRead。
- Bash のネットワークコマンドを deny。
- sandbox network allowlist を使う。
- CI / local で secrets をファイルに置かない。

### 13.3 Destructive local changes

`rm -rf`, `git clean`, `git reset --hard` などで作業ツリーが破壊される可能性。

対策:

- 破壊的コマンドを deny。
- worktree を使う。
- 作業前に `git status` を確認する。
- pre-commit / CI でチェックする。

### 13.4 Production impact

クラウド CLI、kubectl、terraform により本番リソースを変更する可能性。

対策:

- `aws`, `gcloud`, `az`, `kubectl`, `terraform apply`, `terraform destroy` を deny。
- 本番資格情報をローカルに置かない。
- plan は ask、apply は人間のみ。

---

## 14. ロール別プリセット

### 14.1 Reviewer mode

コードレビュー・調査専用。

```json
{
  "permissions": {
    "defaultMode": "plan",
    "allow": [
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash(git log *)"
    ],
    "deny": [
      "Bash(*)",
      "Edit(*)",
      "Write(*)"
    ]
  }
}
```

### 14.2 Safe contributor mode

通常の開発用。

```json
{
  "permissions": {
    "defaultMode": "dontAsk",
    "allow": [
      "Bash(make check)",
      "Bash(make lint)",
      "Bash(make test)",
      "Bash(make format)",
      "Bash(git diff *)",
      "Bash(git status)"
    ],
    "ask": [
      "Bash(git commit *)",
      "Bash(npm install *)",
      "Bash(uv add *)"
    ],
    "deny": [
      "Bash(git push *)",
      "Bash(curl *)",
      "Bash(wget *)",
      "Bash(kubectl *)",
      "Bash(terraform apply *)",
      "Read(./.env*)",
      "Read(./secrets/**)"
    ]
  }
}
```

### 14.3 CI-like agent mode

CI と同じ入口だけ許可する。

```json
{
  "permissions": {
    "defaultMode": "dontAsk",
    "allow": [
      "Bash(make ci)"
    ],
    "deny": [
      "Bash(*)"
    ]
  }
}
```

注意: この例では `deny: Bash(*)` が `allow` より優先されるため、実際には `make ci` も拒否される。Claude Code の評価順では deny が最優先である。CI-like にしたい場合は `deny: Bash(*)` を使わず、`defaultMode: dontAsk` と限定 allow にする。

正しい例:

```json
{
  "permissions": {
    "defaultMode": "dontAsk",
    "allow": [
      "Bash(make ci)"
    ],
    "deny": [
      "Bash(git push *)",
      "Bash(curl *)",
      "Bash(wget *)",
      "Bash(ssh *)"
    ]
  }
}
```

---

## 15. 導入チェックリスト

### 初期設定

- [ ] `.claude/settings.json` を作成した。
- [ ] `defaultMode` を決めた。
- [ ] denylist を先に定義した。
- [ ] allowlist は lint/test/build/format に限定した。
- [ ] asklist に依存関係変更・commit・docker・make を置いた。
- [ ] `.env` と `secrets/**` を Read/Edit deny に入れた。
- [ ] `curl`, `wget`, `ssh`, `scp` を deny した。
- [ ] `git push`, `terraform apply`, `kubectl`, cloud CLI を deny した。

### sandbox

- [ ] sandbox を有効化した。
- [ ] sandbox が使えない場合に fail closed する。
- [ ] 読み取り可能パスを限定した。
- [ ] 書き込み可能パスを限定した。
- [ ] `~/.ssh`, `~/.aws`, `~/.kube` を denyRead した。
- [ ] network allowlist を決めた。
- [ ] unsandboxed escape hatch を制限した。

### hooks

- [ ] `PreToolUse` で Bash を検査している。
- [ ] `PreToolUse` で secret-like file 編集をブロックしている。
- [ ] `ConfigChange` を監査している。
- [ ] hooks scripts に実行権限がある。
- [ ] hooks の失敗時挙動を確認した。

### 運用

- [ ] permission prompt を棚卸しする周期を決めた。
- [ ] allow 追加はレビュー対象にした。
- [ ] settings 変更は PR レビュー対象にした。
- [ ] `.claude/settings.local.json` は Git 管理外にした。
- [ ] bypassPermissions を禁止または隔離環境限定にした。
- [ ] CI とローカルの入口コマンドを揃えた。

---

## 16. 推奨リポジトリ構成

```text
repo/
  .claude/
    settings.json
    hooks/
      validate-bash.sh
      protect-files.sh
      post-edit-format.sh
      audit-config-change.sh
    audit/
      .gitkeep
  CLAUDE.md
  Makefile
  package.json
  pyproject.toml
```

`CLAUDE.md` には、Claude Code に守らせたい高レベルルールを書く。

例:

```markdown
# Claude Code Instructions

- Do not read or modify `.env`, `.env.*`, or files under `secrets/`.
- Do not run production, cloud, Kubernetes, or Terraform apply commands.
- Use `make check` before proposing final changes.
- Prefer small diffs.
- Do not add dependencies without explicit user approval.
- Do not push commits or create tags.
```

ただし、`CLAUDE.md` はあくまで指示であり、強制力は permissions / hooks / sandbox に持たせる。

---

## 17. まとめ

Claude Code の許可リスト整備は、単なる便利設定ではなく、エージェントに作業を委任するための安全設計である。

重要な順序は以下。

1. denylist で絶対禁止を決める。
2. allowlist は安全な作業単位に絞る。
3. asklist は文脈依存の操作に使う。
4. Bash の広すぎる許可を避ける。
5. WebFetch と sandbox でネットワークを制御する。
6. hooks で deterministic な追加検査を行う。
7. settings scope を分けて、チーム共有と個人設定を混ぜない。
8. permission prompt を棚卸しし、継続的に育てる。

最終的に目指すべき形は、Claude Code に「何でもできる力」を与えることではなく、**安全な枠の中で、テスト・検査・修正・確認を高速に回せる環境**を作ることである。

---

## References

- Claude Code Docs: Configure permissions  
  https://code.claude.com/docs/en/permissions
- Claude Code Docs: Settings  
  https://code.claude.com/docs/en/settings
- Claude Code Docs: Automate workflows with hooks  
  https://code.claude.com/docs/en/hooks-guide
- Claude Code Docs: Hooks reference  
  https://code.claude.com/docs/en/hooks
- Claude Code Docs: Sandboxing  
  https://code.claude.com/docs/en/sandboxing
- Anthropic Engineering: Beyond permission prompts: making Claude Code more secure and autonomous  
  https://www.anthropic.com/engineering/claude-code-sandboxing
- Anthropic Engineering: Claude Code auto mode: a safer way to skip permissions  
  https://www.anthropic.com/engineering/claude-code-auto-mode

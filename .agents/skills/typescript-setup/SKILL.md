---
name: typescript-setup
description: |
  Set up a TypeScript project environment. Invoke automatically when starting a new TypeScript
  project or when the environment is not yet configured.
  Triggers: "setup TypeScript project", "initialize TypeScript", "create TS environment",
  missing package.json or tsconfig.json, first task in a TypeScript project.
  Sets up: npm/pnpm, tsconfig with strict mode, prettier, eslint, vitest.
disable-model-invocation: false
user-invocable: true
allowed-tools: [editor, bash]
---

# TypeScript セットアップ Skill

Commander が TypeScript プロジェクトの初期セットアップタスクを生成するために使用します。

## 使用方法

```bash
/typescript-setup "npm" "vitest"
/typescript-setup "$PACKAGE_MANAGER" "$TEST_FRAMEWORK"
```

## 引数

- `$0` = パッケージマネージャー（npm | yarn | pnpm、デフォルト: npm）
- `$1` = テストフレームワーク（jest | vitest、デフォルト: vitest）

## 生成されるタスク仕様

このスキルは `tasks/task-setup-typescript/spec.md` を生成します。

### タスク内容

1. **package.json の作成**
   ```bash
   npm init -y
   ```

2. **TypeScript と開発ツールのインストール**
   ```bash
   npm install -D typescript @types/node
   npm install -D prettier eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin
   npm install -D vitest @vitest/ui  # または jest
   ```

3. **tsconfig.json の作成**
   ```json
   {
     "compilerOptions": {
       "target": "ES2022",
       "module": "ESNext",
       "moduleResolution": "bundler",
       "strict": true,
       "esModuleInterop": true,
       "skipLibCheck": true,
       "forceConsistentCasingInFileNames": true,
       "resolveJsonModule": true,
       "outDir": "./dist",
       "rootDir": "./src"
     },
     "include": ["src/**/*"],
     "exclude": ["node_modules", "dist"]
   }
   ```

4. **.prettierrc の作成**
   ```json
   {
     "semi": true,
     "trailingComma": "es5",
     "singleQuote": true,
     "printWidth": 100,
     "tabWidth": 2
   }
   ```

5. **.eslintrc.json の作成**
   ```json
   {
     "parser": "@typescript-eslint/parser",
     "extends": [
       "eslint:recommended",
       "plugin:@typescript-eslint/recommended",
       "prettier"
     ],
     "plugins": ["@typescript-eslint"],
     "rules": {
       "@typescript-eslint/no-explicit-any": "error",
       "@typescript-eslint/explicit-function-return-type": "warn"
     }
   }
   ```

6. **package.json スクリプトの追加**
   ```json
   {
     "scripts": {
       "dev": "vite",
       "build": "tsc && vite build",
       "test": "vitest run",
       "test:watch": "vitest",
       "lint": "eslint src/",
       "format": "prettier --write src/",
       "type-check": "tsc --noEmit"
     }
   }
   ```

7. **ディレクトリ構造の作成**
   ```
   src/
   ├── index.ts
   └── __tests__/
       └── index.test.ts
   ```

8. **.gitignore の作成**（Node.js/TypeScript 用）
   ```
   node_modules/
   dist/
   .env
   .env.local
   *.log
   .DS_Store
   coverage/
   .vite/
   ```

## 出力

### spec.md の構造

```yaml
---
task_id: task-setup-typescript
worker_type: coding
depends_on: []
parallel_ok: false
input_artifacts: []
output_artifacts:
  - package.json
  - package-lock.json  # or yarn.lock, pnpm-lock.yaml
  - tsconfig.json
  - .prettierrc
  - .eslintrc.json
  - src/index.ts
  - src/__tests__/index.test.ts
  - .gitignore
permissions:
  filesystem:
    write: [., src/, src/__tests__/]
  execution:
    allowed: [npm, npx, node]  # or yarn, pnpm
required_packages: []
environment_verified: true
commander_reasoning: |
  TypeScript プロジェクトの初期セットアップタスク。
  TypeScript, ESLint, Prettier, テストフレームワークの設定を含む。
---

## 指示内容

TypeScript プロジェクトの初期セットアップを行う（パッケージマネージャー: {{package_manager}}, テストフレームワーク: {{test_framework}}）。

1. `package.json` を作成する（`{{package_manager}} init -y`）
2. TypeScript と開発ツールをインストールする
   - typescript, @types/node
   - prettier, eslint, @typescript-eslint/parser, @typescript-eslint/eslint-plugin
   - {{test_framework}}, @{{test_framework}}/ui
3. `tsconfig.json` を作成する（strict モード有効）
4. `.prettierrc` を作成する
5. `.eslintrc.json` を作成する（TypeScript 対応）
6. `package.json` にスクリプトを追加する（dev, build, test, lint, format, type-check）
7. ディレクトリ構造を作成する（`src/`, `src/__tests__/`）
8. `.gitignore` を作成する（Node.js/TypeScript 用）

## 期待する成果物

- `package.json` が存在し、スクリプトが定義されている
- `tsconfig.json` が存在し、`strict: true` が設定されている
- `.prettierrc` と `.eslintrc.json` が存在する
- `src/index.ts` と `src/__tests__/index.test.ts` が存在する
- `.gitignore` が存在し、`node_modules/`, `dist/` が含まれている

## 成功基準

- [ ] `{{package_manager}} install` が実行できる
- [ ] `npx tsc --noEmit` で型チェックが通る
- [ ] `npx prettier --check src/` が通る
- [ ] `npx eslint src/` が通る
- [ ] `package.json` に `scripts` セクションが存在する
- [ ] `tsconfig.json` に `"strict": true` が含まれている

## 注意事項

- パッケージマネージャーによってロックファイル名が異なる
  - npm: `package-lock.json`
  - yarn: `yarn.lock`
  - pnpm: `pnpm-lock.yaml`
- テストフレームワークの設定ファイルも必要に応じて作成する
  - vitest: `vitest.config.ts`
  - jest: `jest.config.js`
```

## 関連ファイル

- `.multi-agent/config/languages/typescript.md` - TypeScript プロジェクトガイドライン
- `.multi-agent/templates/task/spec.md` - タスク仕様テンプレート

## 使用例

### npm + Vitest (推奨)

```bash
/typescript-setup "npm" "vitest"
```

### yarn + Jest

```bash
/typescript-setup "yarn" "jest"
```

### pnpm + Vitest

```bash
/typescript-setup "pnpm" "vitest"
```

## 次のステップ

セットアップタスク完了後、以下のタスクを続けて作成することを推奨：

1. **依存関係インストールタスク**
   ```bash
   npm install  # or yarn, pnpm
   ```

2. **品質チェック設定の検証タスク**
   ```bash
   npm run type-check
   npm run lint
   npm run format
   npm test
   ```

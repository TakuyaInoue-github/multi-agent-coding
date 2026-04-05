# TypeScript プロジェクトガイドライン

このドキュメントは Commander と Observer が TypeScript プロジェクトでタスクを分解・評価する際に参照します。

---

## 環境管理

### パッケージマネージャー

**選択肢**: `npm`, `yarn`, `pnpm`

```bash
# npm (Node.js 標準)
npm install

# yarn (高速・信頼性重視)
yarn install

# pnpm (ディスク効率重視)
pnpm install
```

**推奨**: プロジェクトに既存のロックファイルがあればそれに従う
- `package-lock.json` → npm
- `yarn.lock` → yarn
- `pnpm-lock.yaml` → pnpm

### 依存関係管理

**ファイル**:
- `package.json`: 依存関係・スクリプト定義
- `package-lock.json` / `yarn.lock` / `pnpm-lock.yaml`: 依存関係ロックファイル

**タスク分解時の注意**:
- パッケージ追加タスクは独立させる
- `package.json` の更新は output_artifacts に明記
- ロックファイルも output_artifacts に含める

---

## TypeScript 設定

### tsconfig.json

**推奨設定**:
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "lib": ["ES2022"],
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

**重要なフラグ**:
- `strict: true` - 厳格な型チェック（必須）
- `noImplicitAny: true` - 暗黙の any 型を禁止
- `strictNullChecks: true` - null/undefined の厳密チェック

---

## コード品質

### フォーマッター

**推奨**: `prettier` (業界標準)

```bash
npx prettier --write src/
npx prettier --check src/  # CI での確認
```

**設定例** (`.prettierrc`):
```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2
}
```

### リンター

**推奨**: `ESLint` with TypeScript plugin

```bash
npx eslint src/
```

**設定例** (`.eslintrc.json`):
```json
{
  "parser": "@typescript-eslint/parser",
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "prettier"
  ],
  "plugins": ["@typescript-eslint"],
  "parserOptions": {
    "ecmaVersion": 2022,
    "sourceType": "module"
  },
  "rules": {
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/explicit-function-return-type": "warn"
  }
}
```

### 型チェック

TypeScript コンパイラ自体が型チェッカー：

```bash
npx tsc --noEmit  # 型チェックのみ（出力なし）
```

**ベストプラクティス**:
- `any` 型は極力避ける
- 関数の戻り値型を明示する
- `unknown` を使い、型ガードで絞り込む

```typescript
function processData(data: unknown): string {
  if (typeof data === 'string') {
    return data.toUpperCase();
  }
  if (typeof data === 'number') {
    return data.toString();
  }
  throw new Error('Unsupported data type');
}
```

---

## テスト

### テストフレームワーク

**選択肢**:
- `Jest` - 最も人気（すべて込み）
- `Vitest` - 高速・Vite 統合
- `Mocha` + `Chai` - 古典的

**推奨**: 新規プロジェクトは `Vitest`、既存プロジェクトは `Jest`

```bash
# Vitest
npx vitest run
npx vitest run --coverage

# Jest
npx jest
npx jest --coverage
```

**ディレクトリ構造**:
```
project/
├── src/
│   ├── index.ts
│   ├── utils.ts
│   └── __tests__/
│       └── utils.test.ts
└── package.json
```

または

```
project/
├── src/
│   ├── index.ts
│   └── utils.ts
└── tests/
    └── utils.test.ts
```

**ベストプラクティス**:
- テストファイル名: `*.test.ts` または `*.spec.ts`
- カバレッジ目標: 80% 以上

---

## ビルドツール

### 選択肢

- `Vite` - 最新・高速（推奨）
- `webpack` - 最も柔軟
- `esbuild` - 超高速ビルド
- `tsup` - ライブラリ向け（Zero-config）

### package.json スクリプト例

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

---

## タスク分解時の考慮事項

### セットアップタスク

最初に以下を含むセットアップタスクを配置：
1. `package.json` の作成 (`npm init` / `yarn init`)
2. TypeScript と開発ツールのインストール
   ```bash
   npm install -D typescript @types/node
   npm install -D prettier eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin
   npm install -D vitest @vitest/ui
   ```
3. `tsconfig.json` の作成
4. `.prettierrc` と `.eslintrc.json` の作成
5. ディレクトリ構造の作成 (`src/`, `tests/` または `src/__tests__/`)

### パッケージ管理タスク

新しいパッケージを追加する場合：
- `package.json` と `package-lock.json` (or `yarn.lock`) を output_artifacts に明記
- `npm install` の実行を指示に含める
- 型定義パッケージ (`@types/*`) も必要なら追加

### テストタスク

実装タスクとは独立させる：
- input_artifacts: 実装済みのコード
- output_artifacts: `*.test.ts` ファイル
- success_criteria: カバレッジ 80% 以上、全テスト通過

---

## Gate2 評価基準（Observer 用）

TypeScript コードの品質チェック項目：

### 必須項目 (severity: critical)

- [ ] `tsc --noEmit` で型エラーなし
- [ ] `prettier --check` でフォーマット確認が通過
- [ ] `eslint` で警告・エラーなし
- [ ] `package.json` が存在し、依存関係が記載されている
- [ ] `tsconfig.json` で `strict: true` が有効

### 推奨項目 (severity: major)

- [ ] `vitest` / `jest` でテストがすべて通過
- [ ] カバレッジが 80% 以上（テストタスクの場合）
- [ ] `@typescript-eslint/no-explicit-any` ルールが有効
- [ ] 関数の戻り値型が明示されている（主要な関数）
- [ ] ビルドが成功する (`npm run build`)

### 任意項目 (severity: minor)

- [ ] pre-commit フックが設定されている（`husky` など）
- [ ] CI/CD 設定ファイルが存在する (`.github/workflows/`)
- [ ] モジュール境界が適切に分離されている

---

## よくある落とし穴

### 1. any 型の乱用

❌ **悪い例**:
```typescript
function process(data: any) {
  return data.toUpperCase();
}
```

✅ **良い例**:
```typescript
function process(data: unknown): string {
  if (typeof data === 'string') {
    return data.toUpperCase();
  }
  throw new Error('Expected string');
}
```

### 2. 戻り値型の省略

❌ **悪い例**:
```typescript
function calculate(a: number, b: number) {
  return a + b;
}
```

✅ **良い例**:
```typescript
function calculate(a: number, b: number): number {
  return a + b;
}
```

### 3. strictNullChecks の無効化

❌ **悪い例**: `tsconfig.json` で `strictNullChecks: false`

✅ **良い例**: `strictNullChecks: true` で明示的な null チェック
```typescript
function getName(user: { name?: string }): string {
  return user.name ?? 'Anonymous';
}
```

---

## 参考資料

- [TypeScript Documentation](https://www.typescriptlang.org/docs/)
- [TypeScript Deep Dive](https://basarat.gitbook.io/typescript/)
- [ESLint TypeScript](https://typescript-eslint.io/)
- [Prettier](https://prettier.io/)
- [Vitest](https://vitest.dev/)

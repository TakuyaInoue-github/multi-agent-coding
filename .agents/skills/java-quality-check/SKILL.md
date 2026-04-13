---
name: java-quality-check
description: |
  Run quality checks on Java code. Invoke automatically after writing or modifying Java files,
  before committing, or when asked to verify code quality.
  Triggers: after implementing .java files, before git commit, "check quality", "run checks",
  "verify implementation", Gate2 evaluation by Observer.
  Checks: mvn compile, checkstyle, mvn test (testing tasks only).
disable-model-invocation: false
user-invocable: true
allowed-tools: [bash]
---

# Java 品質チェック Skill

Observer が Gate2 評価時に Java コードの品質をチェックするために使用します。

## 使用方法

```bash
/java-quality-check "task-001"
/java-quality-check "$TASK_ID"
```

## 引数

- `$0` = タスクID（例: "task-001"）

## チェック項目

このスキルは以下のチェックを実行し、結果を `tasks/$TASK_ID/quality_report.md` に出力します。

### 1. コンパイルチェック

**Maven**:
```bash
cd tasks/$TASK_ID
mvn compile
```

**Gradle**:
```bash
cd tasks/$TASK_ID
./gradlew compileJava
```

**評価基準**:
- ✅ pass: コンパイル成功
- ❌ fail: コンパイル失敗

### 2. コードスタイルチェック (Checkstyle)

**Maven**:
```bash
cd tasks/$TASK_ID
mvn checkstyle:check
```

**Gradle**:
```bash
cd tasks/$TASK_ID
./gradlew checkstyleMain
```

**評価基準**:
- ✅ pass: 違反なし
- ⚠️  warning: 軽微な違反のみ
- ❌ fail: 重大な違反あり

### 3. フォーマットチェック (google-java-format / Spotless)

**Maven**:
```bash
cd tasks/$TASK_ID
mvn com.spotify.fmt:fmt-maven-plugin:check || echo "formatter not configured"
```

**Gradle**:
```bash
cd tasks/$TASK_ID
./gradlew spotlessCheck || echo "spotless not configured"
```

**評価基準**:
- ✅ pass: フォーマット済み、または未設定
- ❌ fail: フォーマット差分あり

### 4. バグ検出 (SpotBugs)

**Maven**:
```bash
cd tasks/$TASK_ID
mvn spotbugs:check
```

**Gradle**:
```bash
cd tasks/$TASK_ID
./gradlew spotbugsMain
```

**評価基準**:
- ✅ pass: バグなし
- ⚠️  warning: 軽微なバグ
- ❌ fail: 重大なバグあり

### 5. テストチェック (JUnit) - テストタスクのみ

**Maven**:
```bash
cd tasks/$TASK_ID
mvn test
mvn jacoco:report  # カバレッジ
```

**Gradle**:
```bash
cd tasks/$TASK_ID
./gradlew test
./gradlew jacocoTestReport  # カバレッジ
```

**評価基準**:
- ✅ pass: テスト全通過、カバレッジ 80% 以上
- ⚠️  warning: テスト全通過、カバレッジ 80% 未満
- ❌ fail: テスト失敗

### 6. 構造チェック

- [ ] `pom.xml` または `build.gradle` が存在する
- [ ] Java バージョンが明示されている
- [ ] パッケージ構造が適切（逆ドメイン形式）
- [ ] Javadoc が主要なクラス・メソッドに存在する
- [ ] `target/` または `build/` が `.gitignore` に含まれている

## 出力形式

`tasks/$TASK_ID/quality_report.md`:

```markdown
# Java 品質チェックレポート

タスクID: $TASK_ID
ビルドツール: Maven | Gradle
実行日時: $(date)

## コンパイルチェック

**結果**: pass | fail
**詳細**:
\`\`\`
(コンパイルの出力)
\`\`\`

## コードスタイルチェック (Checkstyle)

**結果**: pass | warning | fail
**詳細**:
\`\`\`
(Checkstyle の出力)
\`\`\`

## フォーマットチェック (google-java-format/Spotless)

**結果**: pass | fail | not_applicable
**詳細**:
\`\`\`
(フォーマッターの出力)
\`\`\`

## バグ検出 (SpotBugs)

**結果**: pass | warning | fail
**詳細**:
\`\`\`
(SpotBugs の出力)
\`\`\`

## テストチェック (JUnit)

**結果**: pass | warning | fail | not_applicable
**カバレッジ**: XX%
**詳細**:
\`\`\`
(テストの出力)
\`\`\`

## 構造チェック

- [x] pom.xml / build.gradle が存在する
- [x] Java バージョンが明示されている
- [x] パッケージ構造が適切
- [x] Javadoc が存在する
- [x] target/ / build/ が .gitignore に含まれている

## 総合評価

**verdict**: pass | warning | fail

**判定基準**:
- コンパイル失敗 → 全体 fail (severity: critical)
- Checkstyle 重大違反 → 全体 fail (severity: critical)
- SpotBugs 重大バグ → 全体 fail (severity: major)
- テスト失敗 → 全体 fail (severity: critical)
- カバレッジ 80% 未満 → warning (severity: major)
- それ以外 → pass

**推奨アクション**:
(fail の場合の修正方法を記載)
```

## 関連ファイル

- `.multi-agent/config/languages/java.md` - Java プロジェクトガイドライン
- `.multi-agent/config/RULEBOOK.md` - 評価基準

## 使用例

### Observer が Gate2 評価時に実行

```bash
/java-quality-check "task-001"
```

その後、`tasks/task-001/quality_report.md` を読んで評価結果を確認。

## 注意事項

- ビルドツール（Maven / Gradle）は自動検出
- Maven の場合: `pom.xml` の存在で判定
- Gradle の場合: `build.gradle` または `build.gradle.kts` の存在で判定
- テストチェックは `worker_type: testing` のタスクでのみ実施
- SpotBugs / google-java-format / Spotless はオプション（設定されている場合のみ実行）

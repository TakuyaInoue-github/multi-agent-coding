# Java プロジェクトガイドライン

このドキュメントは Commander と Observer が Java プロジェクトでタスクを分解・評価する際に参照します。

---

## 環境管理

### ビルドツール

**選択肢**: `Maven` または `Gradle`

#### Maven

```bash
# プロジェクト初期化
mvn archetype:generate

# 依存関係のインストール
mvn clean install

# テスト実行
mvn test
```

**ファイル**:
- `pom.xml` - プロジェクト設定・依存関係

#### Gradle

```bash
# プロジェクト初期化
gradle init

# ビルド
./gradlew build

# テスト実行
./gradlew test
```

**ファイル**:
- `build.gradle` (Groovy) または `build.gradle.kts` (Kotlin DSL)
- `settings.gradle` (Groovy) または `settings.gradle.kts` (Kotlin DSL)

**推奨**: 新規プロジェクトは **Gradle**（高速・柔軟）、企業環境では **Maven**（安定・実績）

### JDK バージョン

**推奨**:
- Java 17 LTS (2023年時点での推奨)
- Java 21 LTS (最新 LTS、2023年9月リリース)

**タスク分解時の注意**:
- `pom.xml` / `build.gradle` で Java バージョンを明示
- パッケージ追加は独立タスクとする

---

## プロジェクト構造

### Maven 標準レイアウト

```
project/
├── pom.xml
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/example/myapp/
│   │   │       ├── Main.java
│   │   │       ├── controller/
│   │   │       ├── service/
│   │   │       └── repository/
│   │   └── resources/
│   │       ├── application.properties
│   │       └── logback.xml
│   └── test/
│       ├── java/
│       │   └── com/example/myapp/
│       │       └── service/
│       │           └── UserServiceTest.java
│       └── resources/
└── target/  # ビルド出力（.gitignore 対象）
```

### Gradle 標準レイアウト

```
project/
├── build.gradle.kts
├── settings.gradle.kts
├── gradlew
├── gradlew.bat
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/example/myapp/
│   │   └── resources/
│   └── test/
│       ├── java/
│       │   └── com/example/myapp/
│       └── resources/
└── build/  # ビルド出力（.gitignore 対象）
```

---

## コード品質

### フォーマッター

**選択肢**:
- `google-java-format` - Google スタイル（推奨）
- `Eclipse Formatter` - Eclipse IDE 標準
- `IntelliJ IDEA Formatter` - IntelliJ 標準

**google-java-format の使用**:

```bash
# インストール（Maven plugin）
<plugin>
  <groupId>com.spotify.fmt</groupId>
  <artifactId>fmt-maven-plugin</artifactId>
  <version>2.21</version>
</plugin>

# フォーマット実行
mvn com.spotify.fmt:fmt-maven-plugin:format

# CI での確認
mvn com.spotify.fmt:fmt-maven-plugin:check
```

**Gradle**:
```kotlin
plugins {
    id("com.diffplug.spotless") version "6.23.0"
}

spotless {
    java {
        googleJavaFormat()
    }
}
```

### リンター

**選択肢**:
- `Checkstyle` - コーディング規約チェック（推奨）
- `PMD` - 潜在的なバグ検出
- `SpotBugs` - バイトコード解析

**Checkstyle の設定**:

```xml
<!-- pom.xml -->
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-checkstyle-plugin</artifactId>
  <version>3.3.1</version>
  <configuration>
    <configLocation>google_checks.xml</configLocation>
  </configuration>
</plugin>
```

```bash
mvn checkstyle:check
```

**Gradle**:
```kotlin
plugins {
    checkstyle
}

checkstyle {
    toolVersion = "10.12.5"
    configFile = file("config/checkstyle/checkstyle.xml")
}
```

### 静的解析

**SpotBugs** (FindBugs の後継):

```xml
<!-- pom.xml -->
<plugin>
  <groupId>com.github.spotbugs</groupId>
  <artifactId>spotbugs-maven-plugin</artifactId>
  <version>4.8.1</version>
</plugin>
```

```bash
mvn spotbugs:check
```

---

## テスト

### テストフレームワーク

**推奨**: `JUnit 5` (Jupiter)

```xml
<!-- pom.xml -->
<dependency>
  <groupId>org.junit.jupiter</groupId>
  <artifactId>junit-jupiter</artifactId>
  <version>5.10.1</version>
  <scope>test</scope>
</dependency>
```

**Gradle**:
```kotlin
dependencies {
    testImplementation("org.junit.jupiter:junit-jupiter:5.10.1")
}

tasks.test {
    useJUnitPlatform()
}
```

**テスト例**:
```java
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class CalculatorTest {
    @Test
    void testAdd() {
        Calculator calc = new Calculator();
        assertEquals(5, calc.add(2, 3));
    }

    @Test
    void testDivideByZero() {
        Calculator calc = new Calculator();
        assertThrows(ArithmeticException.class, () -> calc.divide(1, 0));
    }
}
```

### モックライブラリ

**推奨**: `Mockito`

```xml
<dependency>
  <groupId>org.mockito</groupId>
  <artifactId>mockito-core</artifactId>
  <version>5.7.0</version>
  <scope>test</scope>
</dependency>
```

**使用例**:
```java
import static org.mockito.Mockito.*;

@Test
void testService() {
    UserRepository repo = mock(UserRepository.class);
    when(repo.findById(1L)).thenReturn(Optional.of(new User("Alice")));

    UserService service = new UserService(repo);
    User user = service.getUser(1L);

    assertEquals("Alice", user.getName());
    verify(repo).findById(1L);
}
```

### カバレッジ測定

**JaCoCo**:

```xml
<!-- pom.xml -->
<plugin>
  <groupId>org.jacoco</groupId>
  <artifactId>jacoco-maven-plugin</artifactId>
  <version>0.8.11</version>
  <executions>
    <execution>
      <goals>
        <goal>prepare-agent</goal>
      </goals>
    </execution>
    <execution>
      <id>report</id>
      <phase>test</phase>
      <goals>
        <goal>report</goal>
      </goals>
    </execution>
  </executions>
</plugin>
```

```bash
mvn test
# カバレッジレポート: target/site/jacoco/index.html
```

**ベストプラクティス**:
- カバレッジ目標: 80% 以上

---

## ビルド

### Maven

```bash
# クリーンビルド
mvn clean install

# テストスキップ（非推奨だが時間短縮）
mvn clean install -DskipTests

# パッケージング
mvn package  # JAR/WAR 生成
```

### Gradle

```bash
# ビルド
./gradlew build

# テストスキップ
./gradlew build -x test

# JAR 生成
./gradlew jar
```

---

## タスク分解時の考慮事項

### セットアップタスク

最初に以下を含むセットアップタスクを配置：

**Maven**:
1. `pom.xml` の作成
2. ディレクトリ構造の作成 (`src/main/java`, `src/test/java`)
3. 開発ツールの設定（Checkstyle, SpotBugs, google-java-format）
4. JUnit 5 + Mockito の依存関係追加

**Gradle**:
1. `gradle init` でプロジェクト初期化
2. `build.gradle.kts` の設定
3. Spotless + Checkstyle の設定
4. テスト依存関係の追加

### パッケージ管理タスク

新しいライブラリを追加する場合：
- `pom.xml` / `build.gradle` の更新を output_artifacts に明記
- バージョン競合に注意（`mvn dependency:tree` で確認）

### テストタスク

実装タスクとは独立させる：
- input_artifacts: 実装済みのコード
- output_artifacts: `*Test.java` ファイル
- success_criteria: カバレッジ 80% 以上、全テスト通過

---

## Gate2 評価基準（Observer 用）

Java コードの品質チェック項目：

### 必須項目 (severity: critical)

- [ ] `mvn compile` / `./gradlew compileJava` でコンパイル成功
- [ ] `mvn checkstyle:check` でスタイル違反なし
- [ ] パッケージ構造が適切 (`com.example.projectname`)
- [ ] `pom.xml` / `build.gradle` が存在し、依存関係が記載されている
- [ ] Java バージョンが明示されている

### 推奨項目 (severity: major)

- [ ] `mvn test` / `./gradlew test` でテストがすべて通過
- [ ] JaCoCo カバレッジが 80% 以上（テストタスクの場合）
- [ ] `mvn spotbugs:check` で警告なし
- [ ] 適切な例外処理が実装されている（checked exceptions）
- [ ] Javadoc が主要なクラス・メソッドに存在する

### 任意項目 (severity: minor)

- [ ] `google-java-format` でフォーマット済み
- [ ] CI/CD 設定ファイルが存在する (`.github/workflows/`, `Jenkinsfile`)
- [ ] ログフレームワークが適切（SLF4J + Logback）
- [ ] 依存性注入フレームワークが使用されている（Spring, Guice など）

---

## よくある落とし穴

### 1. null チェックの省略

❌ **悪い例**:
```java
public String getName(User user) {
    return user.getName().toUpperCase();
}
```

✅ **良い例**:
```java
public String getName(User user) {
    if (user == null || user.getName() == null) {
        throw new IllegalArgumentException("User or name cannot be null");
    }
    return user.getName().toUpperCase();
}
```

または Optional を使用:
```java
public Optional<String> getName(User user) {
    return Optional.ofNullable(user)
        .map(User::getName)
        .map(String::toUpperCase);
}
```

### 2. リソースのクローズ忘れ

❌ **悪い例**:
```java
FileReader reader = new FileReader("file.txt");
// 例外が発生するとクローズされない
reader.close();
```

✅ **良い例** (try-with-resources):
```java
try (FileReader reader = new FileReader("file.txt")) {
    // 処理
} catch (IOException e) {
    // エラーハンドリング
}
```

### 3. equals() と hashCode() の不整合

クラスで `equals()` をオーバーライドする場合、`hashCode()` も必ずオーバーライド：

```java
@Override
public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    User user = (User) o;
    return Objects.equals(id, user.id);
}

@Override
public int hashCode() {
    return Objects.hash(id);
}
```

---

## 参考資料

- [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html)
- [Effective Java (Joshua Bloch)](https://www.oreilly.com/library/view/effective-java/9780134686097/)
- [Maven Official Documentation](https://maven.apache.org/)
- [Gradle Official Documentation](https://docs.gradle.org/)
- [JUnit 5 User Guide](https://junit.org/junit5/docs/current/user-guide/)

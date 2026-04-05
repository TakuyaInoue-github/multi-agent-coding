---
name: java-setup
description: Java プロジェクトの初期セットアップタスクを生成
disable-model-invocation: false
user-invocable: true
allowed-tools: [editor, bash]
---

# Java セットアップ Skill

Commander が Java プロジェクトの初期セットアップタスクを生成するために使用します。

## 使用方法

```bash
/java-setup "maven" "com.example.myapp" "17"
/java-setup "$BUILD_TOOL" "$GROUP_ID" "$JAVA_VERSION"
```

## 引数

- `$0` = ビルドツール（maven | gradle、デフォルト: maven）
- `$1` = グループID（例: "com.example.myapp"）
- `$2` = Java バージョン（例: "17", "21"、デフォルト: "17"）

## 生成されるタスク仕様

このスキルは `tasks/task-setup-java/spec.md` を生成します。

### タスク内容（Maven の場合）

1. **pom.xml の作成**
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <project xmlns="http://maven.apache.org/POM/4.0.0"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
            http://maven.apache.org/xsd/maven-4.0.0.xsd">
       <modelVersion>4.0.0</modelVersion>

       <groupId>{{group_id}}</groupId>
       <artifactId>{{artifact_id}}</artifactId>
       <version>1.0-SNAPSHOT</version>

       <properties>
           <maven.compiler.source>{{java_version}}</maven.compiler.source>
           <maven.compiler.target>{{java_version}}</maven.compiler.target>
           <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
       </properties>

       <dependencies>
           <!-- JUnit 5 -->
           <dependency>
               <groupId>org.junit.jupiter</groupId>
               <artifactId>junit-jupiter</artifactId>
               <version>5.10.1</version>
               <scope>test</scope>
           </dependency>
           <!-- Mockito -->
           <dependency>
               <groupId>org.mockito</groupId>
               <artifactId>mockito-core</artifactId>
               <version>5.7.0</version>
               <scope>test</scope>
           </dependency>
       </dependencies>

       <build>
           <plugins>
               <!-- Maven Compiler Plugin -->
               <plugin>
                   <groupId>org.apache.maven.plugins</groupId>
                   <artifactId>maven-compiler-plugin</artifactId>
                   <version>3.11.0</version>
               </plugin>
               <!-- Maven Surefire Plugin (for running tests) -->
               <plugin>
                   <groupId>org.apache.maven.plugins</groupId>
                   <artifactId>maven-surefire-plugin</artifactId>
                   <version>3.2.2</version>
               </plugin>
               <!-- Checkstyle -->
               <plugin>
                   <groupId>org.apache.maven.plugins</groupId>
                   <artifactId>maven-checkstyle-plugin</artifactId>
                   <version>3.3.1</version>
                   <configuration>
                       <configLocation>google_checks.xml</configLocation>
                   </configuration>
               </plugin>
               <!-- SpotBugs -->
               <plugin>
                   <groupId>com.github.spotbugs</groupId>
                   <artifactId>spotbugs-maven-plugin</artifactId>
                   <version>4.8.1</version>
               </plugin>
               <!-- JaCoCo (code coverage) -->
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
           </plugins>
       </build>
   </project>
   ```

2. **ディレクトリ構造の作成**
   ```
   src/
   ├── main/
   │   ├── java/
   │   │   └── {{group_id_path}}/
   │   │       └── Main.java
   │   └── resources/
   └── test/
       ├── java/
       │   └── {{group_id_path}}/
       │       └── MainTest.java
       └── resources/
   ```

3. **.gitignore の作成**（Java/Maven 用）
   ```
   # Maven
   target/
   pom.xml.tag
   pom.xml.releaseBackup
   pom.xml.versionsBackup
   pom.xml.next
   release.properties
   dependency-reduced-pom.xml

   # Gradle
   .gradle/
   build/
   !gradle/wrapper/gradle-wrapper.jar

   # IDE
   .idea/
   *.iml
   .vscode/
   .classpath
   .project
   .settings/

   # OS
   .DS_Store
   Thumbs.db
   ```

### タスク内容（Gradle の場合）

1. **build.gradle.kts の作成**
   ```kotlin
   plugins {
       java
       checkstyle
       id("com.github.spotbugs") version "5.2.3"
       id("com.diffplug.spotless") version "6.23.0"
   }

   group = "{{group_id}}"
   version = "1.0-SNAPSHOT"

   java {
       sourceCompatibility = JavaVersion.VERSION_{{java_version}}
       targetCompatibility = JavaVersion.VERSION_{{java_version}}
   }

   repositories {
       mavenCentral()
   }

   dependencies {
       testImplementation("org.junit.jupiter:junit-jupiter:5.10.1")
       testImplementation("org.mockito:mockito-core:5.7.0")
   }

   tasks.test {
       useJUnitPlatform()
   }

   spotless {
       java {
           googleJavaFormat()
       }
   }

   checkstyle {
       toolVersion = "10.12.5"
       configFile = file("config/checkstyle/checkstyle.xml")
   }
   ```

2. **settings.gradle.kts の作成**
   ```kotlin
   rootProject.name = "{{artifact_id}}"
   ```

## 出力

### spec.md の構造

```yaml
---
task_id: task-setup-java
worker_type: coding
depends_on: []
parallel_ok: false
input_artifacts: []
output_artifacts:
  - pom.xml  # or build.gradle.kts, settings.gradle.kts
  - src/main/java/{{group_id_path}}/Main.java
  - src/test/java/{{group_id_path}}/MainTest.java
  - .gitignore
permissions:
  filesystem:
    write: [., src/main/java/, src/test/java/, src/main/resources/, src/test/resources/]
  execution:
    allowed: [mvn, java, javac]  # or ./gradlew
required_packages: []
environment_verified: true
commander_reasoning: |
  Java プロジェクトの初期セットアップタスク。
  ビルドツール, テスト依存関係, 品質チェックプラグインの設定を含む。
---

## 指示内容

Java プロジェクトの初期セットアップを行う（ビルドツール: {{build_tool}}, グループID: {{group_id}}, Java バージョン: {{java_version}}）。

1. `{{build_tool}}` の設定ファイルを作成する
   - Maven: `pom.xml`
   - Gradle: `build.gradle.kts`, `settings.gradle.kts`
2. ディレクトリ構造を作成する（Maven 標準レイアウト）
   - `src/main/java/{{group_id_path}}/`
   - `src/test/java/{{group_id_path}}/`
   - `src/main/resources/`
   - `src/test/resources/`
3. テスト依存関係を追加する（JUnit 5, Mockito）
4. 品質チェックプラグインを設定する（Checkstyle, SpotBugs, JaCoCo）
5. `.gitignore` を作成する（Java/{{build_tool}} 用）
6. `Main.java` を作成する（基本的な Hello World）
7. `MainTest.java` を作成する（基本的なテスト）

## 期待する成果物

- ビルド設定ファイルが存在し、Java バージョンが正しく設定されている
- ディレクトリ構造が Maven 標準レイアウトに準拠している
- テスト依存関係（JUnit 5, Mockito）が追加されている
- 品質チェックプラグインが設定されている
- `.gitignore` が存在し、`target/` (Maven) または `build/` (Gradle) が含まれている
- `Main.java` が存在し、コンパイル可能である
- `MainTest.java` が存在し、テストが実行できる

## 成功基準

- [ ] `mvn compile` / `./gradlew compileJava` でコンパイルが成功する
- [ ] `mvn test` / `./gradlew test` でテストが実行できる
- [ ] `mvn checkstyle:check` / `./gradlew checkstyleMain` でスタイルチェックが通る
- [ ] パッケージ構造が適切（`{{group_id}}.` で始まる）
- [ ] `.gitignore` に `target/` または `build/` が含まれている

## 注意事項

- グループID は逆ドメイン形式（例: `com.example`）
- パッケージパスは `com/example/myapp` のようにディレクトリ階層に変換される
- Gradle の場合、Wrapper も生成する（`gradle wrapper`）
```

## 関連ファイル

- `.multi-agent/config/languages/java.md` - Java プロジェクトガイドライン
- `.multi-agent/templates/task/spec.md` - タスク仕様テンプレート

## 使用例

### Maven プロジェクト（推奨: 企業環境）

```bash
/java-setup "maven" "com.example.myapp" "17"
```

### Gradle プロジェクト（推奨: 新規プロジェクト）

```bash
/java-setup "gradle" "com.example.myapp" "21"
```

## 次のステップ

セットアップタスク完了後、以下のタスクを続けて作成することを推奨：

1. **依存関係のインストールタスク**
   ```bash
   mvn clean install  # Maven
   ./gradlew build     # Gradle
   ```

2. **品質チェック設定の検証タスク**
   ```bash
   mvn checkstyle:check
   mvn spotbugs:check
   mvn test
   # Gradle
   ./gradlew checkstyleMain
   ./gradlew spotbugsMain
   ./gradlew test
   ```

## 参考

- [Maven Getting Started](https://maven.apache.org/guides/getting-started/)
- [Gradle User Guide](https://docs.gradle.org/current/userguide/userguide.html)
- [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html)

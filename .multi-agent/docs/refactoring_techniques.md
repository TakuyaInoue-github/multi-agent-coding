# リファクタリングの技法

**書籍横断的な体系整理：原則・嗅覚・カタログ・ワークフロー**

Research Report — 2026-04

---

## 目次

1. [はじめに](#1-はじめに)
2. [リファクタリングの定義と原則](#2-リファクタリングの定義と原則)
3. [Two Hats メタファとワークフロー](#3-two-hats メタファとワークフロー)
4. [Code Smells：リファクタリングの嗅覚](#4-code-smells リファクタリングの嗅覚)
5. [リファクタリングカタログ](#5-リファクタリングカタログ)
6. [Refactoring to Patterns：パターンへの進化](#6-refactoring-to-patterns パターンへの進化)
7. [レガシーコードにおけるリファクタリング](#7-レガシーコードにおけるリファクタリング)
8. [リファクタリングの判断フレーム](#8-リファクタリングの判断フレーム)
9. [参考文献](#9-参考文献)

---

## 1. はじめに

リファクタリングは、ソフトウェアの外部的な振る舞いを変えずに内部構造を改善する規律あるテクニックである。Martin Fowler が 1999 年にこの用語を体系化して以来、リファクタリングはプロフェッショナルなプログラマーの基本スキルとなった。しかし「リファクタリング」という言葉は日常会話の中で「コードの書き直し」と混同されがちであり、その本質的な特徴——振る舞い保存・小ステップ・テスト駆動——が見失われることが多い。

本レポートでは、Fowler の『Refactoring』（第 2 版, 2018）を中心に、Feathers の『Working Effectively with Legacy Code』、Kerievsky の『Refactoring to Patterns』、McConnell の『Code Complete』、Martin（Uncle Bob）の『Clean Code』等の書籍を横断し、リファクタリングの原則・嗅覚・カタログ・ワークフローを体系的に整理する。

---

## 2. リファクタリングの定義と原則

### 2.1 厳密な定義

Fowler は名詞と動詞の両方を定義している：

- **名詞としての refactoring** — ソフトウェアの外部的な振る舞いを変えない、内部構造に対する変更。例：Extract Function、Rename Variable。
- **動詞としての refactoring** — 一連のリファクタリング（名詞）を適用することで、外部的な振る舞いを変えずにソフトウェアを再構造化すること。

重要な帰結として、リファクタリングはバグも保存する。バグを修正したなら、それはリファクタリングではない。

### 2.2 なぜリファクタリングするのか

Fowler は以下の理由を挙げている：

- **ソフトウェアの設計を改善する** — 短期的な目標のためにアーキテクチャの全体像を理解しないまま変更を加えると、コードは構造を失っていく。リファクタリングはこの劣化に対抗する。
- **ソフトウェアを理解しやすくする** — コードを理解するために構築した洞察を、コード自体に移す。Ward Cunningham の言葉を借りれば「誰も頭の中でゼロから理解を組み立てなくて済むように」。
- **バグを見つけやすくする** — コードの構造を明確にすることで、バグが見える場所に浮上する。
- **より速くプログラムできるようにする** — Design Stamina Hypothesis：良い設計はプログラミング速度を長期的に維持する。リファクタリングは設計の品質を保つことで、機能追加のコストが時間とともに増大することを防ぐ。

### 2.3 リファクタリングの前提条件

- **テスト** — リファクタリングの安全網。テストなしのリファクタリングは、ロープなしの綱渡りである。各リファクタリングステップの後にテストを実行し、振る舞いが保存されていることを確認する。
- **バージョン管理** — 小ステップでコミットし、問題が発生したら即座に戻れるようにする。
- **自動化されたリファクタリングツール** — IDE のリファクタリング機能は、手動操作よりも安全で高速。ただしツールを信頼しすぎず、テストで検証する。

---

## 3. Two Hats メタファとワークフロー

### 3.1 Two Hats（Kent Beck）

Kent Beck が考案し、Fowler が広めたメタファ。プログラミング中は常に 2 つの帽子のどちらか一方だけを被る：

- **機能追加の帽子** — 新しい機能を追加し、新しいテストを書く。既存コードの構造は変えない。
- **リファクタリングの帽子** — コードの構造を変える。機能は追加しない。テストも追加しない（インターフェースが変わった場合を除く）。

プログラミング中に数分おきに帽子を切り替えることがある。ただし**同時に両方の帽子を被ることは決してない**。どちらの帽子を被っているかを常に意識することが重要。

### 3.2 リファクタリングのワークフロー分類

Fowler は「Workflows of Refactoring」で、リファクタリングを組み込む 6 つのワークフローを提示している：

#### TDD Refactoring

Red → Green → Refactor サイクルの第 3 フェーズ。テストを通した直後のコードを綺麗にする。最も頻度が高く、最も小さい単位のリファクタリング。

#### Comprehension Refactoring

コードを読んで理解を構築したとき、その理解をコード自体に反映させるリファクタリング。変数名の改善、関数の抽出、条件の整理などが典型的。前回のコードリーディングレポートで述べた「理解をコードに移す」行為そのもの。

#### Litter-Pickup Refactoring

作業中に見かけた小さな問題を、その場で修正するリファクタリング。ボーイスカウトルール（来たときよりも美しく）の実践。1〜2 分で終わるものに限定し、ウサギの穴に落ちないよう注意する。

#### Preparatory Refactoring

新しい機能を追加する前に、既存コードの構造を変えて機能追加を容易にするリファクタリング。Jessica Kerr のメタファ：「東に 100 マイル行きたいが、森をまっすぐ突っ切る代わりに、北に 20 マイル走って高速道路に出てから 3 倍の速度で東に 100 マイル行く」。Beck 曰く「変更を容易にしてから、容易な変更を行え」。

#### Planned Refactoring

チームが意図的に時間を確保して行うリファクタリング。大きな構造的問題に対処するとき必要だが、Fowler はこれが頻繁に必要になるのは、日常的なリファクタリングが不足している兆候だと指摘する。

#### Long-Term Refactoring

ライブラリの置き換え、大規模なモジュール分割など、数週間〜数ヶ月かかるリファクタリング。Branch By Abstraction などのテクニックを使い、コードベースを常に動作可能な状態に保ちながら漸進的に進める。

---

## 4. Code Smells：リファクタリングの嗅覚

Code Smell は、Kent Beck が命名し Fowler が体系化した概念で、リファクタリングが必要な箇所を示す「臭い」である。Smell はバグではない——コードは動作する。しかし Smell は設計上の問題を示唆し、将来の変更を困難にする。

### 4.1 Fowler の第 2 版 Code Smells 一覧

Fowler の第 2 版では以下の Code Smells が定義されている。各 Smell に対応する典型的なリファクタリングを併記する：

#### 基本的な Smells

| Smell | 説明 | 典型的なリファクタリング |
|-------|------|----------------------|
| **Mysterious Name** | 意図が伝わらない名前 | Change Function Declaration, Rename Variable, Rename Field |
| **Duplicated Code** | 同じコード構造が複数箇所に存在 | Extract Function, Slide Statements, Pull Up Method |
| **Long Function** | 長すぎる関数 | Extract Function, Replace Temp with Query, Introduce Parameter Object, Replace Conditional with Polymorphism |
| **Long Parameter List** | パラメータが多すぎる | Replace Parameter with Query, Preserve Whole Object, Introduce Parameter Object, Remove Flag Argument |
| **Global Data** | グローバルに変更可能なデータ | Encapsulate Variable |
| **Mutable Data** | 変更可能なデータが広く共有される | Encapsulate Variable, Split Variable, Replace Derived Variable with Query, Combine Functions into Class |

#### 変更パターンに関する Smells

| Smell | 説明 | 典型的なリファクタリング |
|-------|------|----------------------|
| **Divergent Change** | 1 つのモジュールが異なる理由で頻繁に変更される | Split Phase, Move Function, Extract Function, Extract Class |
| **Shotgun Surgery** | 1 つの変更が多数のモジュールの修正を要する | Move Function, Move Field, Combine Functions into Class, Inline Function/Class |
| **Feature Envy** | 関数が自分のモジュールより他のモジュールのデータを多く使う | Move Function, Extract Function |

#### データ構造に関する Smells

| Smell | 説明 | 典型的なリファクタリング |
|-------|------|----------------------|
| **Data Clumps** | 同じデータ群が複数箇所で一緒に現れる | Extract Class, Introduce Parameter Object, Preserve Whole Object |
| **Primitive Obsession** | プリミティブ型を過度に使い、ドメイン概念を型として表現しない | Replace Primitive with Object, Replace Type Code with Subclasses, Replace Conditional with Polymorphism |
| **Repeated Switches** | 同じ switch/if-else チェーンが複数箇所に存在 | Replace Conditional with Polymorphism |
| **Temporary Field** | 特定の状況でのみ値が設定されるフィールド | Extract Class, Move Function, Introduce Special Case |

#### 構造に関する Smells

| Smell | 説明 | 典型的なリファクタリング |
|-------|------|----------------------|
| **Lazy Element** | 存在する価値がほとんどないクラスや関数 | Inline Function, Inline Class, Collapse Hierarchy |
| **Speculative Generality** | 将来必要になるかもしれないという推測による過度の一般化 | Collapse Hierarchy, Inline Function/Class, Change Function Declaration, Remove Dead Code |
| **Message Chains** | クライアントがオブジェクトの長い委譲チェーンを辿る | Hide Delegate, Extract Function, Move Function |
| **Middle Man** | クラスの多くのメソッドが別のクラスに委譲するだけ | Remove Middle Man, Inline Function, Replace Superclass with Delegate |
| **Insider Trading** | モジュール間でデータを過度にやりとりする | Move Function, Move Field, Hide Delegate, Replace Subclass/Superclass with Delegate |

#### その他の Smells

| Smell | 説明 | 典型的なリファクタリング |
|-------|------|----------------------|
| **Large Class** | クラスが多くのことをしすぎている | Extract Class, Extract Superclass, Replace Type Code with Subclasses |
| **Comments** | コードの不備を補うためのコメント（良いコメントは除く） | Extract Function, Change Function Declaration, Introduce Assertion |
| **Loops** | 古典的なループが宣言的パイプラインで置換可能 | Replace Loop with Pipeline |
| **Dead Code** | 使われていないコード | Remove Dead Code |

### 4.2 Smell と Smell の関係

Smell は孤立して存在しない。Long Function はしばしば Duplicated Code、Feature Envy、Data Clumps を内包している。一つの Smell を解消すると、他の Smell が顕在化することがある。重要なのは、**Smell は問題そのものではなく、問題の兆候**であるということ。Smell を検出したら、その背後にある設計上の問題を考える。

---

## 5. リファクタリングカタログ

Fowler の第 2 版には約 60 のリファクタリングが収録されている。ここではカテゴリごとに主要なものを整理する。

### 5.1 基本リファクタリング（Most Common）

Fowler が「最初に学ぶべき」として特別な章にまとめたリファクタリング群：

| リファクタリング | 方向 | 説明 |
|----------------|------|------|
| **Extract Function** | 分離 | コードの断片を新しい関数に抽出し、意図を表す名前をつける |
| **Inline Function** | 統合 | 関数本体が名前と同じくらい明確なとき、呼び出し元に展開する |
| **Extract Variable** | 分離 | 複雑な式に名前をつけて中間変数に代入する |
| **Inline Variable** | 統合 | 変数名が式より表現力がないとき、式で直接置換する |
| **Change Function Declaration** | 変更 | 関数名やパラメータリストを変更する |
| **Encapsulate Variable** | 隠蔽 | 広くアクセスされるデータをアクセサ関数で包む |
| **Rename Variable** | 明確化 | 変数により良い名前をつける |
| **Introduce Parameter Object** | 構造化 | よく一緒に渡されるパラメータ群をオブジェクトにまとめる |
| **Combine Functions into Class** | 構造化 | 同じデータを操作する関数群をクラスにまとめる |
| **Combine Functions into Transform** | 構造化 | データを読んで派生値を計算する関数群を変換関数にまとめる |
| **Split Phase** | 分離 | 異なることを行うコードを別々のフェーズに分ける |

### 5.2 カプセル化

| リファクタリング | 説明 |
|----------------|------|
| **Encapsulate Record** | レコード構造をデータクラスに変換し、アクセスを制御する |
| **Encapsulate Collection** | コレクションへの直接アクセスをアクセサで置換し、変更を制御する |
| **Replace Primitive with Object** | プリミティブ値をドメインオブジェクトに置換する |
| **Replace Temp with Query** | 一時変数を計算を行う関数呼び出しで置換する |
| **Extract Class** | 1 つのクラスが担う責務の一部を新しいクラスに分離する |
| **Inline Class** | 価値のないクラスの内容を別のクラスにマージする |
| **Hide Delegate** | クライアントが知る必要のない委譲先オブジェクトを隠す |
| **Remove Middle Man** | 過度な委譲を取り除き、クライアントが直接アクセスする |

### 5.3 フィーチャーの移動

| リファクタリング | 説明 |
|----------------|------|
| **Move Function** | 関数を最もよく使うコンテキストに移動する |
| **Move Field** | フィールドを最もよく使われるクラスに移動する |
| **Move Statements into Function** | 関数の前後で常に実行される文を関数内に移動する |
| **Move Statements to Callers** | 関数が異なる呼び出し元で異なる振る舞いを必要とする場合、文を呼び出し元に移動する |
| **Replace Inline Code with Function Call** | 既存の関数と同じことをするインラインコードを関数呼び出しで置換する |
| **Slide Statements** | 関連するコード行を近くに移動する |
| **Split Loop** | 異なることを行うループを 2 つのループに分ける |
| **Replace Loop with Pipeline** | ループを filter/map などのパイプライン操作で置換する |
| **Remove Dead Code** | 使われていないコードを削除する |

### 5.4 データの整理

| リファクタリング | 説明 |
|----------------|------|
| **Split Variable** | 複数の役割を持つ変数を、役割ごとに別の変数に分ける |
| **Rename Field** | フィールドにより良い名前をつける |
| **Replace Derived Variable with Query** | 派生的に計算可能な変数を、計算で置換する |
| **Change Reference to Value** | 参照オブジェクトを値オブジェクトに変更する |
| **Change Value to Reference** | 値オブジェクトを参照オブジェクトに変更する |

### 5.5 条件ロジックの簡略化

| リファクタリング | 説明 |
|----------------|------|
| **Decompose Conditional** | 複雑な条件式を、条件・ then 節・ else 節それぞれを関数に抽出する |
| **Consolidate Conditional Expression** | 同じ結果を持つ条件を 1 つの条件式にまとめる |
| **Replace Nested Conditional with Guard Clauses** | ネストした条件をガード節で平坦化する |
| **Replace Conditional with Polymorphism** | 条件分岐をポリモーフィズムで置換する |
| **Introduce Special Case** | 特殊ケースの条件チェックを Special Case オブジェクトで置換する |
| **Introduce Assertion** | コードの前提条件をアサーションで明示する |

### 5.6 API のリファクタリング

| リファクタリング | 説明 |
|----------------|------|
| **Separate Query from Modifier** | 値を返しかつ副作用を持つ関数を、クエリとコマンドに分離する |
| **Parameterize Function** | 類似した処理を行う複数の関数をパラメータ化して 1 つにまとめる |
| **Remove Flag Argument** | boolean フラグ引数をそれぞれの関数に分離する |
| **Preserve Whole Object** | オブジェクトから複数の値を取り出して渡す代わりに、オブジェクト自体を渡す |
| **Replace Parameter with Query** | パラメータの値が受信者自身で計算できるとき、パラメータを削除する |
| **Replace Query with Parameter** | 関数内での参照を避けるため、値を呼び出し元から渡す |
| **Remove Setting Method** | フィールドの設定メソッドを削除し、コンストラクタでのみ設定可能にする |
| **Replace Constructor with Factory Function** | コンストラクタをファクトリ関数で置換する |
| **Replace Function with Command** | 関数をコマンドオブジェクトに変換する |
| **Replace Command with Function** | コマンドオブジェクトを単純な関数に戻す |

### 5.7 継承の扱い

| リファクタリング | 説明 |
|----------------|------|
| **Pull Up Method** | サブクラスの同一メソッドをスーパークラスに移動する |
| **Pull Up Field** | サブクラスの同一フィールドをスーパークラスに移動する |
| **Pull Up Constructor Body** | サブクラスのコンストラクタの共通部分をスーパークラスに移動する |
| **Push Down Method** | スーパークラスのメソッドを、それを使うサブクラスに移動する |
| **Push Down Field** | スーパークラスのフィールドを、それを使うサブクラスに移動する |
| **Replace Type Code with Subclasses** | 型コードをサブクラスで置換する |
| **Remove Subclass** | 価値のないサブクラスをスーパークラスのフィールドに置換する |
| **Extract Superclass** | 類似したクラスからスーパークラスを抽出する |
| **Collapse Hierarchy** | スーパークラスとサブクラスの差がほとんどないとき、統合する |
| **Replace Subclass with Delegate** | サブクラスによる変化を委譲で置換する |
| **Replace Superclass with Delegate** | 不適切な継承を委譲で置換する |

---

## 6. Refactoring to Patterns：パターンへの進化

### 6.1 概要

Joshua Kerievsky の『Refactoring to Patterns』（2004）は、Fowler のリファクタリングと GoF のデザインパターンを橋渡しする書籍である。27 のパターン指向リファクタリングと 12 のデザイン Smell を収録している。

中心的な主張は、**パターンは事前に設計するものではなく、コードの進化の中で必要になったときにリファクタリングによって導入すべき**というもの。Fowler の序文でも「パターンは事前にデザインする必要はなく、システムの成長に応じて進化させればよい」と述べている。

### 6.2 3 つの方向

Kerievsky はパターン指向リファクタリングの方向を 3 つに分類している：

- **Refactoring TO a pattern** — コードをパターンの実装に向けて変換する（例：Replace Conditional Logic with Strategy）
- **Refactoring TOWARDS a pattern** — パターンの完全な実装ではなく、その方向に一歩進める
- **Refactoring AWAY from a pattern** — 過度に複雑なパターン実装を簡素化する

3 番目の方向が重要で、パターンは常に正しいわけではないという認識を示している。YAGNI 原則に基づき、不要な複雑さは取り除く。

### 6.3 代表的なパターン指向リファクタリング

| リファクタリング | 対象パターン | 概要 |
|----------------|------------|------|
| Replace Constructors with Creation Methods | Factory Method | コンストラクタの意図を明確にする |
| Move Accumulation to Collecting Parameter | Collecting Parameter | 蓄積ロジックをパラメータオブジェクトに移動 |
| Replace Conditional Logic with Strategy | Strategy | 条件分岐を Strategy オブジェクトで置換 |
| Form Template Method | Template Method | サブクラスの類似メソッドをテンプレートメソッドに統合 |
| Replace State-Altering Conditionals with State | State | 状態遷移の条件分岐を State パターンで置換 |
| Replace Implicit Tree with Composite | Composite | 暗黙的なツリー構造を Composite パターンで明示化 |
| Encapsulate Composite with Builder | Builder | 複雑な Composite 構築を Builder で隠蔽 |
| Move Embellishment to Decorator | Decorator | 装飾的な振る舞いを Decorator に分離 |
| Replace Type Code with Class | — | 型コードをクラスで置換（Fowler の基本リファクタリングの拡張） |
| Unify Interfaces with Adapter | Adapter | 異なるインターフェースを Adapter で統一 |

---

## 7. レガシーコードにおけるリファクタリング

### 7.1 Feathers の定義

Michael Feathers は『Working Effectively with Legacy Code』において、レガシーコードを「テストのないコード」と定義した。テストがなければ、リファクタリングが振る舞いを保存したかどうかを確認できない。したがってレガシーコードのリファクタリングには、テストの追加が先行する必要がある。

### 7.2 The Legacy Code Change Algorithm

Feathers が提示する、レガシーコードを変更するための基本アルゴリズム：

1. **変更点を特定する** — 何を変更する必要があるかを理解する
2. **テストポイントを見つける** — テストを書ける場所を特定する
3. **依存関係を断ち切る** — テスト可能にするために依存関係を解消する
4. **テストを書く** — 現在の振る舞いを記録する Characterization Test を書く
5. **変更を加えてリファクタリングする** — テストの安全網の下で変更する

### 7.3 Seam モデル

Seam とは、コードを直接編集せずに振る舞いを変えられるポイントである。レガシーコードでテストを書くための鍵となる概念。

- **Object Seam** — オブジェクトの差し替え（インターフェースやサブクラスを通じて）
- **Preprocessing Seam** — プリプロセッサによる差し替え（主に C/C++）
- **Link Seam** — リンク時の差し替え（ライブラリやモジュールの入れ替え）

### 7.4 依存関係を断ち切る 24 のテクニック

Feathers は 24 の依存関係解消テクニックをカタログ化している。代表的なものを示す：

| テクニック | 説明 |
|-----------|------|
| **Parameterize Constructor** | コンストラクタで依存オブジェクトを受け取れるようにする |
| **Parameterize Method** | メソッドで依存オブジェクトを受け取れるようにする |
| **Extract and Override Call** | 依存する呼び出しをメソッドに抽出し、テスト用サブクラスでオーバーライドする |
| **Extract and Override Factory Method** | オブジェクト生成をファクトリメソッドに抽出し、オーバーライドする |
| **Extract Interface** | 依存先のインターフェースを抽出し、テスト用のフェイクを作れるようにする |
| **Introduce Instance Delegator** | 静的メソッドの呼び出しをインスタンスメソッド経由にする |
| **Sprout Method** | 新しい振る舞いを既存メソッドに追加する代わりに、新しいメソッドとして生やす |
| **Sprout Class** | 新しい振る舞いを新しいクラスとして生やす |
| **Wrap Method** | 既存メソッドの前後に処理を追加するために、ラッパーメソッドを作る |
| **Wrap Class** | Decorator パターンで既存クラスをラップする |
| **Subclass and Override Method** | テスト用のサブクラスを作り、問題のあるメソッドをオーバーライドする |
| **Replace Global Reference with Getter** | グローバル参照を Getter メソッド経由にし、テスト時に差し替え可能にする |

### 7.5 Strangler Fig Pattern

大規模なレガシーシステムのリファクタリングには、Martin Fowler が命名した Strangler Fig Pattern（絞殺イチジクパターン）が有効。既存システムの外側に新しい実装を構築し、徐々にトラフィックを新しい実装に移行する。古いシステムは新しいシステムに「絞め殺される」。

Branch By Abstraction との組み合わせ：新しい抽象レイヤーを導入し、既存実装と新実装の両方をその抽象レイヤーの下に置く。呼び出し側は抽象レイヤーだけを知っているため、実装の切り替えが透明になる。

---

## 8. リファクタリングの判断フレーム

### 8.1 いつリファクタリングするか

Fowler のワークフロー分類に基づく判断基準：

| タイミング | 判断基準 | 注意点 |
|-----------|---------|--------|
| **TDD Refactor** | テストが通った直後 | 常に行う。最も安全で最も頻度が高い |
| **Comprehension** | コードを読んで「あ、そうか」と理解したとき | 理解をコードに移す。Cunningham の原則 |
| **Litter-Pickup** | 作業中に小さな問題を見つけたとき | 1-2 分で終わるものに限定 |
| **Preparatory** | 機能追加の前に構造を整えたいとき | 即座に元が取れることが多い |
| **Planned** | 大きな構造的問題があるとき | Hotspot Analysis で優先順位をつける |
| **Long-Term** | ライブラリ置換やモジュール分割 | Branch By Abstraction を使う |

### 8.2 いつリファクタリングしないか

Fowler は以下の場合にリファクタリングを推奨しない：

- **変更する必要のない醜いコード** — 触らないコードは放置してよい
- **書き直した方が簡単なコード** — リファクタリングよりリライトが適切な場合もある（判断は難しいので、タイムボックスで比較する）
- **Clean Code のためだけのリファクタリング** — 美しさではなく経済性が動機であるべき。変更を高速に保つことがゴール

### 8.3 Rule of Three（Don Roberts）

1 回目 — ただやる。
2 回目 — 重複に気づくが、そのままやる。
3 回目 — リファクタリングする。

### 8.4 Smell からリファクタリングへのフロー Chart

```
コードに触れる
  │
  ├─ 名前が不明瞭？ → Rename / Change Function Declaration
  │
  ├─ 関数が長い？ → Extract Function
  │    └─ 抽出した関数が別のクラスに属する？ → Move Function
  │
  ├─ 重複がある？ → Extract Function + Pull Up Method
  │
  ├─ 条件分岐が複雑？
  │    ├─ 同じ条件が複数箇所？ → Replace Conditional with Polymorphism
  │    ├─ ネストが深い？ → Replace Nested Conditional with Guard Clauses
  │    └─ 条件式自体が複雑？ → Decompose Conditional
  │
  ├─ データがプリミティブ？ → Replace Primitive with Object
  │
  ├─ パラメータが多い？ → Introduce Parameter Object / Preserve Whole Object
  │
  └─ クラスが大きい？ → Extract Class / Extract Superclass
```

### 8.5 コードリーディングとの接続

前回のコードリーディングレポートのテクニックとの対応：

| コードリーディングテクニック | 接続するリファクタリングワークフロー |
|--------------------------|----------------------------------|
| Scratch Refactoring（Feathers） | 理解のためだけのリファクタリング。結果は捨てるが、得た理解は Comprehension Refactoring として保存可能 |
| Beacon-driven Reading | Beacon の不在＝Mysterious Name Smell の兆候。Rename Variable / Change Function Declaration |
| Telling the Story | ストーリーが語れない箇所＝Long Function / Large Class / Feature Envy |
| Why/How/What Conjectures | 「Why」が不明な箇所には Comment を追加するか、Extract Function で意図を名前に反映 |
| Characterization Test（Feathers） | レガシーコードリファクタリングの前提条件。The Legacy Code Change Algorithm のステップ 4 |

---

## 9. 参考文献

- Fowler, M. (2018). *Refactoring: Improving the Design of Existing Code*, 2nd ed. Addison-Wesley.
- Fowler, M. (2011). Opportunistic Refactoring. martinfowler.com.
- Fowler, M. (2014). Workflows of Refactoring. martinfowler.com.
- Feathers, M. (2004). *Working Effectively with Legacy Code*. Prentice Hall.
- Kerievsky, J. (2004). *Refactoring to Patterns*. Addison-Wesley.
- McConnell, S. (2004). *Code Complete*, 2nd ed. Microsoft Press.
- Martin, R.C. (2008). *Clean Code*. Prentice Hall.
- Beck, K. (2002). *Test-Driven Development: By Example*. Addison-Wesley.
- Gamma, E., Helm, R., Johnson, R. & Vlissides, J. (1994). *Design Patterns*. Addison-Wesley.

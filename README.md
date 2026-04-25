# Language / 语言
* [I. 简体中文](#I.简体中文)
* [II. English](#II.English)
* [III. Italiano](#III.Italiano)
* [IV. 日本語](#IV.日本語)
* [V. 한국어](#V.한국어)
---

## I.简体中文

# 阅读记录 (Reading Records) 项目文档
本项目是一款基于 iOS 平台开发的数字化阅读管理工具，旨在为用户提供高效、私密的阅读进度追踪与数据管理方案。系统采用 Apple 最新的 SwiftUI 框架与 SwiftData 持久化引擎构建，遵循 MVVM 架构设计模式。

### 1. 项目概述
 * **开发日期**: 2026年4月18日至2026年4月25日
 * **核心目标**: 解决用户在多书籍阅读过程中进度难量化、数据易丢失的问题。

### 2. 技术栈与环境要求
#### 2.1 技术规格
 * **编程语言**: Swift 5.10
 * **界面框架**: SwiftUI
 * **持久化层**: SwiftData (Core Data 演进版)
 * **导出格式**: JSON (JavaScript Object Notation)
 * **通讯组件**: MessageUI (用于邮件反馈系统)

#### 2.2 运行环境
 * **IDE**: Xcode 17.0 或更高版本
 * **操作系统**: iOS 17.0 或更高版本
 * **硬件建议**: iPhone 15 Pro 或以上机型模拟器/真机

### 3. 功能模块说明
#### 3.1 书籍与进度管理
 * **结构化存储**: 存储书籍元数据（标题、作者、出版社、ISBN 关联信息）。
 * **原子化记录**: 每一条阅读进展都被记录为独立的 `ReadingLog` 对象，系统通过聚合算法实时计算当前页码与百分比进度。
 * **级联处理**: 采用 `@Relationship(deleteRule: .cascade)`，确保书籍删除时关联的阅读日志同步销毁，维护数据库引用完整性。

#### 3.2 数据备份与恢复 (Data Portability)
 * **导出逻辑**: 将 `[Book]` 对象图完整序列化为 JSON 字符串，并支持通过 `UIActivityViewController` 进行跨设备分享。
 * **导入逻辑**: 支持 `.fileImporter` 系统级文件选择，集成安全访问权限管理（Security-Scoped Resources），实现全量数据恢复。

#### 3.3 多语言国际化 (i18n)
 * **动态切换**: 独立于系统设置的多语言切换逻辑，支持 **简体中文**、**English**、**Italiano**、**日本語**、**한국어**。
 * **资源管理**: 基于 String Catalogs (`.xcstrings`) 实现高精度的词条匹配。

### 4. 项目目录结构
```
./
├── 阅读记录/                 # 主程序目录
│   ├── ____App.swift       # 应用生命周期入口
│   ├── Models/             # 核心数据模型 (Book, ReadingInsights)
│   ├── Views/              # UI 视图层
│   │   ├── ContentView.swift & MainTabView.swift
│   │   ├── Book/           # 书籍列表、详情编辑及进度组件
│   │   ├── History/        # 阅读历史回顾与标签管理
│   │   ├── Profile/        # 用户设置、数据管理及反馈系统
│   │   └── Statistics/     # 统计图表、成就徽章与时间轴
│   ├── Managers/           # 业务逻辑层 (DataManager, LanguageManager)
│   ├── Resources/          # 本地化字符串 (Localizable.xcstrings)
│   └── Assets.xcassets/    # 静态资源 (应用图标、颜色、占位图)
├── 阅读记录.xcodeproj        # Xcode 工程配置文件
├── 阅读记录Tests/            # 单元测试模块
└── 阅读记录UITests/          # UI自动化测试模块
```

### 5. 安装与运行指南
获取源码: 解压 阅读记录.zip 压缩包。

启动工程: 双击项目根目录下的 阅读记录.xcodeproj 文件。

配置环境: 在 Xcode 顶部工具栏选择一个合适的 iOS 17+ 模拟器（推荐 iPhone 15 Pro）。

编译运行: 按下 Command + R 启动应用。

数据测试: 若需测试导入功能，可使用本项目附带的示例 JSON 文件进行测试。

### 6. 开发规范总结
性能优化: 使用 @Query 属性包装器实现高效的数据库响应式检索。

安全性: 导入过程中实施严格的类型校验与异常捕获（do-catch 机制），防止损坏的 JSON 文件导致程序崩溃。

交互规范: 关键操作集成 UIImpactFeedbackGenerator 触感反馈，确保操作的可感知性。

### 7. 参考资料与致谢 (References & Acknowledgments)

在本项目开发及演示文档制作过程中，我们参考了以下开源项目、技术文档及 AI 工具，向相关作者与机构表示诚挚感谢：

#### 7.1 技术文档与语言规范
* **[Swift 官方文档 (中文版)](https://swift.readthedocs.io/zh-cn/latest/)**：本项目核心逻辑、语法规范及工程架构的主要参考来源。
* **[Apple Developer Documentation](https://developer.apple.com/documentation/)**：深入学习了 SwiftUI 框架、SwiftData 数据库管理以及 iOS 系统底层 API 的使用。

#### 7.2 AI 辅助协作
* **[Google Gemini](https://gemini.google.com/)**：作为本项目的 **AI 辅助开发者**，Gemini 在代码重构、多语言本地化翻译（IT/JA/KO）、逻辑漏洞排查及文档编写方面提供了关键支持。
* **[Nano Banana 2 (Gemini 3 Flash Image)](https://gemini.google.com/)**：辅助生成了 App 的原始视觉素材、UI 概念设计及图标草图。

### 8. 许可与申明 (License & Statements)

#### 8.1 开源许可
* 本项目采用 **[MIT License](LICENSE)** 进行许可。你可以自由地使用、复制、修改和分发本软件，但须保留原始版权声明和许可声明。

#### 8.2 学术申明
* 本项目仅用于 **学术交流** 及 **课程作业提交**。
* 开发者不对因使用本软件而产生的任何直接或间接损失负责。

---

# II.English

# Reading Records - Project Documentation
This project is a digital reading management tool developed for the iOS platform, designed to provide users with an efficient and private solution for tracking reading progress and managing data. The system is built using Apple's latest SwiftUI framework and SwiftData persistence engine, strictly following the MVVM architectural pattern.

### 1. Project Overview
Development Date: April 18, 2026 – April 25, 2026

Core Objective: To solve the issues of difficulty in quantifying progress and the risk of data loss during multi-book reading sessions.

### 2. Tech Stack & Requirements

#### 2.1 Technical Specifications
Language: Swift 5.10

UI Framework: SwiftUI

Persistence Layer: SwiftData (The evolution of Core Data)

Export Format: JSON (JavaScript Object Notation)

Communication: MessageUI (For the email feedback system)

#### 2.2 Runtime Environment
IDE: Xcode 17.0 or higher

OS: iOS 17.0 or higher

Hardware: iPhone 15 Pro or above (Simulator or Physical Device)

### 3. Functional Modules

#### 3.1 Book & Progress Management
Structured Storage: Stores book metadata including title, author, publisher, and ISBN-related information.

Atomic Logging: Every piece of reading progress is recorded as an independent ReadingLog object. The system calculates current page numbers and percentage progress in real-time via aggregation algorithms.

Cascade Handling: Utilizes @Relationship(deleteRule: .cascade) to ensure that associated reading logs are automatically destroyed when a book is deleted, maintaining database referential integrity.

#### 3.2 Data Portability (Backup & Recovery)
Export Logic: Serializes the full [Book] object graph into a JSON string, supporting cross-device sharing via UIActivityViewController.

Import Logic: Supports .fileImporter for system-level file selection, integrating Security-Scoped Resources management to achieve full data restoration.

#### 3.3 Internationalization (i18n)
Dynamic Switching: An in-app language switching logic independent of system settings, supporting Simplified Chinese, English, Italiano, Japanese, and Korean.

Resource Management: High-precision string matching implemented via String Catalogs (.xcstrings).

4. Project Directory Structure

```
./
├── 阅读记录/                 # Main App Directory
│   ├── ____App.swift       # App Entry Point
│   ├── Models/             # Core Data Models (Book, ReadingInsights)
│   ├── Views/              # UI Presentation Layer
│   │   ├── ContentView.swift & MainTabView.swift
│   │   ├── Book/           # Book lists, detail editing, and progress components
│   │   ├── History/        # Reading history review and tag management
│   │   ├── Profile/        # User settings, data management, and feedback system
│   │   └── Statistics/     # Statistics charts, badges, and timeline
│   ├── Managers/           # Business Logic Layer (DataManager, LanguageManager)
│   ├── Resources/          # Localization Strings (Localizable.xcstrings)
│   └── Assets.xcassets/    # Static Assets (Icons, Colors)
├── 阅读记录.xcodeproj        # Xcode Project File
├── 阅读记录Tests/            # Unit Tests
└── 阅读记录UITests/          # UI Tests
```

### 5. Installation & Usage Guide
Acquire Source: Decompress the 阅读记录.zip archive.

Launch Project: Double-click the 阅读记录.xcodeproj file in the root directory.

Configure Environment: Select a suitable iOS 17+ simulator (iPhone 15 Pro recommended) from the Xcode toolbar.

Build & Run: Press Command + R to launch the application.

Data Testing: To test the import function, you may use the provided sample JSON file included in the project.

### 6. Development Standards Summary
Performance Optimization: Implements efficient, responsive database retrieval using the @Query property wrapper.

Security: Enforces strict type validation and exception handling (do-catch mechanisms) during the import process to prevent application crashes caused by corrupted JSON files.

Interaction Standards: Integrates UIImpactFeedbackGenerator for haptic feedback on key operations to enhance user perceptibility.

### 7. References & Acknowledgments

#### 7.1 Technical Documentation & Language Standards
* **[Swift Documentation (Chinese Edition)](https://swift.readthedocs.io/zh-cn/latest/)**: The primary reference for core logic, syntax standards, and engineering architecture.
* **[Apple Developer Documentation](https://developer.apple.com/documentation/)**: In-depth resource for SwiftUI framework, SwiftData persistence, and iOS system APIs.

#### 7.2 AI-Assisted Collaboration
* **[Google Gemini](https://gemini.google.com/)**: As an **AI-Assisted Developer**, Gemini provided critical support in code refactoring, localization (IT/JA/KO), logic debugging, and documentation.
* **[Nano Banana 2 (Gemini 3 Flash Image)](https://gemini.google.com/)**: Assisted in generating original visual assets, UI concept designs, and App icon sketches.

### 8. License & Statements

#### 8.1 Open Source License
* This project is licensed under the **[MIT License](LICENSE)**. You are free to use, copy, modify, and distribute this software, provided that the original copyright and license notice are included.

#### 8.2 Academic Statement
* This project is intended for **academic exchange** and **coursework submission** purposes only.
* The developers are not responsible for any direct or indirect losses incurred from the use of this software.

---

# III.Italiano

# Reading Records - Documentazione del Progetto
Questo progetto è uno strumento digitale per la gestione della lettura sviluppato per la piattaforma iOS. È progettato per offrire agli utenti una soluzione efficiente e privata per il monitoraggio dei progressi di lettura e la gestione dei dati. Il sistema è basato sul framework SwiftUI di Apple e sul motore di persistenza SwiftData, seguendo rigorosamente il pattern architetturale MVVM.

### 1. Panoramica del Progetto
Data di Sviluppo: 18 aprile 2026 – 25 aprile 2026

Obiettivo Core: Risolvere le difficoltà nella quantificazione dei progressi e il rischio di perdita dei dati durante la lettura di più libri contemporaneamente.

### 2. Stack Tecnologico e Requisiti

#### 2.1 Specifiche Tecniche
Linguaggio: Swift 5.10

Framework UI: SwiftUI

Livello di Persistenza: SwiftData (evoluzione di Core Data)

Formato di Esportazione: JSON (JavaScript Object Notation)

Comunicazione: MessageUI (per il sistema di feedback via email)

#### 2.2 Ambiente di Esecuzione
IDE: Xcode 17.0 o superiore

Sistema Operativo: iOS 17.0 o superiore

Hardware Consigliato: Simulatore o dispositivo fisico iPhone 15 Pro o superiore

### 3. Moduli Funzionali

#### 3.1 Gestione Libri e Progressi
Archiviazione Strutturata: Memorizza i metadati dei libri, inclusi titolo, autore, editore e informazioni relative all'ISBN.

Registrazione Atomica: Ogni progresso di lettura viene registrato come un oggetto ReadingLog indipendente. Il sistema calcola il numero di pagina corrente e la percentuale di avanzamento in tempo reale tramite algoritmi di aggregazione.

Gestione a Cascata: Utilizza @Relationship(deleteRule: .cascade) per garantire che i log di lettura associati vengano distrutti automaticamente alla cancellazione di un libro.

#### 3.2 Portabilità dei Dati (Backup e Ripristino)
Logica di Esportazione: Serializza l'intero grafo di oggetti [Book] in una stringa JSON, supportando la condivisione tra dispositivi tramite UIActivityViewController.

Logica di Importazione: Supporta .fileImporter per la selezione dei file a livello di sistema, integrando la gestione dei permessi di accesso sicuro.

#### 3.3 Internazionalizzazione (i18n)
Cambio Dinamico: Logica di cambio lingua in-app indipendente dalle impostazioni di sistema, con supporto per Cinese Semplificato, Inglese, Italiano, Giapponese e Coreano.

Gestione Risorse: Localizzazione implementata tramite String Catalogs (.xcstrings).

### 4. Struttura della Directory del Progetto
```
./
├── 阅读记录/                 # Directory Principale
│   ├── ____App.swift       # Punto di Ingresso
│   ├── Models/             # Modelli Dati Core
│   ├── Views/              # Livello di Presentazione UI
│   │   ├── ContentView.swift & MainTabView.swift
│   │   ├── Book/           # Gestione Libri
│   │   ├── History/        # Cronologia Lettura
│   │   ├── Profile/        # Profilo Utente
│   │   └── Statistics/     # Statistiche e Badge
│   ├── Managers/           # Logica di Business
│   ├── Resources/          # Stringhe Localizzate (.xcstrings)
│   └── Assets.xcassets/    # Risorse Statiche
├── 阅读记录.xcodeproj        # File di Progetto Xcode
├── 阅读记录Tests/            # Test Unitari
└── 阅读记录UITests/          # Test UI
```

### 5. Guida all'Installazione e all'Uso
Acquisizione Sorgenti: Decomprimere l'archivio 阅读记录.zip.

Avvio Progetto: Fare doppio clic sul file 阅读记录.xcodeproj nella directory principale.

Configurazione Ambiente: Selezionare un simulatore iOS 17+ adatto dalla barra degli strumenti di Xcode.

Compilazione ed Esecuzione: Premere Command + R per avviare l'applicazione.

### 6. Sintesi degli Standard di Sviluppo
Ottimizzazione delle Prestazioni: Implementa il recupero reattivo dei dati tramite @Query.

Sicurezza: Applica una stretta validazione dei tipi e la gestione delle eccezioni durante il processo di importazione.

Standard di Interazione: Integra UIImpactFeedbackGenerator per il feedback aptico.

### 7. Riferimenti e Ringraziamenti

#### 7.1 Documentazione Tecnica e Standard
* **[Documentazione Swift (Cinese)](https://swift.readthedocs.io/zh-cn/latest/)**: Riferimento principale per la logica di base e l'architettura del progetto.
* **[Apple Developer Documentation](https://developer.apple.com/documentation/)**: Approfondimento sul framework SwiftUI, SwiftData e le API di sistema iOS.

#### 7.2 Collaborazione con IA
* **[Google Gemini](https://gemini.google.com/)**: Come **Assistente alla Programmazione**, Gemini ha fornito supporto per il refactoring del codice, la localizzazione, il debugging e la stesura della documentazione.
* **[Nano Banana 2 (Gemini 3 Flash Image)](https://gemini.google.com/)**: Ha assistito nella generazione di asset visivi, concept design della UI e bozzetti per l'icona dell'App.

### 8. Licenza e Dichiarazioni

#### 8.1 Licenza Open Source
* Questo progetto è rilasciato sotto la licenza **[MIT License](LICENSE)**. Sei libero di utilizzare, copiare, modificare e distribuire questo software, a condizione che vengano inclusi l'avviso di copyright e la licenza originale.

#### 8.2 Dichiarazione Accademica
* Questo progetto è destinato esclusivamente allo **scambio accademico** e alla **consegna di compiti scolastici**.
* Gli sviluppatori non sono responsabili per eventuali perdite dirette o indirette derivanti dall'uso di questo software.

---

# IV.日本語

# 阅读记录 (Reading Records) プロジェクトドキュメント
本プロジェクトは、iOSプラットフォーム向けに開発されたデジタル読書管理ツールであり、ユーザーに効率的かつプライベートな読書進捗の追跡とデータ管理ソリューションを提供することを目的としています。Appleの最新フレームワークである SwiftUI とデータ永続化エンジン SwiftData を使用し、MVVM アーキテクチャパターンに従って構築されています。

### 1. プロジェクト概要
開発期間: 2026年4月18日 ～ 2026年4月25日

コア目標: 複数の書籍を読む際の進捗の定量化の難しさやデータ紛失のリスクを解決する。

### 2. 技術スタックと環境要件

#### 2.1 技術仕様
プログラミング言語: Swift 5.10

UIフレームワーク: SwiftUI

データ永続化: SwiftData (Core Dataの進化版)

エクスポート形式: JSON (JavaScript Object Notation)

通信コンポーネント: MessageUI (フィードバックメールシステム用)

#### 2.2 実行環境
IDE: Xcode 17.0 以上

OS: iOS 17.0 以上

推奨ハードウェア: iPhone 15 Pro 以上のシミュレータまたは実機

### 3. 機能モジュールの説明

#### 3.1 書籍と進捗管理
構造化ストレージ: タイトル、著者、出版社、ISBN関連情報を含む書籍メタデータを保存。

アトミック記録: 各読書進捗は独立した ReadingLog オブジェクトとして記録され、システムが集計アルゴリズムを通じて現在のページ数やパーセンテージをリアルタイムで計算します。

カスケード処理: @Relationship(deleteRule: .cascade) を採用し、書籍が削除された際に関連する読書ログも自動的に破棄され、データベースの整合性を維持します。

#### 3.2 データのバックアップと復元 (Data Portability)
エクスポート機能: [Book] オブジェクト全体をJSON文字列としてシリアライズし、UIActivityViewController を介したクロスデバイス共有をサポート。

インポート機能: .fileImporter によるシステムレベルのファイル選択をサポートし、完全なデータ復元を実現。

#### 3.3 多言語対応 (i18n)
動的切り替え: システム設定に依存しないアプリ内の言語切り替え機能。簡体字中国語、英語、イタリア語、日本語、韓国語をサポート。

リソース管理: String Catalogs (.xcstrings) に基づく高精度なローカライズ。

### 4. プロジェクトのディレクトリ構造
```
./
├── 阅读记录/                 # メインアプリディレクトリ
│   ├── ____App.swift       # アプリのエントリーポイント
│   ├── Models/             # コアデータモデル (Book, ReadingInsights)
│   ├── Views/              # UIプレゼンテーション層
│   │   ├── ContentView.swift & MainTabView.swift
│   │   ├── Book/           # 書籍リスト、編集、進捗コンポーネント
│   │   ├── History/        # 読書履歴とタグ管理
│   │   ├── Profile/        # ユーザー設定とデータ管理
│   │   └── Statistics/     # 統計グラフ、バッジ、タイムライン
│   ├── Managers/           # ビジネスロジック層
│   ├── Resources/          # ローカライズ文字列 (Localizable.xcstrings)
│   └── Assets.xcassets/    # 静的アセット (アイコン、カラー)
├── 阅读记录.xcodeproj        # Xcodeプロジェクトファイル
├── 阅读记录Tests/            # ユニットテスト
└── 阅读记录UITests/          # UIテスト
```

### 5. インストールと実行ガイド
ソースの取得: 阅读记录.zip を解凍します。

プロジェクトの起動: ルートディレクトリにある 阅读记录.xcodeproj をダブルクリックします。

環境の設定: Xcode上部のツールバーから適切な iOS 17+ シミュレータ（iPhone 15 Pro推奨）を選択します。

ビルドと実行: Command + R を押してアプリを起動します。

### 6. 開発規範のまとめ
パフォーマンス最適化: @Query プロパティラッパーを使用し、効率的なデータベース検索を実装。

安全性: インポートプロセス中に厳密な型検証と例外キャッチ（do-catch）を実施。

インタラクション: UIImpactFeedbackGenerator を統合し、操作の触覚フィードバックを提供。

### 7. 参考文献と謝辞

#### 7.1 技術ドキュメントと言語仕様
* **[Swift 開発ドキュメント (中国語版)](https://swift.readthedocs.io/zh-cn/latest/)**: プロジェクトのコアロジック、構文、および設計アーキテクチャの主な参照先。
* **[Apple Developer Documentation](https://developer.apple.com/documentation/)**: SwiftUI フレームワーク、SwiftData、および iOS システム API の詳細な学習。

#### 7.2 AI支援協力
* **[Google Gemini](https://gemini.google.com/)**: **AIアシスタントデベロッパー** として、コードのリファクタリング、多言語ローカライズ（IT/JA/KO）、デバッグ、およびドキュメント作成を支援。
* **[Nano Banana 2 (Gemini 3 Flash Image)](https://gemini.google.com/)**: アプリのビジュアルアセット、UIコンセプトデザイン、およびアイコン草案の生成を補助。

### 8. ライセンスと宣言

#### 8.1 オープンソースライセンス
* 本プロジェクトは **[MIT License](LICENSE)** の下でライセンスされています。元の著作権表示およびライセンス表示を保持することを条件に、本ソフトウェアを自由に利用、複製、修正、配布することができます。

#### 8.2 学術的宣言
* 本プロジェクトは、**学術交流** および **課題提出** の目的のみに使用されます。
* 開発者は、本ソフトウェアの使用によって生じた直接的または間接的な損失について、一切の責任を負いません。

---

# V.한국어

# 阅读记录 (Reading Records) 프로젝트 문서
이 프로젝트는 iOS 플랫폼을 위해 개발된 디지털 독서 관리 도구로, 사용자에게 효율적이고 개인적인 독서 진행률 추적 및 데이터 관리 솔루션을 제공하는 것을 목표로 합니다. 이 시스템은 Apple의 최신 SwiftUI 프레임워크와 SwiftData 데이터베이스를 사용하여 구축되었으며, MVVM 아키텍처 패턴을 엄격하게 따릅니다.

### 1. 프로젝트 개요
개발 기간: 2026년 4월 18일 ~ 2026년 4월 25일

핵심 목표: 다수의 책을 읽을 때 진행률을 정량화하기 어렵고 데이터가 손실되기 쉬운 문제를 해결합니다.

### 2. 기술 스택 및 환경 요구 사항

#### 2.1 기술 사양
프로그래밍 언어: Swift 5.10

UI 프레임워크: SwiftUI

데이터베이스: SwiftData (Core Data의 발전형)

내보내기 형식: JSON (JavaScript Object Notation)

통신 컴포넌트: MessageUI (이메일 피드백 시스템 용)

#### 2.2 실행 환경
IDE: Xcode 17.0 이상

운영 체제: iOS 17.0 이상

권장 하드웨어: iPhone 15 Pro 이상의 시뮬레이터 또는 실제 기기

### 3. 기능 모듈 설명

#### 3.1 도서 및 진행률 관리
구조화된 저장소: 제목, 저자, 출판사 및 ISBN 관련 정보를 포함한 도서 메타데이터를 저장합니다.

원자적 기록: 모든 독서 진행률은 독립적인 ReadingLog 객체로 기록되며, 시스템은 알고리즘을 통해 현재 페이지 수와 진행률(%)을 실시간으로 계산합니다.

종속 삭제 (Cascade): @Relationship(deleteRule: .cascade)를 사용하여 도서 삭제 시 관련된 독서 기록도 자동으로 삭제되도록 하여 데이터베이스의 무결성을 유지합니다.

#### 3.2 데이터 백업 및 복원 (Data Portability)
내보내기 로직: 전체 [Book] 객체 그래프를 JSON 문자열로 직렬화하고, UIActivityViewController를 통해 기기 간 공유를 지원합니다.

가져오기 로직: 시스템 수준의 파일 선택인 .fileImporter를 지원하며, 안전한 데이터 복원을 구현합니다.

#### 3.3 다국어 지원 (i18n)
동적 전환: 시스템 설정과 독립적인 앱 내 언어 전환 로직으로 중국어 간체, 영어, 이탈리아어, 일본어, 한국어를 지원합니다.

리소스 관리: String Catalogs (.xcstrings)를 기반으로 정밀한 다국어 텍스트 매칭을 제공합니다.

### 4. 프로젝트 디렉토리 구조
```
./
├── 阅读记录/                 # 메인 앱 디렉토리
│   ├── ____App.swift       # 앱 진입점
│   ├── Models/             # 핵심 데이터 모델 (Book, ReadingInsights)
│   ├── Views/              # UI 프레젠테이션 계층
│   │   ├── ContentView.swift & MainTabView.swift
│   │   ├── Book/           # 도서 목록, 편집 및 진행률 컴포넌트
│   │   ├── History/        # 독서 기록 및 태그 관리
│   │   ├── Profile/        # 사용자 설정 및 데이터 관리
│   │   └── Statistics/     # 통계 차트, 배지 및 타임라인
│   ├── Managers/           # 비즈니스 로직 계층
│   ├── Resources/          # 다국어 리소스 (Localizable.xcstrings)
│   └── Assets.xcassets/    # 정적 리소스 (아이콘, 색상 등)
├── 阅读记录.xcodeproj        # Xcode 프로젝트 파일
├── 阅读记录Tests/            # 단위 테스트
└── 阅读记录UITests/          # UI 테스트
```

### 5. 설치 및 실행 가이드
소스 확보: 阅读记录.zip 파일을 압축 해제합니다.

프로젝트 실행: 루트 디렉토리에 있는 阅读记录.xcodeproj 파일을 두 번 클릭합니다.

환경 설정: Xcode 상단 툴바에서 적절한 iOS 17+ 시뮬레이터(iPhone 15 Pro 권장)를 선택합니다.

빌드 및 실행: Command + R을 눌러 앱을 실행합니다.

### 6. 개발 표준 요약
성능 최적화: @Query 속성 래퍼를 사용하여 효율적인 데이터베이스 검색을 구현합니다.

보안: 가져오기 과정에서 엄격한 유형 검증 및 예외 처리(do-catch)를 수행하여 손상된 JSON 파일로 인한 앱 충돌을 방지합니다.

상호 작용: 주요 작업에 UIImpactFeedbackGenerator 햅틱 피드백을 통합하여 사용자 경험을 향상시킵니다.

### 7. 参考文献と謝辞

#### 7.1 技術ドキュメントと言語仕様
* **[Swift 開発ドキュメント (中国語版)](https://swift.readthedocs.io/zh-cn/latest/)**: プロジェクトのコアロジック、構文、および設計アーキテクチャの主な参照先。
* **[Apple Developer Documentation](https://developer.apple.com/documentation/)**: SwiftUI フレームワーク、SwiftData、および iOS システム API の詳細な学習。

#### 7.2 AI支援協力
* **[Google Gemini](https://gemini.google.com/)**: **AIアシスタントデベロッパー** として、コードのリファクタリング、多言語ローカライズ（IT/JA/KO）、デバッグ、およびドキュメント作成を支援。
* **[Nano Banana 2 (Gemini 3 Flash Image)](https://gemini.google.com/)**: アプリのビジュアルアセット、UIコンセプトデザイン、およびアイコン草案の生成を補助。

### 8. 라이선스 및 고지 사항

#### 8.1 오픈 소스 라이선스
* 본 프로젝트는 **[MIT License](LICENSE)**를 따릅니다. 원본 저작권 고지 및 라이선스 고지 사항을 포함하는 조건 하에 본 소프트웨어를 자유롭게 사용, 복제, 수정 및 배포할 수 있습니다.

#### 8.2 학술 고지
* 본 프로젝트는 **학술 교류** 및 **과제 제출** 목적으로만 제작되었습니다.
* 개발자는 본 소프트웨어 사용으로 인해 발생하는 어떠한 직간접적인 손실에 대해서도 책임을 지지 않습니다.
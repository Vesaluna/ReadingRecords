//
//  StatisticsView.swift
//  阅读记录
//
//  Created by Huang on 18/04/2026.
//

import SwiftUI
import SwiftData
import Photos

enum SharePeriod: String {
    case month
    case quarter
    case year

    var filterToken: String {
        switch self {
        case .month: return "本月"
        case .quarter: return "本季度"
        case .year: return "本年"
        }
    }

    var reportButtonTitle: LocalizedStringKey {
        switch self {
        case .month: return "生成月度报告"
        case .quarter: return "生成季度报告"
        case .year: return "生成年度报告"
        }
    }

    var localizedPeriodName: String {
        switch self {
        case .month: return String(localized: "月度")
        case .quarter: return String(localized: "季度")
        case .year: return String(localized: "年度")
        }
    }
}

// MARK: - 1. 统计报告主页面
struct StatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.locale) private var locale
    @Query(sort: \Book.dateAdded, order: .reverse) private var allBooks: [Book]
    
    @State private var selectedDate = Date()
    @AppStorage("username") private var username: String = "新用户"
    @AppStorage("userAvatarData") private var userAvatarData: Data?
    
    @State private var showPreview = false
    @State private var showingPeriodSelection = false // 修复核心1：控制底部弹出菜单的开关
    @State private var selectedPeriod: SharePeriod = .year
    @State private var filteredBooksForShare: [Book] = []

    private var dailyStats: (pages: Int, chapters: Int) {
        var p = 0
        var c = 0
        for book in allBooks {
            let dayCount = book.readingLogs
                .filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
                .reduce(0) { $0 + $1.count }
            
            if book.unit == .pages { p += dayCount }
            else if book.unit == .chapters { c += dayCount }
        }
        return (p, c)
    }

    @ViewBuilder
    private func dailySummaryView() -> some View {
        let stats = dailyStats
        if stats.pages > 0 || stats.chapters > 0 {
            HStack(spacing: 2) {
                Text("共读了")
                if stats.pages > 0 {
                    Text("\(stats.pages)")
                    Text("页")
                }
                if stats.pages > 0 && stats.chapters > 0 {
                    Text("、")
                }
                if stats.chapters > 0 {
                    Text("\(stats.chapters)")
                    Text("章")
                }
            }
            .font(.caption).bold()
            .padding(6)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    DatePicker("阅读日历", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .accentColor(.orange)
                }
                
                Section {
                    HStack {
                        Label(
                            hasData(on: selectedDate) ? "阅读足迹" : "暂无足迹",
                            systemImage: hasData(on: selectedDate) ? "flame.fill" : "calendar.badge.minus"
                        )
                        .foregroundColor(hasData(on: selectedDate) ? .orange : .secondary)
                        
                        Spacer()
                        dailySummaryView()
                    }
                }

                Section {
                    let dayLogs = allBooks.flatMap { book in
                        book.readingLogs
                            .filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
                            .map { (book: book, log: $0) }
                    }
                    
                    if dayLogs.isEmpty {
                        emptyStateView
                    } else {
                        ForEach(dayLogs, id: \.log.id) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.book.title).font(.subheadline).bold()
                                    HStack(spacing: 2) {
                                        Text("读了")
                                        Text("\(item.log.count)")
                                        Text(item.book.unit == .pages ? "页" : "章")
                                    }
                                    .font(.caption2).foregroundColor(.secondary)
                                }
                                Spacer()
                                Text(item.log.date, style: .time)
                                    .font(.system(.caption2, design: .monospaced)).foregroundColor(.gray)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) { deleteLog(item.log, from: item.book) } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                        }
                    }
                } header: {
                    HStack(spacing: 0) {
                        Text("当日记录")
                        Text(": ")
                        Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                    }
                }

                Section("探索功能") {
                    NavigationLink(destination: ReadingTimelineView(books: allBooks)) {
                        featureEntryRow(
                            title: "时间轴",
                            subtitle: "按日期回顾阅读变化",
                            icon: "timeline.selection",
                            color: .blue
                        )
                    }

                    NavigationLink(destination: ChallengeCenterView(books: allBooks)) {
                        featureEntryRow(
                            title: "任务栏",
                            subtitle: "查看挑战进度与完成状态",
                            icon: "flame.circle.fill",
                            color: .orange
                        )
                    }

                    NavigationLink(destination: BadgeWallView(books: allBooks)) {
                        featureEntryRow(
                            title: "成就栏",
                            subtitle: "解锁并展示你的阅读徽章",
                            icon: "rosette",
                            color: .purple
                        )
                    }
                }
                
                Section("阅读成就") {
                    VStack(spacing: 20) {
                        HStack {
                            statCard(title: "总书籍", value: "\(allBooks.count)")
                            Divider()
                            statCard(title: "已读完", value: "\(allBooks.filter { $0.progress >= 1.0 }.count)")
                            Divider()
                            statCard(title: "累积打卡", value: "\(calculateTotalDays())")
                        }
                        
                        // 修复核心1：废除 Menu，改用普通 Button 触发 confirmationDialog
                        Button {
                            showingPeriodSelection = true
                        } label: {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("生成分享卡片")
                            }
                            .font(.subheadline.bold()).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 14)
                            .background(LinearGradient(colors: [.orange, .red.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(14)
                        }
                        .confirmationDialog("", isPresented: $showingPeriodSelection, titleVisibility: .hidden) {
                            Button(SharePeriod.month.reportButtonTitle(languageCode: languageCode)) { prepareShare(period: .month) }
                            Button(SharePeriod.quarter.reportButtonTitle(languageCode: languageCode)) { prepareShare(period: .quarter) }
                            Button(SharePeriod.year.reportButtonTitle(languageCode: languageCode)) { prepareShare(period: .year) }
                            Button("取消", role: .cancel) { }
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
            .navigationTitle("统计报告")
            .sheet(isPresented: $showPreview) {
                SharePreviewView(period: selectedPeriod, books: filteredBooksForShare)
                    .onAppear {
                        for book in allBooks { _ = book.readingLogs.count }
                    }
            }
        }
    }

    private func prepareShare(period: SharePeriod) {
        let calendar = Calendar.current
        let now = Date()
        
        let matchedBooks = allBooks.filter { book in
            book.readingLogs.contains { log in
                switch period {
                case .month:
                    return calendar.isDate(log.date, equalTo: now, toGranularity: .month)
                case .quarter:
                    let curQ = (calendar.component(.month, from: now) - 1) / 3
                    let logQ = (calendar.component(.month, from: log.date) - 1) / 3
                    return curQ == logQ && calendar.isDate(log.date, equalTo: now, toGranularity: .year)
                case .year:
                    return calendar.isDate(log.date, equalTo: now, toGranularity: .year)
                }
            }
        }

        filteredBooksForShare = matchedBooks
        selectedPeriod = period
        
        // 稍微延迟，让确认菜单完美收回后再弹窗，绝对安全
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            showPreview = true
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "pencil.and.outline").font(.largeTitle).foregroundColor(.gray.opacity(0.4))
            Text("这一天还没有书写足迹").font(.caption).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical)
    }

    private func statCard(title: LocalizedStringKey, value: String) -> some View {
        VStack {
            Text(value).font(.title3).bold()
            Text(title).font(.caption2).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func featureEntryRow(title: LocalizedStringKey, subtitle: LocalizedStringKey, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 34, height: 34)
                .background(color.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.bold())
                Text(subtitle).font(.caption).foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func hasData(on date: Date) -> Bool {
        allBooks.contains { book in
            book.readingLogs.contains { Calendar.current.isDate($0.date, inSameDayAs: date) }
        }
    }

    private func calculateTotalDays() -> Int {
        let allDates = allBooks.flatMap { $0.readingLogs.map { Calendar.current.startOfDay(for: $0.date) } }
        return Set(allDates).count
    }

    private var languageCode: String {
        locale.language.languageCode?.identifier ?? "en"
    }

    private func deleteLog(_ log: ReadingLog, from book: Book) {
        withAnimation {
            book.readingLogs.removeAll { $0.id == log.id }
            modelContext.delete(log)
            try? modelContext.save()
        }
    }
}

// MARK: - 2. 分享预览页面
struct SharePreviewView: View {
    let period: SharePeriod
    let books: [Book]
    @Environment(\.dismiss) var dismiss
    @Environment(\.displayScale) var displayScale
    @Environment(\.locale) var locale
    @State private var renderedImage: UIImage?
    @State private var renderedImageURL: URL?
    @State private var showSaveAlert = false
    @State private var isRendering = false
    
    @State private var renderTask: Task<Void, Never>? = nil
    
    // 修复核心2：引入专门的变量控制系统分享面板的弹出
    @State private var showShareSheet = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if books.isEmpty {
                    ContentUnavailableView("无阅读数据", systemImage: "tray", description: Text("这段时间还没有阅读记录"))
                } else {
                    ScrollView {
                        AchievementCard(period: period, books: books)
                            .padding()
                    }
                }
                
                if !books.isEmpty {
                    if isRendering {
                        HStack(spacing: 10) {
                            ProgressView()
                            Text("正在生成卡片...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 8)
                    }
                }

                HStack(spacing: 12) {
                    Button(action: saveImage) {
                        Label("保存到相册", systemImage: "square.and.arrow.down")
                            .font(.headline).foregroundColor(.white)
                            .padding().frame(maxWidth: .infinity)
                            .background(canExportImage ? Color.orange : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!canExportImage)

                    // 修复核心2：直接通过状态变量拉起符合规范的 ActivityViewController 包装器
                    Button {
                        if renderedImageURL == nil {
                            prepareShareFile()
                        }
                        // 强制延迟一点，确保文件生成完毕后再弹窗
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showShareSheet = true
                        }
                    } label: {
                        Label("系统分享", systemImage: "square.and.arrow.up")
                            .font(.headline).foregroundColor(.orange)
                            .padding().frame(maxWidth: .infinity)
                            .background(Color.orange.opacity(0.12))
                            .cornerRadius(12)
                    }
                    .disabled(!canExportImage)
                }
                .padding()
            }
            .navigationTitle(period.previewTitleText(languageCode: languageCode))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("关闭") { dismiss() } }
            }
            .alert("已保存到相册", isPresented: $showSaveAlert) { Button("确定", role: .cancel) { } }
            // 修复核心2：通过独立的 .sheet 安全弹出分享面板
            .sheet(isPresented: $showShareSheet) {
                if let url = renderedImageURL {
                    ActivityViewController(activityItems: [url])
                        .presentationDetents([.medium, .large]) // 允许面板半屏或全屏
                        .ignoresSafeArea()
                }
            }
            .onAppear { renderCardIfPossible() }
            .onChange(of: books.map(\.id)) { _, _ in
                renderedImageURL = nil
                renderCardIfPossible()
            }
            .onChange(of: period.filterToken) { _, _ in
                renderedImageURL = nil
                renderCardIfPossible()
            }
        }
    }
    
    @MainActor
    private func renderCardIfPossible() {
        guard !books.isEmpty else {
            renderedImage = nil
            renderedImageURL = nil
            return
        }
        
        renderTask?.cancel()
        renderTask = Task {
            isRendering = true
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            
            let content = AchievementCard(period: period, books: books)
                .frame(width: 350)
                .fixedSize(horizontal: false, vertical: true)
            
            let renderer = ImageRenderer(content: content)
            renderer.scale = displayScale
            
            if let image = renderer.uiImage {
                self.renderedImage = image
                self.updateShareFileIfNeeded()
            }
            self.isRendering = false
        }
    }
    
    private func saveImage() {
        if renderedImage == nil {
            renderCardIfPossible()
        }
        guard let image = renderedImage else { return }
        let saver = ImageSaver { if $0 { showSaveAlert = true } }
        saver.writeToPhotoAlbum(image: image)
    }

    private func prepareShareFile() {
        if renderedImage == nil {
            renderCardIfPossible()
        } else {
            updateShareFileIfNeeded()
        }
    }

    private var languageCode: String {
        locale.language.languageCode?.identifier ?? "en"
    }

    private var canExportImage: Bool {
        !books.isEmpty && renderedImage != nil && !isRendering
    }

    @MainActor
    private func updateShareFileIfNeeded() {
        guard let image = renderedImage, let data = image.pngData() else {
            renderedImageURL = nil
            return
        }
        let fileName = "reading-share-\(period.rawValue).png"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: url, options: .atomic)
            renderedImageURL = url
        } catch {
            renderedImageURL = nil
        }
    }
}

// 修复核心2必备：标准的 UIKit 分享面板包装器（零警告，最安全）
struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

private extension SharePeriod {
    func previewTitleText(languageCode: String) -> String {
        switch languageCode {
        case "zh":
            switch self {
            case .month: return "月度成果预览"
            case .quarter: return "季度成果预览"
            case .year: return "年度成果预览"
            }
        case "it":
            switch self {
            case .month: return "Anteprima mensile"
            case .quarter: return "Anteprima trimestrale"
            case .year: return "Anteprima annuale"
            }
        default:
            switch self {
            case .month: return "Month Preview"
            case .quarter: return "Quarter Preview"
            case .year: return "Year Preview"
            }
        }
    }

    func reportButtonTitle(languageCode: String) -> String {
        switch languageCode {
        case "zh":
            switch self {
            case .month: return "生成月度报告"
            case .quarter: return "生成季度报告"
            case .year: return "生成年度报告"
            }
        case "it":
            switch self {
            case .month: return "Genera report mensile"
            case .quarter: return "Genera report trimestrale"
            case .year: return "Genera report annuale"
            }
        case "ja":
            switch self {
            case .month: return "月次レポートを生成"
            case .quarter: return "四半期レポートを生成"
            case .year: return "年間レポートを生成"
            }
        case "ko":
            switch self {
            case .month: return "월간 리포트 생성"
            case .quarter: return "분기 리포트 생성"
            case .year: return "연간 리포트 생성"
            }
        default:
            switch self {
            case .month: return "Generate Monthly Report"
            case .quarter: return "Generate Quarterly Report"
            case .year: return "Generate Yearly Report"
            }
        }
    }
}

// MARK: - 3. 核心分享卡片设计
struct AchievementCard: View {
    let period: SharePeriod
    let books: [Book]
    @Environment(\.locale) private var locale
    
    private let totalReadingMinutes: Int
    private let finishedBooksCount: Int
    
    @AppStorage("username") private var username: String = "新用户"
    @AppStorage("userAvatarData") private var userAvatarData: Data?

    init(period: SharePeriod, books: [Book]) {
        self.period = period
        self.books = books
        
        let calendar = Calendar.current
        let now = Date()
        
        var totalMinutes = 0
        var finishedCount = 0
        
        for book in books {
            let periodLogs = book.readingLogs.filter { log in
                switch period {
                case .month:
                    return calendar.isDate(log.date, equalTo: now, toGranularity: .month)
                case .quarter:
                    let currentQuarter = (calendar.component(.month, from: now) - 1) / 3
                    let logQuarter = (calendar.component(.month, from: log.date) - 1) / 3
                    return currentQuarter == logQuarter && calendar.isDate(log.date, equalTo: now, toGranularity: .year)
                case .year:
                    return calendar.isDate(log.date, equalTo: now, toGranularity: .year)
                }
            }

            let periodCount = periodLogs.reduce(0) { $0 + max(0, $1.count) }
            let totalCount = book.readingLogs.reduce(0) { $0 + max(0, $1.count) }
            if totalCount > 0 {
                let ratio = Double(periodCount) / Double(totalCount)
                totalMinutes += Int((Double(book.readingMinutes) * ratio).rounded())
            } else {
                totalMinutes += book.readingMinutes
            }

            if book.progress >= 1.0 {
                finishedCount += 1
            }
        }
        
        self.totalReadingMinutes = totalMinutes
        self.finishedBooksCount = finishedCount
    }

    private var formattedTime: String {
        let hours = totalReadingMinutes / 60
        let minutes = totalReadingMinutes % 60
        switch languageCode {
        case "zh":
            return hours > 0 ? "\(hours)小时 \(minutes)分钟" : "\(minutes)分钟"
        case "it":
            return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
        case "ja":
            return hours > 0 ? "\(hours)時間\(minutes)分" : "\(minutes)分"
        case "ko":
            return hours > 0 ? "\(hours)시간 \(minutes)분" : "\(minutes)분"
        default:
            return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
        }
    }

    private var displayDate: String {
        let calendar = Calendar.current
        let now = Date()
        let year = calendar.component(.year, from: now)

        switch period {
        case .month:
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: locale.identifier)
            formatter.setLocalizedDateFormatFromTemplate("MMM yyyy")
            return formatter.string(from: now)
        case .quarter:
            let quarter = (calendar.component(.month, from: now) - 1) / 3 + 1
            switch languageCode {
            case "zh":
                return "第\(quarter)季度 \(year)"
            case "it":
                return "\(quarter)° trimestre \(year)"
            case "ja":
                return "\(year)年 第\(quarter)四半期"
            case "ko":
                return "\(year)년 \(quarter)분기"
            default:
                return "Q\(quarter) \(year)"
            }
        case .year:
            switch languageCode {
            case "zh": return "\(year) 年度阅读报告"
            case "it": return "Rapporto di lettura \(year)"
            case "ja": return "\(year)年 読書レポート"
            case "ko": return "\(year)년 독서 리포트"
            default: return "\(year) Reading Report"
            }
        }
    }

    private var readingReportTitle: String {
        switch languageCode {
        case "zh": return "阅读报告"
        case "it": return "Reading Report"
        case "ja": return "読書レポート"
        case "ko": return "독서 리포트"
        default: return "Reading Report"
        }
    }

    private var finishedBooksLabel: String {
        switch languageCode {
        case "zh": return "已读书籍"
        case "it": return "Libri letti"
        case "ja": return "読了冊数"
        case "ko": return "완독 도서"
        default: return "Finished Books"
        }
    }

    private var readingTimeLabel: String {
        switch languageCode {
        case "zh": return "阅读时间"
        case "it": return "Tempo di lettura"
        case "ja": return "読書時間"
        case "ko": return "독서 시간"
        default: return "Reading Time"
        }
    }

    private var footerReadBooksText: String {
        switch languageCode {
        case "zh": return "读了 \(finishedBooksCount) 本书"
        case "it": return "Letto \(finishedBooksCount) libri"
        case "ja": return "\(finishedBooksCount)冊を読みました"
        case "ko": return "\(finishedBooksCount)권 읽음"
        default: return "Read \(finishedBooksCount) books"
        }
    }

    private var languageCode: String {
        locale.language.languageCode?.identifier ?? "en"
    }

    var body: some View {
        VStack(spacing: 25) {
            // 头部
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(displayDate).font(.system(size: 28, weight: .black, design: .rounded))
                    Text(readingReportTitle).font(.system(.title3, design: .monospaced)).foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "seal.fill").font(.system(size: 40)).foregroundColor(.orange)
            }
            
            // 统计栏
            HStack(spacing: 0) {
                VStack {
                    Text("\(finishedBooksCount)").font(.system(size: 38, weight: .bold))
                    Text(finishedBooksLabel).font(.caption).foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Rectangle().fill(Color.gray.opacity(0.2)).frame(width: 1, height: 40)
                
                VStack {
                    Text(formattedTime).font(.system(size: 32, weight: .bold))
                    Text(readingTimeLabel).font(.caption).foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 20)
            .background(Color.orange.opacity(0.05))
            .cornerRadius(20)
            
            // 书籍列表
            VStack(alignment: .leading, spacing: 18) {
                ForEach(books.prefix(8)) { book in
                    HStack(spacing: 12) {
                        Rectangle()
                            .fill(LinearGradient(colors: [.orange.opacity(0.3), .orange], startPoint: .top, endPoint: .bottom))
                            .frame(width: 4, height: 32).cornerRadius(2)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(book.title).font(.subheadline).bold().lineLimit(1)
                            
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(Color.orange.opacity(0.2))
                                    Capsule().fill(Color.orange)
                                        .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(book.progress))))
                                }
                            }
                            .frame(height: 5)
                        }
                        
                        Spacer(minLength: 8)
                        
                        Text("\(Int(book.progress * 100))%").font(.caption2).monospacedDigit().foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer(minLength: 20)
            
            // 底部：用户信息
            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(username).font(.subheadline).bold()
                    Text(footerReadBooksText).font(.caption2).foregroundColor(.secondary)
                }
                
                if let data = userAvatarData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 45, height: 45)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 45, height: 45)
                        .foregroundColor(.orange.opacity(0.8))
                }
            }
        }
        .padding(30).frame(width: 350)
        .background(
            ZStack {
                Color(UIColor.systemBackground)
                VStack(spacing: 40) {
                    ForEach(0..<15, id: \.self) { r in
                        HStack(spacing: 40) {
                            ForEach(0..<8, id: \.self) { c in
                                Image("应用图标")
                                    .resizable()
                                    .frame(width: 35, height: 35)
                                    .opacity(0.15)
                                    .rotationEffect(.degrees(-15))
                                    .offset(x: r % 2 == 0 ? 0 : 20)
                            }
                        }
                    }
                }
                .rotationEffect(.degrees(-15))
                .scaleEffect(1.4)
            }
        )
        .cornerRadius(32)
        .clipped()
        .overlay(RoundedRectangle(cornerRadius: 32).stroke(Color.gray.opacity(0.1), lineWidth: 1))
    }
}

// MARK: - 4. 辅助工具
class ImageSaver: NSObject {
    var completion: (Bool) -> Void
    init(completion: @escaping (Bool) -> Void) { self.completion = completion }
    func writeToPhotoAlbum(image: UIImage) { UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil) }
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        completion(error == nil)
    }
}

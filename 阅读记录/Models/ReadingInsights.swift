import Foundation
import SwiftUI

struct TimelineEntry: Identifiable {
    let id = UUID()
    let date: Date
    let items: [TimelineBookLog]

    var totalCount: Int {
        items.reduce(0) { $0 + $1.log.count }
    }

    var totalMinutes: Int {
        items.reduce(0) { $0 + $1.log.minutes }
    }
}

struct TimelineBookLog: Identifiable {
    let id = UUID()
    let bookTitle: String // 书名是用户输入的数据，不需要本地化，保持 String
    let unit: ReadingUnit
    let log: ReadingLog
}

struct ReadingChallenge: Identifiable {
    let id = UUID()
    // 修复核心 1：将 UI 展示文本的类型改为 LocalizedStringKey
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let icon: String
    let tint: Color
    let progress: Double
    let progressText: LocalizedStringKey

    var isCompleted: Bool { progress >= 1.0 }
}

struct ReadingBadge: Identifiable {
    let id = UUID()
    // 修复核心 2：将 UI 展示文本的类型改为 LocalizedStringKey
    let title: LocalizedStringKey
    let icon: String
    let color: Color
    let unlocked: Bool
    let hint: LocalizedStringKey
}

enum ReadingInsightsBuilder {
    // MARK: - Timeline Builder
    static func timeline(from books: [Book]) -> [TimelineEntry] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: books.flatMap { book in
            book.readingLogs.map { log in
                TimelineBookLog(bookTitle: book.title, unit: book.unit, log: log)
            }
        }, by: { calendar.startOfDay(for: $0.log.date) })

        return grouped
            .map { date, items in
                TimelineEntry(date: date, items: items.sorted { $0.log.date > $1.log.date })
            }
            .sorted { $0.date > $1.date }
    }

    // MARK: - Data Calculations
    static func uniqueReadingDays(from books: [Book]) -> Int {
        let calendar = Calendar.current
        let days = books.flatMap { $0.readingLogs.map { calendar.startOfDay(for: $0.date) } }
        return Set(days).count
    }

    static func totalReadingMinutes(from books: [Book]) -> Int {
        books.reduce(0) { $0 + $1.readingMinutes }
    }
    
    static func totalUnitsRead(from books: [Book]) -> Int {
        books.reduce(0) { total, book in
            total + book.readingLogs.reduce(0) { $0 + $1.count }
        }
    }

    static func completedBooks(from books: [Book]) -> Int {
        books.filter { $0.progress >= 1.0 }.count
    }

    static func currentStreak(from books: [Book]) -> Int {
        let calendar = Calendar.current
        let daySet = Set(books.flatMap { $0.readingLogs.map { calendar.startOfDay(for: $0.date) } })
        guard !daySet.isEmpty else { return 0 }

        let today = calendar.startOfDay(for: Date())
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return 0 }

        var streak = 0
        var cursor: Date
        
        if daySet.contains(today) {
            cursor = today
        } else if daySet.contains(yesterday) {
            cursor = yesterday
        } else {
            return 0
        }

        while daySet.contains(cursor) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previousDay
        }
        return streak
    }

    static func monthlyMinutes(from books: [Book]) -> Int {
        let calendar = Calendar.current
        let now = Date()
        return books.flatMap(\.readingLogs)
            .filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
            .reduce(0) { $0 + $1.minutes }
    }

    // MARK: - Feature Builders
    static func challengeList(from books: [Book]) -> [ReadingChallenge] {
        let streak = currentStreak(from: books)
        let monthly = monthlyMinutes(from: books)
        let completed = completedBooks(from: books)

        // 修复核心 3：去掉所有 String(localized:)，直接写纯字符串
        // Swift 会自动把它们转为 LocalizedStringKey，并且 Xcode 能够 100% 提取！
        return [
            ReadingChallenge(
                title: "连续阅读 7 天",
                subtitle: "保持每天都有阅读记录",
                icon: "flame.fill",
                tint: .orange,
                progress: min(Double(streak) / 7.0, 1.0),
                progressText: "\(streak)/7 天"
            ),
            ReadingChallenge(
                title: "月度 600 分钟",
                subtitle: "本月累计阅读 10 小时",
                icon: "clock.fill",
                tint: .blue,
                progress: min(Double(monthly) / 600.0, 1.0),
                progressText: "\(monthly)/600 分钟"
            ),
            ReadingChallenge(
                title: "完成 3 本书",
                subtitle: "完成进度达到 100%",
                icon: "book.fill",
                tint: .green,
                progress: min(Double(completed) / 3.0, 1.0),
                progressText: "\(completed)/3 本"
            )
        ]
    }

    static func badgeList(from books: [Book]) -> [ReadingBadge] {
        let days = uniqueReadingDays(from: books)
        let completed = completedBooks(from: books)
        let minutes = totalReadingMinutes(from: books)
        let streak = currentStreak(from: books)
        let units = totalUnitsRead(from: books)

        // 徽章系统：直接传入纯字符串，干净清爽，Xcode 提取无障碍
        return [
            ReadingBadge(title: "初次启航", icon: "paperplane.fill", color: .cyan, unlocked: days >= 1, hint: "任意一天有阅读记录"),
            ReadingBadge(title: "积少成多", icon: "doc.text.fill", color: .mint, unlocked: units >= 100, hint: "累计阅读 100 页/章"),
            ReadingBadge(title: "第一桶金", icon: "book.closed.fill", color: .yellow, unlocked: completed >= 1, hint: "读完第 1 本书"),
            
            ReadingBadge(title: "坚持一周", icon: "flame.fill", color: .orange, unlocked: streak >= 7, hint: "连续阅读 7 天"),
            ReadingBadge(title: "专注时刻", icon: "hourglass", color: .teal, unlocked: minutes >= 600, hint: "累计阅读 600 分钟"),
            ReadingBadge(title: "阅读达人", icon: "books.vertical.fill", color: .green, unlocked: completed >= 3, hint: "读完 3 本书"),
            
            ReadingBadge(title: "习惯养成", icon: "calendar.badge.clock", color: .pink, unlocked: days >= 30, hint: "累计 30 天阅读记录"),
            ReadingBadge(title: "持之以恒", icon: "flame.circle.fill", color: .red, unlocked: streak >= 30, hint: "连续阅读 30 天"),
            ReadingBadge(title: "时间掌控者", icon: "clock.badge.checkmark.fill", color: .purple, unlocked: minutes >= 3000, hint: "累计阅读 3000 分钟"),
            
            ReadingBadge(title: "百日筑基", icon: "crown.fill", color: .orange, unlocked: days >= 100, hint: "累计 100 天阅读记录"),
            ReadingBadge(title: "知识探险家", icon: "sparkles", color: .indigo, unlocked: completed >= 10, hint: "读完 10 本书"),
            ReadingBadge(title: "卷帙浩繁", icon: "scroll.fill", color: .brown, unlocked: units >= 10000, hint: "累计阅读 10000 页/章")
        ]
    }
}

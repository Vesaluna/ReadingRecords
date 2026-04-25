import Foundation
import SwiftData
import SwiftUI

// MARK: - 阅读单位
enum ReadingUnit: String, Codable, CaseIterable {
    case pages = "页"
    case chapters = "章"
    
    var resource: LocalizedStringResource {
        switch self {
        case .pages: return LocalizedStringResource("页")
        case .chapters: return LocalizedStringResource("章")
        }
    }
}

// MARK: - 阅读记录模型
@Model
final class ReadingLog: Codable {
    var date: Date
    var count: Int
    var minutes: Int
    
    // 【修复关键 1】：增加对 Book 的反向引用
    // 这确保了即使 App 重启，Log 依然能通过数据库外键找到所属的书籍
    var book: Book?
    
    init(date: Date = Date(), count: Int, minutes: Int = 0) {
        self.date = date
        self.count = count
        self.minutes = minutes
    }
    
    // MARK: - Codable 实现
    enum CodingKeys: String, CodingKey {
        case date, count, minutes
        // 注意：不要在这里包含 book，否则会引起 JSON 循环引用
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.date = try container.decode(Date.self, forKey: .date)
        self.count = try container.decode(Int.self, forKey: .count)
        self.minutes = try container.decode(Int.self, forKey: .minutes)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(count, forKey: .count)
        try container.encode(minutes, forKey: .minutes)
    }
}

// MARK: - 书籍模型
@Model
final class Book: Codable {
    var title: String
    var author: String
    var publisher: String
    var totalPages: Int
    var unit: ReadingUnit
    var dateAdded: Date
    var rating: Int
    var readingMinutes: Int
    var tags: [String]
    var coverImageData: Data?
    
    var startDate: Date = Date()
    var endDate: Date?
    
    // 【修复关键 2】：使用 cascade 确保书籍删除时日志也删除
    @Relationship(deleteRule: .cascade, inverse: \ReadingLog.book)
    var readingLogs: [ReadingLog] = []

    init(title: String = "",
         author: String = "",
         publisher: String = "",
         totalPages: Int = 100,
         unit: ReadingUnit = .pages,
         coverImageData: Data? = nil) {
        self.title = title
        self.author = author
        self.publisher = publisher
        self.totalPages = totalPages
        self.unit = unit
        self.dateAdded = Date()
        self.rating = 0
        self.readingMinutes = 0
        self.tags = []
        self.coverImageData = coverImageData
        self.startDate = Date()
        self.endDate = nil
        self.readingLogs = []
    }
    
    // MARK: - Codable 实现
    enum CodingKeys: String, CodingKey {
        case title, author, publisher, totalPages, unit, dateAdded,
             rating, readingMinutes, tags, coverImageData, startDate, endDate, readingLogs
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.author = try container.decode(String.self, forKey: .author)
        self.publisher = try container.decode(String.self, forKey: .publisher)
        self.totalPages = try container.decode(Int.self, forKey: .totalPages)
        self.unit = try container.decode(ReadingUnit.self, forKey: .unit)
        self.dateAdded = try container.decode(Date.self, forKey: .dateAdded)
        self.rating = try container.decode(Int.self, forKey: .rating)
        self.readingMinutes = try container.decode(Int.self, forKey: .readingMinutes)
        self.tags = try container.decode([String].self, forKey: .tags)
        self.coverImageData = try container.decodeIfPresent(Data.self, forKey: .coverImageData)
        self.startDate = try container.decode(Date.self, forKey: .startDate)
        self.endDate = try container.decodeIfPresent(Date.self, forKey: .endDate)
        
        // 这里的解码非常重要：由于 ReadingLog 也是 Codable，它们会被加载进内存
        self.readingLogs = try container.decode([ReadingLog].self, forKey: .readingLogs)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(author, forKey: .author)
        try container.encode(publisher, forKey: .publisher)
        try container.encode(totalPages, forKey: .totalPages)
        try container.encode(unit, forKey: .unit)
        try container.encode(dateAdded, forKey: .dateAdded)
        try container.encode(rating, forKey: .rating)
        try container.encode(readingMinutes, forKey: .readingMinutes)
        try container.encode(tags, forKey: .tags)
        try container.encode(coverImageData, forKey: .coverImageData)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(readingLogs, forKey: .readingLogs)
    }
    
    // MARK: - 计算属性
    // 由于阅读记录通过对象关系绑定，无论 title 怎么变，只要 logs 在数组里，计算就永远准确
    var currentPage: Int {
        readingLogs.reduce(0) { $0 + $1.count }
    }
    
    var progress: Double {
        guard totalPages > 0 else { return 0 }
        let current = Double(currentPage)
        let total = Double(totalPages)
        return min(current / total, 1.0)
    }
}

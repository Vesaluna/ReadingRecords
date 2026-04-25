//
//  DataManager.swift
//  阅读记录
//
//  Created by Huang on 19/04/2026.
//
import Foundation
import SwiftData
import UniformTypeIdentifiers

struct DataManager {
    // 导出逻辑：将 [Book] 转换为临时文件 URL
    static func exportBooks(_ books: [Book]) -> URL? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted // 让导出的 JSON 易读
        encoder.dateEncodingStrategy = .iso8601  // 标准日期格式
        
        do {
            let data = try encoder.encode(books)
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("ReadingRecord_Backup.json")
            try data.write(to: tempURL)
            return tempURL
        } catch {
            print("导出编码失败: \(error)")
            return nil
        }
    }
    
    // 导入逻辑：将 Data 转换为 [Book]
    static func decodeBooks(from data: Data) -> [Book]? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            return try decoder.decode([Book].self, from: data)
        } catch {
            print("导入解码失败: \(error)")
            return nil
        }
    }
}

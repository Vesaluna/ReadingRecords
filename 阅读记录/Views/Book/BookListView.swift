//
//  BookListView.swift
//  阅读记录
//
//  Created by Huang on 18/04/2026.
//
import SwiftUI
import SwiftData

struct BookListView: View {
    @Query var books: [Book]
    
    var body: some View {
        List {
            Section("阅读概览") {
                LabeledContent("总书籍数量", value: "\(books.count) 本")
                LabeledContent("已读完书籍", value: "\(books.filter { $0.progress >= 1.0 }.count) 本")
            }
        }
        .navigationTitle("数据统计")
    }
}

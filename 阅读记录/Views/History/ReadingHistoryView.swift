//
//  ReadingHistoryView.swift.swift
//  阅读记录
//
//  Created by Huang on 18/04/2026.
//
import SwiftUI
import SwiftData

struct ReadingHistoryView: View {
    @Query(sort: \Book.dateAdded, order: .reverse) var books: [Book]
    
    var body: some View {
        List(books) { book in
            HStack {
                VStack(alignment: .leading) {
                    Text(book.title).font(.headline)
                    Text("添加于: \(book.dateAdded.formatted(date: .long, time: .omitted))")
                        .font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Text("\(Int(book.progress * 100))%").bold().foregroundColor(.orange)
            }
        }
        .navigationTitle("我的回顾")
    }
}

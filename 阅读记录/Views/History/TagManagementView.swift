//
//  TagManagementView.swift
//  阅读记录
//
//  Created by Huang on 18/04/2026.
//
import SwiftUI
import SwiftData

struct TagManagementView: View {
    @Query var allBooks: [Book]
    
    // 自动抓取并去重所有书籍中的标签
    var distinctTags: [String] {
        let tags = allBooks.flatMap { $0.tags }
        return Array(Set(tags)).sorted()
    }
    
    var body: some View {
        List {
            if distinctTags.isEmpty {
                ContentUnavailableView("暂无标签", systemImage: "tag.slash", description: Text("在编辑书籍页面添加标签后，会在这里显示。"))
            } else {
                ForEach(distinctTags, id: \.self) { tag in
                    NavigationLink(destination: TagFilteredListView(tag: tag)) {
                        HStack {
                            Text(tag)
                            Spacer()
                            Text("\(allBooks.filter { $0.tags.contains(tag) }.count) 本")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("标签索引")
    }
}

// 点击标签后显示的过滤列表
struct TagFilteredListView: View {
    let tag: String
    @Query var allBooks: [Book]
    
    var filteredBooks: [Book] {
        allBooks.filter { $0.tags.contains(tag) }
    }
    
    var body: some View {
        List(filteredBooks) { book in
            HStack {
                if let data = book.coverImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: 40, height: 55)
                        .cornerRadius(4)
                }
                
                VStack(alignment: .leading) {
                    Text(book.title).font(.headline)
                    Text(book.author).font(.caption).foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("#\(tag)")
    }
}

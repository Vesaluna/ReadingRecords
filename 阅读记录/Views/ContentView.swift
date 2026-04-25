import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("selectedLanguage") private var selectedLanguage = "zh-Hans"
    
    @Query(sort: \Book.dateAdded, order: .reverse) private var allBooks: [Book]
    
    @State private var showingAddBook = false
    @State private var selectedCategory: String = "全部"
    @State private var searchText: String = ""

    var categories: [String] {
        let fixed = ["全部", "阅读中", "已读完"]
        let userTags = Array(Set(allBooks.flatMap { $0.tags })).sorted()
        return fixed + userTags
    }

    var finalFilteredBooks: [Book] {
        let categoryFiltered: [Book]
        switch selectedCategory {
        case "全部":
            categoryFiltered = allBooks
        case "阅读中":
            categoryFiltered = allBooks.filter { $0.progress < 1.0 }
        case "已读完":
            categoryFiltered = allBooks.filter { $0.progress >= 1.0 }
        default:
            categoryFiltered = allBooks.filter { $0.tags.contains(selectedCategory) }
        }
        
        if searchText.isEmpty {
            return categoryFiltered
        } else {
            return categoryFiltered.filter { book in
                book.title.localizedCaseInsensitiveContains(searchText) ||
                book.author.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            // 方案三：使用 ZStack 实现层叠布局
            ZStack(alignment: .bottomTrailing) {
                
                // --- 第一层：主体内容 ---
                VStack(spacing: 0) {
                    categorySliderBar
                    
                    List {
                        ForEach(finalFilteredBooks) { book in
                            NavigationLink(destination: EditBookView(book: book)) {
                                bookRow(book)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 10)
                                    .shadow(color: .black.opacity(0.05), radius: 2)
                            )
                        }
                        .onDelete(perform: deleteBook)
                    }
                    .listStyle(.plain)
                    .overlay {
                        if !searchText.isEmpty && finalFilteredBooks.isEmpty {
                            ContentUnavailableView.search(text: searchText)
                        }
                    }
                }
                
                // --- 第二层：Things 风格悬浮按钮 ---
                floatingAddButton
            }
            .navigationTitle("阅读记录")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "搜索书名或作者")
            // 注意：这里移除了原来的 .toolbar 按钮，让顶部更干净
            .sheet(isPresented: $showingAddBook) {
                AddBookView()
            }
        }
        .id(selectedLanguage)
    }

    // MARK: - 新增：悬浮添加按钮
    private var floatingAddButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred() // 触感反馈
            showingAddBook = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(Color.orange)
                        .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
                )
        }
        .padding(.trailing, 20) // 距离右边缘
        .padding(.bottom, 20)   // 距离底部（Tab Bar 上方）
    }

    // MARK: - 原有组件保持不变
    
    private var categorySliderBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(categories, id: \.self) { category in
                    VStack(spacing: 6) {
                        Text(LocalizedStringKey(category))
                            .font(.system(size: 16, weight: selectedCategory == category ? .bold : .medium))
                            .foregroundColor(selectedCategory == category ? .orange : .secondary)
                        
                        Capsule()
                            .fill(selectedCategory == category ? Color.orange : Color.clear)
                            .frame(width: 20, height: 3)
                    }
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
        }
        .background(Color(UIColor.systemBackground))
    }

    private func bookRow(_ book: Book) -> some View {
        HStack(spacing: 16) {
            ZStack {
                if let imageData = book.coverImageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Color.gray.opacity(0.2)
                        .overlay(Image(systemName: "book").foregroundColor(.gray))
                }
            }
            .frame(width: 70, height: 100)
            .cornerRadius(10)
            .clipped()
            .shadow(color: .black.opacity(0.1), radius: 5, x: 2, y: 2)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(book.title)
                    .font(.system(size: 17, weight: .bold))
                    .lineLimit(1)
                
                if book.rating > 0 {
                    HStack(spacing: 2) {
                        ForEach(0..<book.rating, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.orange)
                        }
                    }
                }

                if !book.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(book.tags.prefix(3), id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 9, weight: .medium))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.1))
                                .foregroundColor(.orange)
                                .cornerRadius(4)
                        }
                    }
                }

                if book.readingMinutes > 0 {
                    Text("读了 \(book.readingMinutes) 分钟")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    ProgressView(value: book.progress)
                        .tint(.orange)
                        .scaleEffect(x: 1, y: 1.5)
                    
                    HStack {
                        EditableProgressView(book: book)
                        Spacer()
                        Text("\(Int(book.progress * 100))%")
                            .font(.caption2).bold()
                            .padding(4)
                            .background(Color.orange.opacity(0.1))
                            .foregroundColor(.orange)
                            .cornerRadius(4)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    func deleteBook(_ indexSet: IndexSet) {
        for index in indexSet {
            let bookToDelete = finalFilteredBooks[index]
            modelContext.delete(bookToDelete)
        }
    }
}

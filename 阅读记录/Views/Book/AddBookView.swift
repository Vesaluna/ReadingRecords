//
//  AddBookView.swift
//  阅读记录
//
//  Created by Huang on 18/04/2026.
//
import SwiftUI
import SwiftData
import PhotosUI

struct AddBookView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var author = ""
    @State private var publisher = "" // 新增：出版社状态
    @State private var totalPages = ""
    @State private var selectedUnit: ReadingUnit = .pages
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil

    var body: some View {
        NavigationStack {
            Form {
                // 封面选择部分 (保持不变)
                Section("书籍封面") {
                    HStack {
                        Spacer()
                        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                            if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 130)
                                    .cornerRadius(10)
                                    .shadow(radius: 3)
                            } else {
                                VStack(spacing: 12) {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.system(size: 40))
                                    Text("选择封面")
                                        .font(.caption)
                                }
                                .foregroundColor(.secondary)
                                .frame(width: 100, height: 130)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        .onChange(of: selectedItem) { oldItem, newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    selectedImageData = data
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                // 基本信息部分：新增出版社
                Section("书籍基本信息") {
                    TextField("书名", text: $title)
                    TextField("作者", text: $author)
                    TextField("出版社", text: $publisher) // 新增输入框
                }
                
                Section("进度设置") {
                    Picker("计重单位", selection: $selectedUnit) {
                        ForEach(ReadingUnit.allCases, id: \.self) { unit in
                            // 这里会显示“页”或“章”，去掉了“%”
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    TextField("总\(selectedUnit.rawValue)数", text: $totalPages)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("添加书籍")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        saveBook()
                    }
                    .disabled(title.isEmpty || totalPages.isEmpty)
                }
            }
        }
    }

    private func saveBook() {
        let pages = Int(totalPages) ?? 0
        
        // 关键：调用最新的 Book 初始化函数，传入所有字段
        let newBook = Book(
            title: title,
            author: author,
            publisher: publisher, // 传入出版社
            totalPages: pages,
            unit: selectedUnit,
            coverImageData: selectedImageData
        )
        
        // 注意：startDate 在 Book 模型 init 中默认设为 Date()，此处无需手动再设
        
        modelContext.insert(newBook)
        dismiss()
    }
}

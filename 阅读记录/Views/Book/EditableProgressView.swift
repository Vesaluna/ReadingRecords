//
//  EditableProgressView.swift
//  阅读记录
//
//  Created by Huang on 19/04/2026.
//

import SwiftUI
import SwiftData

struct EditableProgressView: View {
    @Bindable var book: Book
    @Environment(\.modelContext) private var modelContext // 引入上下文以确保保存
    @State private var showInputAlert = false
    @State private var inputNumber = ""

    var body: some View {
        HStack(spacing: 8) {
            // 左侧：显示当前进度，点击弹出输入框
            Button {
                // 默认填入当前页码方便修改
                inputNumber = "\(book.currentPage)"
                showInputAlert = true
            } label: {
                HStack(spacing: 4) {
                    Text("\(book.currentPage) / \(book.totalPages)")
                    Text(book.unit.resource) // 使用 resource 确保本地化正确
                }
                .font(.caption).bold()
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.1))
                .foregroundColor(.primary)
                .cornerRadius(6)
            }
            .buttonStyle(.plain)

            // 右侧：快速“+1”按钮
            Button {
                if book.currentPage < book.totalPages {
                    addNewLog(count: 1)
                }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 20))
            }
            .buttonStyle(.plain)
        }
        .alert("更新进度", isPresented: $showInputAlert) {
            TextField("输入总进度", text: $inputNumber)
                .keyboardType(.numberPad)
            
            Button("取消", role: .cancel) { }
            
            Button("保存") {
                if let targetPage = Int(inputNumber) {
                    let current = book.currentPage
                    let validatedTarget = max(0, min(targetPage, book.totalPages))
                    let diff = validatedTarget - current
                    
                    if diff != 0 {
                        addNewLog(count: diff)
                    }
                }
                inputNumber = ""
            }
        } message: {
            Text("当前进度为 \(book.currentPage) \(book.unit.resource)，请输入最新的总进度。")
        }
    }

    // MARK: - 核心修复：统一的日志添加方法
    private func addNewLog(count: Int) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        withAnimation {
            // 1. 创建新日志
            let newLog = ReadingLog(date: Date(), count: count)
            
            // 2. 插入上下文
            modelContext.insert(newLog)
            
            // 3. 【核心修复】：显式建立双向关联
            // 这样即使重启 App，SwiftData 也能通过底层的 Relationship 找到这条记录
            newLog.book = book
            book.readingLogs.append(newLog)
            
            // 4. 尝试保存，确保即使立刻杀掉进程数据也已写入
            try? modelContext.save()
        }
    }
}

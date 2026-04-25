//
//  EditBookView.swift
//  阅读记录
//
//  Created by Huang on 18/04/2026.
//

import SwiftUI
import SwiftData
import PhotosUI

// MARK: - 主视图：编辑书籍
struct EditBookView: View {
    @Bindable var book: Book
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    // 状态变量
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var showTagAlert = false
    @State private var newTagName = ""
    @State private var inputHours: Int = 0
    @State private var inputMinutes: Int = 0
    
    // 焦点状态
    @FocusState private var isInputFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                coverSection
                basicInfoSection
                progressAndRatingSection
                timeStatsSection
                timelineSection
                tagSection
            }
            .navigationTitle("编辑书籍")
            .navigationBarTitleDisplayMode(.inline)
            .onTapGesture { isInputFocused = false }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        saveAndDismiss()
                    }
                    .bold()
                }
            }
            .onAppear {
                // 初始化时间显示
                inputHours = book.readingMinutes / 60
                inputMinutes = book.readingMinutes % 60
            }
            .alert("新标签", isPresented: $showTagAlert) {
                TextField("输入标签名称", text: $newTagName)
                Button("取消", role: .cancel) { newTagName = "" }
                Button("添加") { addNewTag() }
            }
        }
    }

    // MARK: - 逻辑处理

    private func saveAndDismiss() {
        // 确保时长同步
        book.readingMinutes = (inputHours * 60) + inputMinutes
        
        // 【核心修复】：手动触发一次保存，确保即使改名和修改在 App 重启后依然存在
        try? modelContext.save()
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        dismiss()
    }

    private func addNewTag() {
        let trimmed = newTagName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !book.tags.contains(trimmed) {
            withAnimation(.spring()) {
                book.tags.append(trimmed)
            }
        }
        newTagName = ""
    }

    private func triggerTagAlert() {
        isInputFocused = false
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            showTagAlert = true
        }
    }

    // MARK: - 子视图组件
    
    private var coverSection: some View {
        Section("书籍封面") {
            HStack {
                Spacer()
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    if let imageData = book.coverImageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 140)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 5)
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "photo.badge.plus")
                                .font(.largeTitle)
                            Text("点击选取封面").font(.caption)
                        }
                        .frame(width: 100, height: 140)
                        .background(Color.secondary.opacity(0.1))
                        .foregroundColor(.orange)
                        .cornerRadius(12)
                    }
                }
                .buttonStyle(.plain)
                .onChange(of: selectedItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            await MainActor.run {
                                withAnimation(.spring()) { book.coverImageData = data }
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
    
    private var basicInfoSection: some View {
        Section("基本信息") {
            TextField("书名", text: $book.title)
                .focused($isInputFocused)
            TextField("作者", text: $book.author)
                .focused($isInputFocused)
            TextField("出版社", text: $book.publisher)
                .focused($isInputFocused)
        }
    }
    
    private var progressAndRatingSection: some View {
        Section("进度与评分") {
            HStack {
                Text("评分")
                Spacer()
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= book.rating ? "star.fill" : "star")
                        .foregroundColor(.orange)
                        .onTapGesture {
                            isInputFocused = false
                            UISelectionFeedbackGenerator().selectionChanged()
                            book.rating = index
                        }
                }
            }

            Picker("单位", selection: $book.unit) {
                ForEach(ReadingUnit.allCases, id: \.self) { unit in
                    Text(unit.resource).tag(unit)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: book.unit) { isInputFocused = false }
            
            HStack {
                Text("总\(book.unit.resource)数")
                Spacer()
                TextField("数量", value: $book.totalPages, format: .number)
                    .focused($isInputFocused)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
            }
            
            HStack {
                Text("当前进度")
                Spacer()
                // 这里调用了 Book 模型中的计算属性
                Text("\(book.currentPage) \(book.unit.resource)")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var timeStatsSection: some View {
        Section("时长统计") {
            HStack {
                Text("阅读时长")
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    Text("\(inputHours)h \(inputMinutes)m")
                        .font(.subheadline.monospacedDigit())
                    HStack(spacing: 12) {
                        Stepper("", value: $inputHours, in: 0...999)
                            .labelsHidden()
                        Stepper("", value: $inputMinutes, in: 0...59)
                            .labelsHidden()
                    }
                }
            }
            
            // 自动累计计算逻辑
            let autoMinutes = book.readingLogs.reduce(0) { $0 + $1.minutes }
            if autoMinutes > 0 {
                HStack {
                    Text("记录累计")
                    Spacer()
                    Text("\(autoMinutes / 60)小时 \(autoMinutes % 60)分钟")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
    }

    private var timelineSection: some View {
        Section("阅读时间轴") {
            DatePicker("开始阅读", selection: $book.startDate, displayedComponents: .date)
                .tint(.orange)
            
            // 优化：处理可选日期绑定
            DatePicker("结束阅读", selection: Binding(
                get: { book.endDate ?? Date() },
                set: { book.endDate = $0 }
            ), displayedComponents: .date)
            .tint(.orange)
        }
    }
    
    private var tagSection: some View {
        Section("标签管理") {
            // 【此处调用了下面的 FlowLayout 和 TagView】
            FlowLayout(spacing: 10) {
                ForEach(book.tags, id: \.self) { tag in
                    TagView(tag: tag, color: Color.orange)
                        .onTapGesture {
                            isInputFocused = false
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation { book.tags.removeAll { $0 == tag } }
                        }
                }
                
                Button(action: triggerTagAlert) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("新标签")
                    }
                    .font(.caption.bold())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color.orange.opacity(0.12))
                    .foregroundColor(.orange)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.orange.opacity(0.3), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 8)
        }
    }
}

// MARK: - 辅助视图组件

// 1. 单个标签的视图
struct TagView: View {
    let tag: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
            Image(systemName: "xmark").font(.system(size: 8, weight: .bold))
        }
        .font(.caption.bold())
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(color.opacity(0.12))
        .foregroundColor(color)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(color.opacity(0.3), lineWidth: 1))
    }
}

// 2. 负责让标签“流式”排列的布局引擎
struct FlowLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var _: CGFloat = 0
        var maxRowHeight: CGFloat = 0
        var totalWidth: CGFloat = 0
        var totalHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > width {
                // 换行
                totalHeight += maxRowHeight + spacing
                currentX = 0
                maxRowHeight = 0
            }
            
            currentX += size.width + spacing
            maxRowHeight = max(maxRowHeight, size.height)
            totalWidth = max(totalWidth, currentX)
        }
        
        totalHeight += maxRowHeight
        return CGSize(width: totalWidth, height: totalHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX = bounds.minX
        var currentY = bounds.minY
        var maxRowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > bounds.maxX {
                // 换行
                currentY += maxRowHeight + spacing
                currentX = bounds.minX
                maxRowHeight = 0
            }
            
            subview.place(
                at: CGPoint(x: currentX, y: currentY),
                proposal: .unspecified
            )
            
            currentX += size.width + spacing
            maxRowHeight = max(maxRowHeight, size.height)
        }
    }
}

import SwiftUI

struct ReadingTimelineView: View {
    let books: [Book] // 假设 Book 模型在外部定义

    private var entries: [TimelineEntry] {
        ReadingInsightsBuilder.timeline(from: books)
    }

    var body: some View {
        List {
            if entries.isEmpty {
                // 修复点 1: 标准字符串字面量，Xcode 会自动提取 "暂无阅读记录" 和 "先去书柜更新阅读进度吧"
                ContentUnavailableView(
                    "暂无阅读记录",
                    systemImage: "timeline.selection",
                    description: Text("先去书柜更新阅读进度吧")
                )
                .frame(maxWidth: .infinity)
                .listRowSeparator(.hidden)
            } else {
                // 使用 enumerated 获取 index 判断是否是最后一条
                ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                    TimelineRow(
                        entry: entry,
                        isLast: index == entries.count - 1
                    )
                    .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("时间轴") // Xcode 会自动提取 "时间轴"
    }
}

// MARK: - 拆分的子视图：时间轴的每一行
struct TimelineRow: View {
    let entry: TimelineEntry
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // 左侧：时间轴节点与连线
            VStack(spacing: 0) {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 10, height: 10)
                
                if !isLast {
                    Rectangle()
                        .fill(Color.orange.opacity(0.25))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }

            // 右侧：内容区
            VStack(alignment: .leading, spacing: 10) {
                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.headline)

                HStack(spacing: 12) {
                    // 如果总数也有单位，建议改为 "\(entry.totalCount) 页" 的形式
                    Label("\(entry.totalCount)", systemImage: "book.pages")
                    
                    // 修复点 2: 移除 String(localized:)，直接写标准插值。
                    // Xcode 会自动在 String Catalog 提取出 "%lld 分钟"。
                    // 在其他语言(如英语)中，你可以直接将其翻译为 "%lld minutes" 并配置复数规则！
                    Label("\(entry.totalMinutes) 分钟", systemImage: "clock")
                }
                .font(.caption)
                .foregroundColor(.secondary)

                // 具体的阅读记录列表
                ForEach(entry.items) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.bookTitle)
                                .font(.subheadline.bold())
                                .lineLimit(1)
                            
                            // 修复点 3: 解决枚举/动态变量无法本地化的问题
                            // 使用 Text(LocalizedStringKey()) 将动态字符串转为可本地化的键
                            // 注意：你需要在 String Catalog 中手动添加枚举的值（例如 "页", "章"）
                            Text("\(item.log.count) \(Text(LocalizedStringKey(item.unit.rawValue)))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        
                        // 时间格式化会自动根据系统语言本地化，无需额外处理
                        Text(item.log.date, style: .time)
                            .font(.caption2.monospacedDigit())
                            .foregroundColor(.secondary)
                    }
                    .padding(10)
                    .background(Color.secondary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
            .padding(.bottom, 6)
        }
    }
}

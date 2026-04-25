import SwiftUI

struct BadgeWallView: View {
    let books: [Book] // 假设外部传入

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var badges: [ReadingBadge] {
        ReadingInsightsBuilder.badgeList(from: books)
    }

    private var unlockedCount: Int {
        badges.filter(\.unlocked).count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    // 修复点 1：移除 NSLocalizedString 和 String(format:)
                    // 直接使用标准插值，Xcode 会自动提取出 "已解锁 %lld/%lld" 词条
                    Text("已解锁 \(unlockedCount)/\(badges.count)")
                        .font(.subheadline.bold())
                    
                    Spacer()
                }

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(badges) { badge in
                        BadgeCell(badge: badge)
                    }
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("成就栏") // Xcode 会自动提取 "成就栏"
    }
}

private struct BadgeCell: View {
    let badge: ReadingBadge

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: badge.icon)
                .font(.system(size: 24))
                .foregroundColor(badge.unlocked ? .white : .secondary.opacity(0.6))
                .frame(width: 52, height: 52)
                .background((badge.unlocked ? badge.color : Color.gray.opacity(0.35)).gradient)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.7), lineWidth: badge.unlocked ? 1 : 0)
                )

            // 修复点 2：动态变量包装为 LocalizedStringKey
            // 请记住：需手动在 String Catalog 中添加 "夜猫子"、"读书破万卷" 等成就名称！
            Text(badge.title)
                .font(.subheadline.bold())
                .multilineTextAlignment(.center)

            // 修复点 3：拆分三元运算符，并使用 Group 统一添加修饰符
            Group {
                if badge.unlocked {
                    // 纯静态字面量，Xcode 自动提取 "已解锁"
                    Text("已解锁")
                } else {
                    // 动态提示语（如 "连续阅读7天解锁"），需手动在 String Catalog 中添加并翻译
                    Text(badge.hint)
                }
            }
            .font(.caption2)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .lineLimit(2)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .opacity(badge.unlocked ? 1 : 0.75)
    }
}

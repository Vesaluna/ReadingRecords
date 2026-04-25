import SwiftUI

struct ChallengeCenterView: View {
    let books: [Book] // 假设外部传入

    private var challenges: [ReadingChallenge] {
        ReadingInsightsBuilder.challengeList(from: books)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                ForEach(challenges) { challenge in
                    ChallengeCard(challenge: challenge)
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("任务栏") // Xcode 会自动提取 "任务栏"
    }
}

private struct ChallengeCard: View {
    let challenge: ReadingChallenge
    @State private var animatedProgress: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: challenge.icon)
                    .foregroundColor(.white)
                    .frame(width: 34, height: 34)
                    .background(challenge.tint.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    // 修复点 1：将动态变量包装为 LocalizedStringKey，使其能够在运行时去查找翻译
                    // 注意：由于是变量，你需要手动在 String Catalog 中添加挑战标题和副标题的具体词条！
                    Text(challenge.title)
                        .font(.headline)
                    Text(challenge.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                // 修复点 2：将三元运算符拆分为 if-else，让 SwiftUI 识别静态文本
                if challenge.isCompleted {
                    Text("已完成") // Xcode 会自动提取 "已完成"
                        .font(.caption.bold())
                        .foregroundColor(.green)
                } else {
                    // 假设 progressText 是 "3/5" 这种数字，通常不需要翻译。
                    // 但如果它包含汉字(如 "进度 3/5")，也需要用 LocalizedStringKey 包装：
                    Text(challenge.progressText)
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                }
            }

            ProgressView(value: animatedProgress)
                .tint(challenge.isCompleted ? .green : challenge.tint)
                .animation(.easeOut(duration: 0.9), value: animatedProgress)

            if challenge.isCompleted {
                // 修复点 3：直接传入字符串字面量，移除 String(localized:)
                // Xcode 会自动提取 "挑战已达成，继续冲刺更高目标！"
                Label("挑战已达成，继续冲刺更高目标！", systemImage: "checkmark.seal.fill")
                    .font(.caption)
                    .foregroundColor(.green)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(challenge.isCompleted ? Color.green.opacity(0.35) : Color.clear, lineWidth: 1)
        )
        .onAppear {
            animatedProgress = challenge.progress
        }
    }
}

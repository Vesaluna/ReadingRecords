import SwiftUI
import SwiftData

@main
struct ReadingRecordApp: App {
    // 使用 ObservedObject 确保能感知 LanguageManager 的变化
    @ObservedObject private var langManager = LanguageManager.shared

    var body: some Scene {
        WindowGroup {
            ZStack {
                // 主界面：绑定到 manager 的受控变量
                MainTabView()
                    .environment(\.locale, .init(identifier: langManager.currentDisplayLanguage))
                    .id(langManager.currentDisplayLanguage) // 强制销毁旧语言视图
                
                // 过渡大幕：盖在最上层
                if langManager.isSwitching {
                    LanguageSwitchView()
                        .zIndex(999) // 确保在绝对顶层
                        .transition(.opacity)
                }
            }
            // 响应切换动画
            .animation(.easeInOut(duration: 0.3), value: langManager.isSwitching)
        }
        .modelContainer(for: Book.self)
    }
}

// 过渡页面组件
struct LanguageSwitchView: View {
    var body: some View {
        ZStack {
            // 纯色背景，遮住所有内容
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // 确保你 Assets 里的图标名字是 "应用图标"
                Image("应用图标")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .cornerRadius(22)
                    .shadow(color: .black.opacity(0.15), radius: 15)
                
                ProgressView()
                    .tint(.orange)
                    .scaleEffect(1.2)
                
                Text("正在加载...") // 建议保留，提示用户正在切换
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        // 关键：拦截所有点击，防止用户在切换时乱点
        .contentShape(Rectangle())
        .onTapGesture {}
    }
}

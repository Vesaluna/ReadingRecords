import SwiftUI

struct AboutAppView: View {
    var body: some View {
        // 使用 List 配合 insetGrouped 样式营造 iOS 原生高级感
        List {
            // 第一部分：App 核心品牌展示
            Section {
                VStack(spacing: 16) {
                    Spacer(minLength: 10)
                    
                    // 应用图标：圆形裁切 + 细描边 + 柔和阴影
                    Image("应用图标")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.secondary.opacity(0.1), lineWidth: 0.5))
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    VStack(spacing: 8) {
                        Text("阅读记录")
                            .font(.title2)
                            .bold()
                        
                        Text("Version 1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer(minLength: 10)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear) // 背景透明，突出图标悬浮感
            }
            
            // 第二部分：开发信息
            Section {
                HStack {
                    Text("开发者")
                    Spacer()
                    Text("Huang HaiXin")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("产品设计")
                    Spacer()
                    Text("Diego Chen")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("资源测试")
                    Spacer()
                    Text("Vittorio Zhu")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("开发周期")
                    Spacer()
                    Text("2026/04/18 ~ 2026/04/25")
                        .foregroundColor(.secondary)
                }
            }
            
            // 第三部分：社交媒体
            Section("关注我") {
                HStack {
                    Spacer()
                    
                    Link(destination: URL(string: "https://space.bilibili.com/509666195")!) {
                        VStack(spacing: 8) {
                            Image("Bilibili")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 36, height: 36) // 稍微调大了一点点，视觉更平衡
                            
                            Text("Bilibili")
                                .font(.caption2)
                                .fontWeight(.medium)
                        }
                    }
                    .foregroundColor(.pink)
                    .buttonStyle(.plain) // 依然建议保留，防止 List 触发整行点击逻辑
                    
                    Spacer()
                }
                .padding(.vertical, 12)
            }

            // 第四部分：版权申明
            Section {
                VStack(spacing: 4) {
                    Text("© 2026 废怯少女 All Rights Reserved.")
                }
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("关于")
        .navigationBarTitleDisplayMode(.inline)
    }
}

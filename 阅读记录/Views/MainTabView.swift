//
//  MainTabView.swift
//  阅读记录
//
//  Created by Huang on 18/04/2026.
//
import SwiftUI

struct MainTabView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage = "zh-Hans"
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView()
                .tabItem { Label("书柜", systemImage: "list.bullet.rectangle.portrait") }
                .tag(0)
            
            StatisticsView()
                .tabItem { Label("统计", systemImage: "chart.pie.fill") }
                .tag(1)
            
            ProfileView()
                .tabItem { Label("我的", systemImage: "person.fill") }
                .tag(2)
        }
        .tint(.orange)
        // 关键：只注入环境，不重启视图
        .environment(\.locale, .init(identifier: selectedLanguage))
    }
}

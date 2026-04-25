//
//  LanguageManager.swift
//  阅读记录
//
//  Created by Huang on 19/04/2026.
//
import SwiftUI
import Combine

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    static let supportedLanguages = ["zh-Hans", "en", "it", "ja", "ko"]
    
    // 隐藏真实的存储，防止其他视图直接订阅它导致抢跑
    @AppStorage("selectedLanguage") private var storedLanguage = "zh-Hans"
    
    // UI 实际绑定的变量
    @Published var currentDisplayLanguage: String = "zh-Hans"
    @Published var isSwitching = false
    
    private init() {
        // 初始化时对齐存储的值
        self.currentDisplayLanguage = Self.supportedLanguages.contains(storedLanguage) ? storedLanguage : "zh-Hans"
    }
    
    func switchLanguage(to newLang: String) {
        guard Self.supportedLanguages.contains(newLang) else { return }
        // 第一步：瞬间拉起幕布（不要加动画，追求极致覆盖速度）
        isSwitching = true
        
        // 第二步：给 0.1 秒时间让 ZStack 把幕布渲染在最顶层
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // 第三步：此时幕布已盖死，修改语言
            self.storedLanguage = newLang
            self.currentDisplayLanguage = newLang
            
            // 第四步：停留 3 秒（覆盖所有后台 UI 重建的卡顿）
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                // 第五步：优雅淡出幕布
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.isSwitching = false
                }
            }
        }
    }
}



//
//  EditProfileView.swift
//  阅读记录
//
//  Created by Huang on 18/04/2026.
//
import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @AppStorage("username") private var username: String = "新用户"
    @AppStorage("userBio") private var userBio: String = "" // 个性签名
    @AppStorage("userAvatarData") private var userAvatarData: Data?
    
    @State private var selectedItem: PhotosPickerItem?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Form {
            Section {
                VStack(spacing: 12) {
                    HStack {
                        Spacer()
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            if let userAvatarData, let uiImage = UIImage(data: userAvatarData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 86, height: 86)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 86, height: 86)
                                    .foregroundColor(.orange.opacity(0.8))
                                    .shadow(color: .orange.opacity(0.2), radius: 4, x: 0, y: 2)
                            }
                        }
                        .onChange(of: selectedItem) { _, newItem in
                            processSelectedImage(newItem)
                        }
                        Spacer()
                    }
                    
                    // 仅当用户有自定义头像时，显示移除按钮
                    if userAvatarData != nil {
                        Button("移除头像", role: .destructive) {
                            withAnimation {
                                userAvatarData = nil
                                selectedItem = nil
                            }
                        }
                        .font(.caption)
                    } else {
                        Text("点击选取头像")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            Section("基本信息") {
                HStack {
                    Text("用户名")
                    Spacer()
                    TextField("请输入用户名", text: $username)
                        .multilineTextAlignment(.trailing)
                        // 限制字数，防止在分享卡片里把 UI 撑爆
                        .onChange(of: username) { _, newValue in
                            if newValue.count > 12 {
                                username = String(newValue.prefix(12))
                            }
                        }
                }
                
                HStack {
                    Text("个性签名")
                    Spacer()
                    TextField("一句话介绍自己", text: $userBio)
                        .multilineTextAlignment(.trailing)
                        .onChange(of: userBio) { _, newValue in
                            if newValue.count > 20 {
                                userBio = String(newValue.prefix(20))
                            }
                        }
                }
            }
        }
        .navigationTitle("编辑资料")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively) // 滑动表单时自动收起键盘
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("完成") { dismiss() }
            }
        }
    }
    
    // MARK: - 图片处理逻辑
    private func processSelectedImage(_ item: PhotosPickerItem?) {
        Task {
            if let data = try? await item?.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                
                // ⚠️ 关键性能优化：将大图压缩并裁剪成小图，防止撑爆 AppStorage
                let compressedData = compressAndResizeImage(uiImage)
                
                await MainActor.run {
                    self.userAvatarData = compressedData
                }
            }
        }
    }
    
    private func compressAndResizeImage(_ image: UIImage) -> Data? {
        let size = CGSize(width: 200, height: 200) // 头像不需要超过 200x200
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0 // 强制 1x 缩放，保持极小体积
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        
        // 压成 JPEG 格式，质量设为 0.6，体积通常只有几KB到十几KB
        return resizedImage.jpegData(compressionQuality: 0.6)
    }
}

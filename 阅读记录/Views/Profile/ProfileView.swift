import SwiftUI
import UIKit
import SwiftData
import MessageUI
import UniformTypeIdentifiers

// 1. 定义一个简单的包装器，避免扩展系统 URL，解决 Identifiable 报错
struct ExportFile: Identifiable {
    let id = UUID()
    let url: URL
}

struct ProfileView: View {
    @ObservedObject private var langManager = LanguageManager.shared
    @Environment(\.modelContext) private var modelContext
    @Query private var allBooks: [Book]
    
    @AppStorage("username") private var username: String = "新用户"
    @AppStorage("userAvatarData") private var userAvatarData: Data?
    
    // 状态变量
    @State private var isShowingMailView = false
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil
    
    @State private var isImporting = false
    @State private var exportFile: ExportFile? // 使用包装对象触发 Sheet

    var body: some View {
        NavigationStack {
            List {
                // 1. 用户信息头部
                Section {
                    NavigationLink(destination: EditProfileView()) {
                        HStack(spacing: 15) {
                            if let userAvatarData, let uiImage = UIImage(data: userAvatarData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.orange)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(username).font(.headline)
                                Text("查看并编辑个人资料").font(.caption).foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // 2. 数据管理区
                Section("我的数据") {
                    NavigationLink(destination: ReadingHistoryView()) {
                        Label("我的回顾", systemImage: "clock.arrow.circlepath")
                    }
                    NavigationLink(destination: TagManagementView()) {
                        Label("我的标签", systemImage: "tag")
                    }
                    NavigationLink(destination: BookListView()) {
                        Label("我的数据", systemImage: "checklist")
                    }
                    

                }
                
                // 3. 设置区
                Section("设置") {
                    Picker(selection: Binding(
                        get: { langManager.currentDisplayLanguage },
                        set: { newValue in
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            langManager.switchLanguage(to: newValue)
                        }
                    )) {
                        Text("简体中文").tag("zh-Hans")
                        Text("English").tag("en")
                        Text("Italiano").tag("it")
                        Text("日本語").tag("ja")
                        Text("한국어").tag("ko")
                    } label: {
                        Label("切换语言", systemImage: "character.bubble")
                    }
                    .pickerStyle(.navigationLink)
                    
                    // 导出功能
                    Button {
                        exportData()
                    } label: {
                        Label("导出备份", systemImage: "square.and.arrow.up")
                    }
                    
                    // 导入功能
                    Button {
                        isImporting = true
                    } label: {
                        Label("导入备份", systemImage: "square.and.arrow.down")
                    }
                }

                // 4. 支持与反馈
                Section("支持与反馈") {
                    Button {
                        if MFMailComposeViewController.canSendMail() {
                            isShowingMailView = true
                        } else {
                            fallbackEmail()
                        }
                    } label: {
                        Label("意见反馈", systemImage: "bubble.left.and.exclamationmark.bubble.right")
                    }

                    NavigationLink(destination: AboutAppView()) {
                        Label("关于应用", systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle("个人中心")
            // 弹出邮件
            .sheet(isPresented: $isShowingMailView) {
                MailView(result: $mailResult)
            }
            // 弹出导出分享面板
            .sheet(item: $exportFile) { file in
                ShareSheet(activityItems: [file.url])
            }
            // 弹出文件选择器
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                handleImport(result: result)
            }
        }
    }

    // MARK: - 私有逻辑处理

    private func exportData() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let data = try encoder.encode(allBooks)
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("ReadingRecords_Backup.json")
            try data.write(to: tempURL)
            // 赋值触发 sheet
            self.exportFile = ExportFile(url: tempURL)
        } catch {
            print("导出失败: \(error)")
        }
    }

    // 修正后的 handleImport，处理 Result<[URL], Error> 类型
    private func handleImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            // 必须：请求安全访问权限
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let importedBooks = try decoder.decode([Book].self, from: data)
                
                for book in importedBooks {
                    modelContext.insert(book)
                }
                try? modelContext.save()
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } catch {
                print("解析失败: \(error)")
            }
        case .failure(let error):
            print("读取失败: \(error.localizedDescription)")
        }
    }

    private func fallbackEmail() {
        let email = "einsteinandviolin@gmail.com"
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - 辅助组件

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct MailView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    @Binding var result: Result<MFMailComposeResult, Error>?

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView
        init(_ parent: MailView) { self.parent = parent }
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            if let error = error { parent.result = .failure(error) }
            else { parent.result = .success(result) }
            parent.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients(["einsteinandviolin@gmail.com"])
        vc.setSubject("阅读记录 App 反馈")
        vc.mailComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}

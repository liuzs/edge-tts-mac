//
//  ContentView.swift
//  edge-tts-mac
//
//  Created by sanxi on 2024/12/10.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ContentView: View {
    // 绑定变量，存储用户输入的文本
    @State private var inputText: String = ""
    @State private var savePath: URL? = nil
    @State private var statusMessage: String = ""
    @State private var isGenerating = false
    private let generator = MP3Generator() // 实例化 MP3Generator 类
    var body: some View {
        VStack(alignment: .leading, spacing: 23.0) {
            // 标题
            Text("请输入文字")
                .font(.headline)
                .padding()
            // 多行输入框
            TextEditor(text: $inputText)
                .frame(minHeight: 300) // 设置高度，可以调节大小
                .cornerRadius(8) // 圆角
                .padding(.horizontal) // 左右边距
            // 按钮：生成MP3
            Button(action: {
                showSavePanel()
            }) {
                Text("生成 MP3")
                    .fontWeight(.bold)
                    .padding(.all)
            }
            .buttonStyle(.automatic)
            .padding(.horizontal)
            
            // 显示当前输入的内容（可选，用于调试）
            /*
            Text("你输入的内容: \(inputText)")
                .foregroundColor(.gray)
                .font(.subheadline)
            */
            Spacer() // 占位符，将内容推向顶部
        }
        .padding() // 为整个界面添加内边距
    }

    // 弹出保存路径选择对话框
    func showSavePanel() {
        let savePanel = NSSavePanel()
        savePanel.title = "保存 MP3 文件"
        savePanel.allowedContentTypes = [.audio]       // 允许的文件类型 (macOS 12+ 推荐)
        savePanel.nameFieldStringValue = "output.mp3"  // 默认文件名
        
        if savePanel.runModal() == .OK {   // 弹出面板并等待用户确认
            if let selectedURL = savePanel.url {
                savePath = selectedURL    // 赋值保存路径
                generateMP3()             // 调用生成 MP3 方法
            }
        }
    }

    // 生成 MP3 文件
    func generateMP3() {
        guard let path = savePath else { return }
        isGenerating = true
        statusMessage = "正在生成 MP3 文件..."

        generator.generateMP3(from: inputText, to: path) { success, message in
            DispatchQueue.main.async {
                isGenerating = false
                statusMessage = message
            }
        }
    }
}

#Preview {
    ContentView()
}

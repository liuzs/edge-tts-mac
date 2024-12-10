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
    @State private var isGenerating = false
    @State private var statusMessage: String = "准备就绪" // 默认状态
    @State private var progress: Double = 0.0
    private let generator = MP3Generator() // 实例化 MP3Generator 类
    var body: some View {
        HStack {
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
                
                // 进度条只在生成中时显示
                if isGenerating {
                    ProgressView(value: progress, total: 100)
                        .progressViewStyle(LinearProgressViewStyle())
                        .frame(width: 300, height: 10)
                        .padding()
                }
                // 按钮：生成MP3
                Button(action: {
                    showSavePanel()
                }) {
                    Text(isGenerating ? "生成中..." : "生成语音")
                        .fontWeight(.bold)
                        .padding(.all)
                }
                .disabled(isGenerating) // 生成中禁用按钮
                .buttonStyle(.automatic)
                .padding(.horizontal)
                
                Spacer() // 占位符，将内容推向顶部
                
                // 状态栏显示
                Text(statusMessage)
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding()
            }
            VStack(alignment: .leading, spacing: 20) {
                Text("控制选项")
                    .font(.headline)
            }
            .padding()
        } // 为整个界面添加内边距
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
        let voice = "zh-CN-XiaoxiaoNeural"
        let rate = "+0%"
        let pitch = "+0Hz"
        isGenerating = true
        progress = 0.0
        statusMessage = "正在生成 MP3 文件..."

        let progressUpdateInterval = 0.1 // 进度更新的时间间隔
        let progressIncrement = 2.0      // 每次增加的进度量
        
        // 模拟进度平滑增加
        var timer: Timer? = nil
        timer = Timer.scheduledTimer(withTimeInterval: progressUpdateInterval, repeats: true) { _ in
            if progress < 95.0 {  // 最大进度为 95%
                progress += progressIncrement
            } else {
                timer?.invalidate() // 停止计时器
            }
        }

        // 执行实际的生成任务
        generator.generateMP3(from: inputText, to: path, voice: voice, rate: rate,pitch: pitch) { success, message in
            DispatchQueue.main.async {
                timer?.invalidate()       // 任务完成时停止进度模拟
                progress = 100.0          // 直接设置进度条到 100%
                isGenerating = false      // 生成完成
                statusMessage = success ? "MP3 文件生成完毕！" : "生成失败，请重试。"
            }
        }
    }
}

#Preview {
    ContentView()
}

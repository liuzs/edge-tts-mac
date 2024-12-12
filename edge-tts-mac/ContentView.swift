//
//  ContentView.swift
//  edge-tts-mac
//
//  Created by sanxi on 2024/12/10.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers
struct Voice: Identifiable, Hashable {
    let id = UUID() // 使用 UUID 作为唯一标识符
    let name: String
    let gender: String
    let contentCategories: String
    let voicePersonalities: [String]
}

struct ContentView: View {
    // 绑定变量，存储用户输入的文本
    @State private var inputText: String = "在这里输入文字..."
    @State private var savePath: URL? = nil
    @State private var isGenerating = false
    @State private var statusMessage: String = "准备就绪" // 默认状态
    @State private var progress: Double = 0.0
    @State private var rate: Double = 0.0    // rate 滑条的初始值
    @State private var pitch: Double = 0.0   // pitch 滑条的初始值
    let voices: [Voice] = [
        Voice(name: "zh-CN-XiaoxiaoNeural", gender: "Female", contentCategories: "News, Novel", voicePersonalities: ["Warm"]),
        Voice(name: "zh-CN-XiaoyiNeural", gender: "Female", contentCategories: "Cartoon, Novel", voicePersonalities: ["Lively"]),
        Voice(name: "zh-CN-YunjianNeural", gender: "Male", contentCategories: "Sports, Novel", voicePersonalities: ["Passion"]),
        Voice(name: "zh-CN-YunxiNeural", gender: "Male", contentCategories: "Novel", voicePersonalities: ["Lively", "Sunshine"]),
        Voice(name: "zh-CN-YunxiaNeural", gender: "Male", contentCategories: "Cartoon, Novel", voicePersonalities: ["Cute"]),
        Voice(name: "zh-CN-YunyangNeural", gender: "Male", contentCategories: "News", voicePersonalities: ["Professional", "Reliable"]),
        Voice(name: "zh-CN-liaoning-XiaobeiNeural", gender: "Female", contentCategories: "Dialect", voicePersonalities: ["Humorous"]),
        Voice(name: "zh-CN-shaanxi-XiaoniNeural", gender: "Female", contentCategories: "Dialect", voicePersonalities: ["Bright"]),
        Voice(name: "ja-JP-KeitaNeural", gender: "Male", contentCategories: "General", voicePersonalities: ["Friendly", "Positive"]),
        Voice(name: "ja-JP-NanamiNeural", gender: "Female", contentCategories: "General", voicePersonalities: ["Friendly", "Positive"])
        // 可以继续手动添加更多数据...
    ]
    @State private var selectedVoice: Voice? = nil
    private let generator = MP3Generator() // 实例化 MP3Generator 类
    var body: some View {
        VStack {
            HStack { // 水平布局
                
                //主内容区域 (ZStack 或 TextEditor)
                VStack(alignment: .leading, spacing: 23.0) {
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

                    
                    // 状态栏显示
                    Text(statusMessage)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding()
                }
                
                //侧边栏 (VStack)
                VStack(alignment: .leading, spacing: 20) {
                    
                    Divider() // 分隔线
                    // Model 选择控件
                    Text("语音模型")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, 8)
                    
                    HStack {
                        // 将表格数据手动填充为静态数组

                        Picker("选择模型", selection: $selectedVoice) {
                            ForEach(voices) { voice in
                                Text(voice.name).tag(voice) // 直接将 voice 作为 tag
                            }
                        }
                        .pickerStyle(MenuPickerStyle()) // 使用菜单样式
                        

                    }
                    
                    // Rate 滑条
                    HStack {
                        Text("语速")
                            .frame(width: 50, alignment: .leading)
                        Text(String(format: "+%.0f%%", rate)) // 动态显示滑条值，格式化为整数百分比
                            .foregroundColor(.gray)
                    }
                    Slider(value: $rate, in: -100...100, step: 1) // 范围 -100% 到 100%，步进为 1%
                    
                    // Pitch 滑条
                    HStack {
                        Text("音高")
                            .frame(width: 50, alignment: .leading)
                        Text(String(format: "+%.0fHz", pitch)) // 动态显示滑条值，格式化为 Hz
                            .foregroundColor(.gray)
                    }
                    Slider(value: $pitch, in: -50...50, step: 1) // 范围 -50Hz 到 50Hz，步进为 1Hz

                    // 重置按钮
                    Button(action: {
                        // 重置所有控件的值
                        selectedVoice = voices.first        // 重置 Picker 为第一个模型
                        rate = 0.0                          // 重置 Rate 滑条
                        pitch = 0.0                         // 重置 Pitch 滑条
                    }) {
                        Text("重置")
                    }

                    Divider() // 分隔线
                    
                    // Properties 信息
                    VStack(alignment: .leading, spacing: 10) {
                        Text("属性")
                            .font(.caption)
                            .foregroundColor(.gray)

                        if let voice = selectedVoice { // 解包 selectedVoice
                            // Gender 显示
                            HStack {
                                Image(systemName: "person.fill") // 使用一个适合的图标
                                Text("性别")
                                    .frame(width: 120, alignment: .leading)
                                Text(voice.gender) // 使用解包后的 voice.gender
                                    .foregroundColor(.gray)
                            }
                            
                            // ContentCategories 显示
                            HStack {
                                Image(systemName: "tag.fill") // 一个标签图标
                                Text("内容分类")
                                    .frame(width: 120, alignment: .leading)
                                Text(voice.contentCategories) // 使用 voice.contentCategories
                                    .foregroundColor(.gray)
                            }

                            // VoicePersonalities 显示
                            HStack {
                                Image(systemName: "star.fill") // 使用星形图标
                                Text("人格")
                                    .frame(width: 120, alignment: .leading)
                                Text(voice.voicePersonalities.joined(separator: ", ")) // 将 personality 合并为字符串显示
                                    .foregroundColor(.gray)
                            }
                        } else {
                            // 如果 selectedVoice 是 nil，可以显示一个默认提示
                            Text("请选择一个模型来查看属性")
                                .foregroundColor(.gray)
                                .italic()
                        }
                    }
                    
                    Spacer() // 占位符，将内容推到顶部
                }
                .onAppear {
                    selectedVoice = voices.first
                }
            }

            .padding()
            // 为整个界面添加内边距
        }
        
        //顶栏（Toolbar 或 HStack）
        .toolbar {
            ToolbarItem(placement: .automatic) {
                
                Button(action: {
                    showSavePanel()
                    print("导出按钮被点击")
                }) {
                    Image(systemName: "square.and.arrow.up")
                    Text("导出音频")
                        .foregroundColor(.blue)
                }
                .disabled(isGenerating) // 生成中禁用按钮
            }
        }
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
        guard let voice = selectedVoice?.name else {
            print("请选择一个有效的模型")
            return
        }
        let rateString = String(format: "+%.0f%%", rate)
        let pitchString = String(format: "+%.0fHz", pitch)
        isGenerating = true
        progress = 0.0
        statusMessage = "正在生成 MP3 文件..."

        let progressUpdateInterval = 0.1 // 进度更新的时间间隔
        var timer: Timer? = nil

        let wordCount = inputText.count // 获取文本字数
        let timePer10Words = 0.5 // 每10个字用时 0.5 秒
        let totalDuration = Double(wordCount) / 10.0 * timePer10Words // 根据字数计算总时长
        let totalUpdates = totalDuration / progressUpdateInterval // 总更新次数
        let progressIncrement = 95.0 / totalUpdates // 每次增加的进度量（最大95%）

        progress = 0.0 // 重置进度条

        timer = Timer.scheduledTimer(withTimeInterval: progressUpdateInterval, repeats: true) { _ in
            if progress < 95.0 { // 最大进度为 95%
                progress += progressIncrement
            } else {
                timer?.invalidate() // 停止计时器
            }
        }

        // 执行实际的生成任务
        generator.generateMP3(from: inputText, to: path, voice: voice, rate: rateString,pitch: pitchString) { success, message in
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

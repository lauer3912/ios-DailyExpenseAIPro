# DailyExpenseAIPro — 记账预算 App

## 项目概述
DailyExpenseAIPro 是一款专业的个人财务管理应用，专为欧美市场设计。

**核心功能**:
- 收支记录与管理
- 预算跟踪与提醒
- 储蓄目标
- 报表统计与分析
- Widget 支持
- AI 智能分析

**技术栈**:
- SwiftUI + MVVM
- iOS 17.0+
- Core Data (本地存储)
- WidgetKit
- Charts (图表库)

## 开发环境
- Xcode 15+
- iOS 17.0+
- Swift 5.9

## 项目结构
```
DailyExpenseAIPro/
├── SPEC.md          # 项目详细规格
├── project.yml      # XcodeGen 配置文件
├── Sources/         # 应用源代码
│   ├── Info.plist
│   ├── DailyExpenseAIProApp.swift
│   ├── views/
│   │   └── MainTabView.swift
│   ├── models/      # 数据模型
│   ├── viewmodels/  # ViewModel
│   └── helpers/     # 工具类
├── Widgets/         # Widget 扩展
│   ├── Info.plist
│   ├── DailyExpenseAIProWidget.swift
│   └── DailyExpenseAIProWidget.entitlements
└── Configs/         # 配置文件
    ├── Debug.xcconfig
    └── Release.xcconfig
```

## 快速开始

### 1. 生成 Xcode 项目
```bash
# 使用 XcodeGen 生成 .xcodeproj
xcodegen
```

### 2. 打开项目
```bash
open DailyExpenseAIPro.xcodeproj
```

### 3. 运行
- 选择模拟器或连接真机
- Cmd + R 运行

## 功能清单 (50+)

### 基础功能
1. ✅ 收支记录
2. ✅ 多账户管理
3. ✅ 预算设置
4. ✅ 储蓄目标
5. ✅ 报表统计
6. ✅ 账单管理
7. ✅ 债务追踪
8. ✅ 数据导出

### 高级功能
9. ⬜ 云同步 (Premium)
10. ⬜ 家庭共享
11. ⬜ Apple Watch App
12. ⬜ Siri Shortcuts
13. ⬜ Face ID/Touch ID
14. ⬜ 语音输入
15. ⬜ OCR 收据识别
16. ⬜ AI 智能分析

### 辅助功能
17. ⬜ Widget
18. ⬜ 重复记账
19. ⬜ 模板记账
20. ⬜ 自定义分类

## 变现模式

**Freemium 模式**:
- 免费版: 基础记账功能，2个账户
- Premium: $4.99/月 或 $39.99/年
  - 无限账户
  - 云同步
  - OCR 收据
  - AI 分析
  - 高级报表
  - Widget 高级功能
  - 家庭共享

## 颜色主题

### 深色模式
- 背景: `#0D1117`
- 卡片: `#161B22`
- 收入: `#00D4AA` (薄荷绿)
- 支出: `#FF6B6B` (珊瑚红)

### 浅色模式
- 背景: `#FAFBFC`
- 卡片: `#FFFFFF`
- 收入: `#006D77` (深海蓝)
- 支出: `#EF476F` (珊瑚橙)

## 发布要求

- ✅ 英文 Privacy Policy
- ✅ 英文 App Store 描述
- ✅ iPhone 6.9" + iPad 12.9" 截图
- ✅ 60秒操作演示视频
- ✅ 无中文字符

## 隐私政策

隐私政策页面: https://lauer3912.github.io/ios-DailyExpenseAIPro/docs/PrivacyPolicy.html

## 开发者

- Team: ZhiFeng Sun (9L6N2ZF26B)
- Developer: PageBrin
- GitHub: lauer3912

## License

MIT License
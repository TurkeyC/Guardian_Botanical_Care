# Guardian Botanical Care (gbc_flutter)

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

**Guardian Botanical Care** 是一个基于 Flutter 开发的跨平台AI绿植养护助手应用。无论您是植物爱好者还是园艺新手，本应用都致力于为您提供便捷、智能的植物管理体验。

---

## 目录

- [项目简介](#项目简介)
- [主要特性](#主要特性)
- [技术栈](#技术栈)
- [项目结构](#项目结构)
- [快速开始](#快速开始)
- [核心功能](#核心功能)
  - [应用工作流](#应用工作流)
  - [植物识别](#植物识别)
- [贡献指南](#贡献指南)
- [许可证](#许可证)

---

## 项目简介

`gbc_flutter` 项目旨在解决植物养护过程中的常见问题，例如品种识别、信息管理等。应用充分利用 Flutter 的跨平台能力，目前主要为 Android 和 Windows 平台提供支持，并计划在未来扩展到更多平台。

项目代码结构清晰，注释完善，易于二次开发和维护。

## 主要特性

- **跨平台兼容**: 一套代码库，多端运行，目前支持 Android 和 Windows。
- **植物识别**: 通过拍照或相册选图，快速识别植物品种。
- **多媒体支持**: 集成图片、视频的采集与播放功能。
- **原生能力集成**: 包含定位服务、系统权限管理等。
- **自定义主题**: 支持主题切换，提供丰富的自定义组件。
- **数据持久化**: 使用 `sqflite` 和 `shared_preferences` 进行本地数据存储。

## 技术栈

本项目主要依赖以下技术和库：

- **核心框架**: [Flutter](https://flutter.dev/)
- **状态管理**: [Provider](https://pub.dev/packages/provider)
- **路由管理**: Flutter 内置 Navigator
- **本地数据库**: [sqflite](https://pub.dev/packages/sqflite)
- **键值对存储**: [shared_preferences](https://pub.dev/packages/shared_preferences)
- **原生能力**:
  - [permission_handler](https://pub.dev/packages/permission_handler) (权限管理)
  - [geolocator](https://pub.dev/packages/geolocator) (地理位置)
  - [image_picker](https://pub.dev/packages/image_picker) (图片选择)
- **多媒体**:
  - [video_player](https://pub.dev/packages/video_player) / [media_kit_video](https://pub.dev/packages/media_kit_video) (视频播放)

详细依赖请查阅 `pubspec.yaml` 文件。

## 项目结构

项目采用分层架构，将业务逻辑、UI 和数据模型分离，便于管理和扩展。

```
gbc_flutter/
├── lib/                      # Dart 源码
│   ├── main.dart             # 应用入口
│   ├── models/               # 数据模型
│   ├── providers/            # 状态管理
│   ├── screens/              # UI 页面
│   ├── services/             # 业务服务 (如数据库、API调用)
│   ├── themes/               # 主题样式
│   └── widgets/              # 可复用的UI组件
├── assets/                   # 静态资源 (图片, 视频, 字体等)
├── android/                  # Android 平台特定代码
├── windows/                  # Windows 平台特定代码
└── test/                     # 测试代码
```

## 快速开始

请确保您已正确安装并配置 Flutter 环境。

1.  **克隆仓库**
    ```bash
    git clone https://github.com/TurkeyC/Guardian_Botanical_Care.git
    cd gbc_flutter
    ```

2.  **安装依赖**
    ```bash
    flutter pub get
    ```

3.  **运行应用**
    ```bash
    flutter run
    ```

4.  **构建发布包**
    ```bash
    # 构建 Android APK
    flutter build apk --release

    # 构建 Windows 应用
    flutter build windows --release
    ```

---

## 核心功能

### 应用工作流

1.  **启动**: 应用从 `lib/main.dart` 开始执行，完成全局依赖注入、Provider 初始化和主题加载。
2.  **导航**: 用户通过底部导航栏或页面内交互，在首页、拍摄识别、植物管理等不同功能模块间切换。
3.  **数据交互**:
    - **UI 层 (`screens`, `widgets`)**: 负责界面展示和用户输入。
    - **状态管理层 (`providers`)**: 管理应用状态，并将其通知给 UI 层进行更新。
    - **服务层 (`services`)**: 封装具体的业务逻辑，如数据库操作、文件读写、API 请求等。
    - **模型层 (`models`)**: 定义应用所需的数据结构。

### 植物识别

本项目的核心功能之一是植物识别，其实现流程如下：

1.  **图像采集**: 用户在识别页面可以通过 `image_picker` 插件启动相机进行**拍照**，或从**相册选择**已有的植物图片。
2.  **图像处理**:
    - 应用获取到图片后，可能会进行压缩或格式化处理，以优化识别效率和网络传输。
    - 识别逻辑分为**端侧识别**和**云端识别**两种模式：
      - **端侧识别**: 如果集成了本地模型（如 TensorFlow Lite），则直接在设备上进行推理分析。
      - **云端识别**: 将图片上传至后端服务器或第三方植物识别 API。
3.  **结果展示**:
    - 识别服务返回植物的名称、科属、简介、养护建议等信息。
    - 结果将清晰地展示在结果页面，并提供保存识别记录的选项。

> 该功能的具体实现代码，请参考 `screens/` 目录下的识别相关页面及 `services/` 目录下的识别服务。

## 贡献指南

我们欢迎任何形式的贡献！如果您希望参与项目，请遵循以下步骤：

1.  **Fork** 本仓库。
2.  创建您的特性分支 (`git checkout -b feature/AmazingFeature`)。
3.  提交您的更改 (`git commit -m 'Add some AmazingFeature'`)。
4.  将分支推送到远程 (`git push origin feature/AmazingFeature`)。
5.  **提交 Pull Request** 并详细描述您的更改。

也欢迎通过 [Issues](https://github.com/TurkeyC/Guardian_Botanical_Care/issues) 报告 Bug 或提出功能建议。

## 许可证

本项目遵循 [GNU General Public License v3.0](LICENSE) 开源许可协议。

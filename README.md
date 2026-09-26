# Compositor 中文版

这是 [Compositor](https://github.com/robbietilton/Compositor) 的独立简体中文维护版本，面向图像合成和照片后期工作。保留英文界面与原有编辑能力，在原生 SwiftUI、AppKit 界面中提供简体中文。

中文基础来自 [qg-lin 的 PR #126](https://github.com/robbietilton/Compositor/pull/126)，保留原作者提交署名；本仓库继续补齐新版功能、运行时提示和专业术语，并修复语言切换与独立 fork 配置。原项目与贡献者的 MIT 许可见 [LICENSE](LICENSE)。

## 本地使用

要求 macOS 26.5 或更新版本；从源码构建要求 Xcode 26.6 或更新版本。

```sh
./scripts/build-local.sh
```

命令输出本地应用的完整路径。也可以在 Xcode 中打开 `Compositor.xcodeproj`，运行 **Compositor** scheme。本地应用使用 ad-hoc 签名，尚未通过 Developer ID 签名与 Apple 公证；不能把它当作正式分发包。

在应用菜单的 **语言 / Language** 中选择“简体中文”“English”或“跟随系统”。设置保存后，先保存工作，退出应用并重新打开，新语言才会生效。

## 中文覆盖

菜单、工具栏、图层和图层组、混合模式、调整图层、滤镜、Camera Raw、图层效果、拾色器、快捷键设置、辅助功能标签，以及 PSD/PSB 转换与错误提示均使用中文资源。包括新版仿色、最近使用的项目、文字编辑和彩色滑块。

术语参照 Photoshop 简体中文界面，详见 [术语与维护规则](docs/zh-Hans-terminology.md)。算法名、格式名、字体家族、单位和键名保留规范写法；用户输入的图层名称、文字内容和文件名保持原样。`.comp` 格式和内部标识保持兼容。

## 编辑能力

- 图层与图层组、混合模式、图层蒙版、剪贴蒙版、调整图层与图层效果。
- 非破坏变换、扭曲、裁切、参考线、网格与吸附。
- 选框、套索、魔棒、对象选择、主体选择与内容识别填充。
- 画笔、橡皮擦、污点修复、仿制图章、涂抹、液化、渐变、形状和可编辑文字。
- 色阶、曲线、色相／饱和度、Camera Raw、模糊、杂色与仿色等调整和滤镜。
- 多项目标签页；导入常见图像格式、相机 RAW、SVG、PSD/PSB；导出 PNG/JPEG。

PSD/PSB 导入仍遵守上游的格式限制：主要支持 8 位 RGB，部分 Photoshop 功能会转换或栅格化，导入前显示转换报告。中文支持不会增加 Photoshop 文件兼容能力。

AI 或脚本操作 `.comp` 项目请参阅 [项目写入说明](docs/writing-comp-files.md) 与 [文件格式](docs/project-format.md)。

## 验证与维护

```sh
./scripts/test-localization.sh          # 英文、简体中文完整回归
./scripts/test-localization.sh zh-Hans  # 只跑简体中文
python3 scripts/check-localization.py   # 资源、格式参数和运行时 helper 检查
```

测试会检查构建产物中的中文资源、主要枚举和快捷键、专业术语、菜单功能、语言偏好隔离与持久化标识。完整回归在两种启动语言下执行；需要真实窗口的测试单独串行。CI 使用相同的双语言配置。

## 独立版本与发布

应用标识为 `io.github.lento52.compositor-cn`，与官方应用的偏好设置和窗口状态分开保存，可以同时安装。已移除上游 Sparkle 自动更新和对应网络、更新助手权限；当前采用手动更新。

本地构建会验证实际签名、权限、独立应用标识和中文资源，不发布、不推送。正式分发时，维护者需提供自己的 `CN_TEAM_ID`、`CN_SIGN_IDENTITY` 与保存在 Keychain 的 `CN_NOTARY_PROFILE`，再执行 `scripts/release.sh`。该脚本只生成签名、公证后的 DMG。

用户批准发布后，`scripts/publish.sh DMG路径 cn-v版本 发布说明文件` 可在 **Lento52/Compositor_CN** 创建草稿 Release，要求标签已存在于远端；不会更新 feed、提交或推送。正式签名、公证与远端发布需要届时单独验证。

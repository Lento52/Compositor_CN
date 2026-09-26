# Compositor 中文版

这是 [Compositor](https://github.com/robbietilton/Compositor) 的独立简体中文维护版本，面向图像合成和照片后期工作。保留英文界面与原有编辑能力，在原生 SwiftUI、AppKit 界面中提供简体中文。

中文基础来自 [qg-lin 的 PR #126](https://github.com/robbietilton/Compositor/pull/126)，保留原作者提交署名；本仓库继续补齐新版功能、运行时提示和专业术语，并修复语言切换与独立 fork 配置。原项目与贡献者的 MIT 许可见 [LICENSE](LICENSE)。

## 下载安装

在 [Releases](https://github.com/Lento52/Compositor_CN/releases) 下载中文版 DMG；要求 macOS 26.5 或更新版本，包含 Apple 芯片与 Intel 两种架构。将“Compositor 中文版.app”拖到 Applications。

当前安装包使用临时（ad-hoc）签名，**没有 Developer ID 签名，也没有通过 Apple 公证**。首次打开可能受到 macOS 限制；确认来源与 SHA-256 校验值后，参考 [Apple 官方说明](https://support.apple.com/zh-cn/102445)，在“系统设置 > 隐私与安全性”中为该应用选择“仍要打开”。Intel 架构已编译，尚未在 Intel 实机上验证。

## 本地使用

要求 macOS 26.5 或更新版本；从源码构建要求 Xcode 26.6 或更新版本。

```sh
./scripts/build-local.sh
```

命令输出本地应用的完整路径。也可以在 Xcode 中打开 `Compositor.xcodeproj`，运行 **Compositor** scheme。本地应用使用 ad-hoc 签名，尚未通过 Developer ID 签名与 Apple 公证。

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

本地构建会验证实际签名、权限、独立应用标识和中文资源，不发布、不推送。无需 Developer ID 的通用安装包可用 `scripts/package-unnotarized.sh cn-v1.3.3-1` 生成；输出 DMG 与 SHA-256 校验值，明确标注未公证。

维护者确认发布后，推送 `cn-v版本-修订号` 标签可触发 `Release CN` 工作流，在 **Lento52/Compositor_CN** 构建、检查并发布未公证的 DMG；发布说明须预先放在 `docs/releases/标签.md`。仅发布步骤获得仓库内容写权限，不需要个人访问令牌。

如未来需要 Developer ID 签名与 Apple 公证，维护者提供自己的 `CN_TEAM_ID`、`CN_SIGN_IDENTITY` 与保存在 Keychain 的 `CN_NOTARY_PROFILE` 后，执行 `scripts/release.sh`。该脚本只生成签名、公证后的 DMG。`scripts/publish.sh DMG路径 cn-v版本 发布说明文件` 可手动创建草稿 Release。

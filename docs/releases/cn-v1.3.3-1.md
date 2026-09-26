首个独立简体中文安装包，基于上游 Compositor 1.3.3 与 [qg-lin 的 PR #126](https://github.com/robbietilton/Compositor/pull/126)。代码来自本仓库 `codex/simplified-chinese` 分支，保留原作者提交署名及 MIT 许可。

## 下载与安装

- 下载 `Compositor-CN-1.3.3-1-universal.dmg`，将“Compositor 中文版.app”拖到 Applications。
- 要求 **macOS 26.5 或更新版本**；包含 Apple 芯片（arm64）和 Intel（x86_64）两种架构。已在 Apple 芯片上运行验收；Intel 架构通过编译，尚未在 Intel 实机上验证。
- `SHA256SUMS.txt` 提供安装包的 SHA-256 校验值。
- **安装包使用临时（ad-hoc）签名，未使用 Developer ID 签名，未通过 Apple 公证。** 首次打开可能受到 macOS 限制；确认来源和校验值后，可参考 [Apple 官方说明](https://support.apple.com/zh-cn/102445)，在“系统设置 > 隐私与安全性”中为该应用选择“仍要打开”。

## 本次变化

- 简体中文资源增至 1,171 条，覆盖菜单、工具、图层效果、Camera Raw、PSD 转换提示、仿色和最近打开等界面。
- 统一“文字”“图层组”“拾色器”“黑场／灰场／白场”“仿色”等 Photoshop 术语。
- 保留英文界面。在应用菜单“语言 / Language”中切换，保存工作、退出并重新打开后生效。
- 使用独立应用标识，可与官方版本同时安装；移除官方自动更新服务，采用手动更新。
- 英文和简体中文各 449 项本地回归测试通过，GitHub 双语自动测试通过；构建时检查中文资源、签名、沙盒权限和两种架构。

PSD/PSB 导入仍遵守上游兼容限制，未扩大 Photoshop 文件支持范围。尚未逐项人工遍历所有功能或进行全量文件模糊测试。

## English

This is the first independently maintained Simplified Chinese build, based on Compositor 1.3.3 and PR #126. Original commit attribution and the MIT license are preserved.

Requires macOS 26.5 or later. The DMG contains arm64 and x86_64 binaries; runtime validation was performed on Apple Silicon, while Intel support has been compile-checked only. **This build is ad-hoc signed, without Developer ID signing or Apple notarization.** macOS may block the first launch; see [Apple's guidance](https://support.apple.com/en-us/102445). SHA-256 checksums are included.

The release extends Chinese coverage to newer features, uses established Photoshop terminology, retains English support, and separates its preferences and update configuration from the official app. Updates are manual. Upstream PSD/PSB compatibility limits still apply.

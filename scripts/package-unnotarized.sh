#!/bin/zsh
# 生成通用架构、ad-hoc 签名的 DMG；不公证、不上传、不修改 Git。
set -euo pipefail
[[ $# -ge 1 && $# -le 2 ]] || { echo "用法：$0 cn-v版本-修订号 [输出目录]"; exit 1; }
TAG="$1"
[[ "$TAG" =~ '^cn-v[0-9]+\.[0-9]+\.[0-9]+-[0-9]+$' ]] || { echo "标签格式应为 cn-v1.3.3-1"; exit 1; }
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT_ROOT="${2:-$PROJECT_DIR/dist}"
mkdir -p "$OUTPUT_ROOT" "$PROJECT_DIR/build"
OUTPUT_DIR="$(mktemp -d "$OUTPUT_ROOT/Compositor-CN-release-XXXXXX")"
WORK="$(mktemp -d "$PROJECT_DIR/build/package-XXXXXX")"
VERSION="${TAG#cn-v}"
DMG="$OUTPUT_DIR/Compositor-CN-$VERSION-universal.dmg"

xcodebuild build -quiet \
  -project "$PROJECT_DIR/Compositor.xcodeproj" -scheme Compositor -configuration Release \
  -destination 'generic/platform=macOS' -derivedDataPath "$WORK/DerivedData" \
  ARCHS='arm64 x86_64' ONLY_ACTIVE_ARCH=NO \
  CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY=- DEVELOPMENT_TEAM=""
python3 "$PROJECT_DIR/scripts/check-localization.py" --derived-data "$WORK/DerivedData"
APP="$WORK/DerivedData/Build/Products/Release/Compositor.app"
python3 "$PROJECT_DIR/scripts/check-local-build.py" "$APP"
python3 - "$APP" "$VERSION" <<'PY_CHECK'
from pathlib import Path
import plistlib
import subprocess
import sys

app = Path(sys.argv[1])
with (app / "Contents/Info.plist").open("rb") as source:
    info = plistlib.load(source)
assert info["CFBundleShortVersionString"] == sys.argv[2].rsplit("-", 1)[0], "标签与应用版本不一致"
binary = app / "Contents/MacOS" / info["CFBundleExecutable"]
subprocess.run(["lipo", str(binary), "-verify_arch", "arm64", "x86_64"], check=True)
print("Apple 芯片与 Intel 两种架构检查：通过")
PY_CHECK

mkdir -p "$WORK/dmg"
ditto "$APP" "$WORK/dmg/Compositor 中文版.app"
ln -s /Applications "$WORK/dmg/Applications"
cp "$PROJECT_DIR/LICENSE" "$WORK/dmg/LICENSE.txt"
cat > "$WORK/dmg/安装说明.txt" <<'INSTALL'
Compositor 中文版 / Compositor CN

要求 macOS 26.5 或更新版本；支持 Apple 芯片与 Intel。
将“Compositor 中文版.app”拖到 Applications，之后从“应用程序”打开。

本包使用临时（ad-hoc）签名，没有 Developer ID 签名，也没有通过 Apple 公证。
首次打开可能受到 macOS 安全检查限制。确认下载来源与 SHA-256 校验值后，
可参考 Apple 官方说明，在“系统设置 > 隐私与安全性”中为该应用选择“仍要打开”：
https://support.apple.com/zh-cn/102445

在应用菜单的“语言 / Language”中切换简体中文或英文；保存工作、退出并重新打开后生效。
当前采用手动更新，不连接官方自动更新服务。

Requires macOS 26.5 or later; includes arm64 and x86_64 binaries.
Drag the app to Applications. This build is ad-hoc signed, without Developer ID signing or Apple notarization.
See Apple's guidance above if macOS blocks the first launch.

Source: https://github.com/Lento52/Compositor_CN
Upstream: https://github.com/robbietilton/Compositor
Chinese localization foundation: https://github.com/robbietilton/Compositor/pull/126
INSTALL
hdiutil create -quiet -volname 'Compositor CN' -srcfolder "$WORK/dmg" -format UDZO "$DMG"
hdiutil verify "$DMG"
(cd "$OUTPUT_DIR" && shasum -a 256 "${DMG:t}" > SHA256SUMS.txt)
echo "未公证 DMG：$DMG"
echo "SHA-256 校验文件：$OUTPUT_DIR/SHA256SUMS.txt"

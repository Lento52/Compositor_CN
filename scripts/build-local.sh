#!/bin/zsh
# 构建本地验收应用；仅本机 ad-hoc 签名，不公证、不发布、不推送。
set -euo pipefail
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT_ROOT="${1:-$PROJECT_DIR/build}"
mkdir -p "$OUTPUT_ROOT"
OUTPUT_DIR="$(mktemp -d "$OUTPUT_ROOT/Compositor-CN-XXXXXX")"
DERIVED_DATA="$PROJECT_DIR/build/DerivedData"
xcodebuild build -quiet \
  -project "$PROJECT_DIR/Compositor.xcodeproj" -scheme Compositor -configuration Release \
  -destination "platform=macOS,arch=$(uname -m)" -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY=- DEVELOPMENT_TEAM="" ONLY_ACTIVE_ARCH=YES
python3 "$PROJECT_DIR/scripts/check-localization.py" --derived-data "$DERIVED_DATA"
ditto "$DERIVED_DATA/Build/Products/Release/Compositor.app" "$OUTPUT_DIR/Compositor 中文版.app"
python3 "$PROJECT_DIR/scripts/check-local-build.py" "$OUTPUT_DIR/Compositor 中文版.app"
echo "本地应用：$OUTPUT_DIR/Compositor 中文版.app"

#!/bin/zsh
# 使用维护者自己的 Developer ID 和 Keychain 公证配置构建正式 DMG。
# 示例：CN_TEAM_ID=团队标识 CN_SIGN_IDENTITY='Developer ID Application: …' \
#       CN_NOTARY_PROFILE=Keychain配置名 ./scripts/release.sh
set -euo pipefail
: "${CN_TEAM_ID:?请设置维护者自己的 CN_TEAM_ID}"
: "${CN_SIGN_IDENTITY:?请设置维护者自己的 CN_SIGN_IDENTITY}"
: "${CN_NOTARY_PROFILE:?请设置维护者自己的 CN_NOTARY_PROFILE}"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CACHE_ROOT="$HOME/Library/Caches/CompositorCNRelease"
mkdir -p "$CACHE_ROOT" "$PROJECT_DIR/dist"
WORK="$(mktemp -d "$CACHE_ROOT/build-XXXXXX")"
settings=$(xcodebuild -project "$PROJECT_DIR/Compositor.xcodeproj" -scheme Compositor -configuration Release -showBuildSettings 2>/dev/null)
VERSION=$(print -r -- "$settings" | awk -F' = ' '/ MARKETING_VERSION = /{print $2; exit}')
DMG="$PROJECT_DIR/dist/Compositor-CN-$VERSION.dmg"
[[ ! -e "$DMG" ]] || { echo "文件已存在，请先保留旧包或提高版本：$DMG"; exit 1; }
xcodebuild archive -quiet \
  -project "$PROJECT_DIR/Compositor.xcodeproj" -scheme Compositor -configuration Release \
  -destination "generic/platform=macOS" -archivePath "$WORK/Compositor.xcarchive" \
  -derivedDataPath "$WORK/DerivedData" CODE_SIGN_STYLE=Manual \
  CODE_SIGN_IDENTITY="$CN_SIGN_IDENTITY" DEVELOPMENT_TEAM="$CN_TEAM_ID" ENABLE_HARDENED_RUNTIME=YES
# 不保存凭证；这里只生成公开的签名配置。
python3 - "$WORK/ExportOptions.plist" "$CN_TEAM_ID" "$CN_SIGN_IDENTITY" <<'PY_CONFIG'
import plistlib, sys
with open(sys.argv[1], 'wb') as output:
    plistlib.dump({'method': 'developer-id', 'signingStyle': 'manual',
                  'teamID': sys.argv[2], 'signingCertificate': sys.argv[3]}, output)
PY_CONFIG
xcodebuild -exportArchive -quiet -archivePath "$WORK/Compositor.xcarchive" \
  -exportOptionsPlist "$WORK/ExportOptions.plist" -exportPath "$WORK/export"
APP_PATH="$WORK/export/Compositor.app"
codesign --verify --deep --strict "$APP_PATH"
ditto -c -k --keepParent "$APP_PATH" "$WORK/Compositor.zip"
xcrun notarytool submit "$WORK/Compositor.zip" --keychain-profile "$CN_NOTARY_PROFILE" --wait
xcrun stapler staple "$APP_PATH"
mkdir -p "$WORK/dmg"
ditto "$APP_PATH" "$WORK/dmg/Compositor 中文版.app"
ln -s /Applications "$WORK/dmg/Applications"
hdiutil create -quiet -volname 'Compositor CN' -srcfolder "$WORK/dmg" -format UDZO "$DMG"
codesign --sign "$CN_SIGN_IDENTITY" --timestamp "$DMG"
xcrun notarytool submit "$DMG" --keychain-profile "$CN_NOTARY_PROFILE" --wait
xcrun stapler staple "$DMG"
spctl --assess --type open --context context:primary-signature "$DMG"
echo "已生成正式包：$DMG；未发布、未推送。"

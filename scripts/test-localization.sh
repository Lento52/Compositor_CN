#!/bin/zsh
# 双语言完整回归；窗口测试单独串行，避免互相争用焦点。
set -euo pipefail
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DERIVED_DATA="${CN_TEST_DERIVED_DATA:-$PROJECT_DIR/build/TestDerivedData}"
RESULT_ROOT="$PROJECT_DIR/build/test-results"
mkdir -p "$RESULT_ROOT"
RESULT_DIR="$(mktemp -d "$RESULT_ROOT/run-XXXXXX")"
languages=(en zh-Hans)
if [[ $# == 1 ]]; then
  [[ "$1" == en || "$1" == zh-Hans ]] || { echo "语言只支持 en 或 zh-Hans"; exit 1; }
  languages=("$1")
fi
common=(-project "$PROJECT_DIR/Compositor.xcodeproj" -scheme Compositor \
        -destination "platform=macOS,arch=$(uname -m)" -derivedDataPath "$DERIVED_DATA")
xcodebuild build-for-testing -quiet "${common[@]}" CODE_SIGN_IDENTITY=- CODE_SIGN_STYLE=Manual DEVELOPMENT_TEAM=""
python3 "$PROJECT_DIR/scripts/check-localization.py" --derived-data "$DERIVED_DATA"
for language in "${languages[@]}"; do
  region=US
  [[ "$language" == en ]] || region=CN
  xcodebuild test-without-building -quiet "${common[@]}" -testLanguage "$language" -testRegion "$region" \
    -resultBundlePath "$RESULT_DIR/$language-unit.xcresult" -parallel-testing-enabled YES \
    -only-testing:CompositorTests -skip-testing:CompositorTests/FloatingPanelTests -skip-testing:CompositorTests/SliderSnapTests
  xcodebuild test-without-building -quiet "${common[@]}" -testLanguage "$language" -testRegion "$region" \
    -resultBundlePath "$RESULT_DIR/$language-window.xcresult" -parallel-testing-enabled NO \
    -only-testing:CompositorTests/FloatingPanelTests -only-testing:CompositorTests/SliderSnapTests
done
echo "双语言回归结果：$RESULT_DIR"

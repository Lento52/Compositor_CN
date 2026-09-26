#!/usr/bin/env python3
"""验证本地 Release 应用的实际签名、权限、身份与中文资源。"""
from pathlib import Path
import json
import plistlib
import subprocess
import sys

app = Path(sys.argv[1])
subprocess.run(["codesign", "--verify", "--deep", "--strict", str(app)], check=True)
signed = subprocess.run(["codesign", "-d", "--entitlements", ":-", str(app)],
                        capture_output=True, check=True)
rights = plistlib.loads(signed.stdout)
assert rights.get("com.apple.security.app-sandbox") is True, "未启用应用沙盒"
assert rights.get("com.apple.security.files.user-selected.read-write") is True, "缺少用户所选文件权限"
for key in ["com.apple.security.network.client", "com.apple.security.network.server",
            "com.apple.security.temporary-exception.mach-lookup.global-name", "com.apple.security.get-task-allow"]:
    assert not rights.get(key), f"Release 应用不应包含此权限：{key}"
with (app / "Contents/Info.plist").open("rb") as source:
    info = plistlib.load(source)
assert info["CFBundleIdentifier"] == "io.github.lento52.compositor-cn", "应用标识未隔离"
assert not any(key.startswith("SU") for key in info), "仍包含 Sparkle 更新配置"
assert not (app / "Contents/Frameworks/Sparkle.framework").exists(), "仍打包了上游更新器"
for table in ["Localizable", "InfoPlist"]:
    path = app / f"Contents/Resources/zh-Hans.lproj/{table}.strings"
    # Xcode 的 .strings 可能含 UTF-16 BOM；交给 macOS 原生解析器处理。
    strings = json.loads(subprocess.check_output(["plutil", "-convert", "json", "-o", "-", str(path)]))
    assert strings, f"缺少简体中文 {table} 资源"
    if table == "Localizable":
        assert strings.get("Type") == "文字" and strings.get("Dither") == "仿色", "中文资源不完整"
    else:
        assert strings.get("CFBundleDisplayName") == "Compositor 中文版", "中文应用名称不正确"
print("Release 签名、沙盒权限、独立身份与中文资源检查：通过")

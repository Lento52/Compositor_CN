#!/bin/zsh
# 用户批准发布后手动执行；只创建中文 fork 的草稿 Release，不改 feed、不提交、不推送。
# 参数：DMG路径 版本标签 发布说明文件
set -euo pipefail
REPO=Lento52/Compositor_CN
[[ $# == 3 ]] || { echo "用法：$0 DMG路径 cn-v版本 发布说明文件"; exit 1; }
DMG="$1"
TAG="$2"
NOTES="$3"
[[ -f "$DMG" && -f "$NOTES" ]] || { echo "安装包或发布说明文件不存在"; exit 1; }
[[ "$TAG" == cn-v* ]] || { echo "中文版本标签应使用 cn-v 前缀"; exit 1; }
gh release create "$TAG" "$DMG" --repo "$REPO" --draft \
  --title "Compositor CN $TAG" --notes-file "$NOTES" --verify-tag
echo "已创建草稿：https://github.com/$REPO/releases/tag/$TAG"

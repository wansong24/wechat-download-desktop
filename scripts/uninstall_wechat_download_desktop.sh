#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "此脚本仅支持 macOS。"
  exit 1
fi

DESKTOP_FOLDER="${HOME}/Desktop/微信下载"

find_wechat_link() {
  local base="${HOME}/Library/Containers/com.tencent.xinWeChat/Data/Documents/xwechat_files"
  find "${base}" -maxdepth 3 -type l -path '*/msg/file' 2>/dev/null | head -n 1 || true
}

TARGET="$(find_wechat_link)"

if [[ -z "${TARGET}" ]]; then
  echo "没有找到指向桌面“微信下载”的微信原路径链接，可能已经恢复过。"
  exit 0
fi

if [[ ! -d "${DESKTOP_FOLDER}" ]]; then
  echo "找不到桌面文件夹：${DESKTOP_FOLDER}"
  exit 1
fi

rm -f "${TARGET}"
mv "${DESKTOP_FOLDER}" "${TARGET}"
killall Finder >/dev/null 2>&1 || true

echo "已恢复：微信下载文件夹已移回默认位置。"
echo "恢复路径：${TARGET}"

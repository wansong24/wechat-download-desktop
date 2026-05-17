#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "此脚本仅支持 macOS。"
  exit 1
fi

DESKTOP="${HOME}/Desktop"
DESKTOP_FOLDER="${DESKTOP}/微信下载"

find_wechat_download_dir() {
  local base="${HOME}/Library/Containers/com.tencent.xinWeChat/Data/Documents/xwechat_files"
  if [[ ! -d "${base}" ]]; then
    echo "找不到微信数据目录：${base}" >&2
    return 1
  fi

  local candidate
  candidate="$(find "${base}" -maxdepth 3 -type d -path '*/msg/file' 2>/dev/null | head -n 1 || true)"
  if [[ -z "${candidate}" ]]; then
    echo "找不到微信下载目录。请确认已经安装并登录 Mac 版微信。" >&2
    return 1
  fi

  printf '%s\n' "${candidate}"
}

TARGET="$(find_wechat_download_dir)"

if [[ -e "${DESKTOP}/微信下载.app" ]]; then
  rm -rf "${DESKTOP}/微信下载.app"
fi

if [[ -L "${DESKTOP_FOLDER}" || -f "${DESKTOP_FOLDER}" ]]; then
  rm -f "${DESKTOP_FOLDER}"
fi

if [[ -d "${DESKTOP_FOLDER}" && ! -L "${DESKTOP_FOLDER}" ]]; then
  if [[ "${TARGET}" != "${DESKTOP_FOLDER}" && ! -L "${TARGET}" ]]; then
    echo "桌面已存在普通文件夹：${DESKTOP_FOLDER}"
    echo "为避免覆盖你的文件，请先手动改名或移走它。"
    exit 1
  fi
fi

if [[ -d "${TARGET}" && ! -L "${TARGET}" && "${TARGET}" != "${DESKTOP_FOLDER}" ]]; then
  mv "${TARGET}" "${DESKTOP_FOLDER}"
fi

if [[ ! -d "${DESKTOP_FOLDER}" ]]; then
  mkdir -p "${DESKTOP_FOLDER}"
fi

if [[ "${TARGET}" != "${DESKTOP_FOLDER}" ]]; then
  rm -rf "${TARGET}"
  ln -s "${DESKTOP_FOLDER}" "${TARGET}"
fi

swift - <<'SWIFT'
import AppKit

let folderPath = NSString(string: "~/Desktop/微信下载").expandingTildeInPath
let side: CGFloat = 1024
let image = NSImage(size: NSSize(width: side, height: side))
image.lockFocus()
NSColor.clear.setFill()
NSRect(x: 0, y: 0, width: side, height: side).fill()

let shadow = NSShadow()
shadow.shadowOffset = NSSize(width: 0, height: -18)
shadow.shadowBlurRadius = 34
shadow.shadowColor = NSColor(calibratedWhite: 0, alpha: 0.28)
shadow.set()

let tab = NSBezierPath(roundedRect: NSRect(x: 150, y: 610, width: 360, height: 135), xRadius: 42, yRadius: 42)
NSColor(calibratedRed: 0.16, green: 0.70, blue: 0.33, alpha: 1).setFill()
tab.fill()

let body = NSBezierPath(roundedRect: NSRect(x: 105, y: 210, width: 815, height: 530), xRadius: 68, yRadius: 68)
NSColor(calibratedRed: 0.08, green: 0.58, blue: 0.25, alpha: 1).setFill()
body.fill()

NSShadow().set()
let top = NSBezierPath(roundedRect: NSRect(x: 145, y: 470, width: 735, height: 215), xRadius: 55, yRadius: 55)
NSColor(calibratedRed: 0.30, green: 0.86, blue: 0.49, alpha: 0.94).setFill()
top.fill()

let gloss = NSBezierPath(roundedRect: NSRect(x: 165, y: 525, width: 695, height: 95), xRadius: 38, yRadius: 38)
NSColor(calibratedWhite: 1, alpha: 0.18).setFill()
gloss.fill()

image.unlockFocus()
if !NSWorkspace.shared.setIcon(image, forFile: folderPath, options: []) {
  fputs("绿色图标设置失败，但文件夹链接已经完成。\n", stderr)
}
SWIFT

osascript -e 'tell application "Finder" to set label index of alias POSIX file "'"${DESKTOP_FOLDER}"'" to 6' >/dev/null 2>&1 || true
qlmanage -r cache >/dev/null 2>&1 || true
killall Finder >/dev/null 2>&1 || true

echo "完成：桌面“微信下载”现在是绿色文件夹，打开后直达微信下载内容。"
echo "微信原路径：${TARGET}"
echo "桌面路径：${DESKTOP_FOLDER}"

#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "此脚本仅支持 macOS。"
  exit 1
fi

DESKTOP="${HOME}/Desktop"
DESKTOP_FOLDER="${DESKTOP}/微信下载"

find_wechat_download_dir() {
  if [[ -n "${WECHAT_DOWNLOAD_DIR:-}" ]]; then
    if [[ -d "${WECHAT_DOWNLOAD_DIR}" || -L "${WECHAT_DOWNLOAD_DIR}" ]]; then
      printf '%s\n' "${WECHAT_DOWNLOAD_DIR}"
      return 0
    fi
    echo "WECHAT_DOWNLOAD_DIR 指定的目录不存在：${WECHAT_DOWNLOAD_DIR}" >&2
    return 1
  fi

  local base="${HOME}/Library/Containers/com.tencent.xinWeChat/Data/Documents/xwechat_files"
  if [[ ! -d "${base}" ]]; then
    echo "找不到微信数据目录：${base}" >&2
    return 1
  fi

  local candidate
  candidate="$(
    find "${base}" -maxdepth 4 \( -type d -o -type l \) -path '*/msg/file' -print0 2>/dev/null |
      xargs -0 stat -f '%m %N' 2>/dev/null |
      sort -rn |
      sed -n '1s/^[0-9][0-9]* //p'
  )"
  if [[ -z "${candidate}" ]]; then
    echo "找不到微信下载目录。请确认已经安装并登录 Mac 版微信。" >&2
    return 1
  fi

  printf '%s\n' "${candidate}"
}

TARGET="$(find_wechat_download_dir)"

if [[ ! -d "${DESKTOP}" ]]; then
  echo "找不到桌面目录：${DESKTOP}" >&2
  exit 1
fi

if [[ -e "${DESKTOP}/微信下载.app" ]]; then
  rm -rf "${DESKTOP}/微信下载.app"
fi

if [[ -L "${DESKTOP_FOLDER}" || -f "${DESKTOP_FOLDER}" ]]; then
  rm -f "${DESKTOP_FOLDER}"
fi

if [[ -d "${DESKTOP_FOLDER}" && ! -L "${DESKTOP_FOLDER}" ]]; then
  if [[ -L "${TARGET}" ]]; then
    link_dest="$(readlink "${TARGET}")"
    if [[ "${link_dest}" = /* ]]; then
      linked_real="$(cd "${link_dest}" 2>/dev/null && pwd -P || true)"
    else
      linked_real="$(cd "$(dirname "${TARGET}")/${link_dest}" 2>/dev/null && pwd -P || true)"
    fi
    desktop_real="$(cd "${DESKTOP_FOLDER}" && pwd -P)"
    if [[ "${linked_real}" != "${desktop_real}" ]]; then
      echo "微信下载路径已经是链接，但没有指向桌面“微信下载”：${TARGET}" >&2
      exit 1
    fi
  elif [[ "${TARGET}" != "${DESKTOP_FOLDER}" ]]; then
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

if [[ "${TARGET}" != "${DESKTOP_FOLDER}" && ! -L "${TARGET}" ]]; then
  rm -rf "${TARGET}"
  ln -s "${DESKTOP_FOLDER}" "${TARGET}"
elif [[ -L "${TARGET}" ]]; then
  rm -f "${TARGET}"
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

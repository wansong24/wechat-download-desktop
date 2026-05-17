#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "此脚本仅支持 macOS。"
  exit 1
fi

DESKTOP_FOLDER="${HOME}/Desktop/微信下载"

find_wechat_link() {
  local base="${HOME}/Library/Containers/com.tencent.xinWeChat/Data/Documents/xwechat_files"
  if [[ -n "${WECHAT_DOWNLOAD_DIR:-}" ]]; then
    printf '%s\n' "${WECHAT_DOWNLOAD_DIR}"
    return 0
  fi
  find "${base}" -maxdepth 4 -type l -path '*/msg/file' 2>/dev/null |
    while IFS= read -r link_path; do
      if link_points_to_desktop "${link_path}"; then
        printf '%s\n' "${link_path}"
        break
      fi
    done
}

link_points_to_desktop() {
  local link_path="$1"
  local link_dest linked_real desktop_real
  link_dest="$(readlink "${link_path}")"
  if [[ "${link_dest}" = /* ]]; then
    linked_real="$(cd "${link_dest}" 2>/dev/null && pwd -P || true)"
  else
    linked_real="$(cd "$(dirname "${link_path}")/${link_dest}" 2>/dev/null && pwd -P || true)"
  fi
  desktop_real="$(cd "${DESKTOP_FOLDER}" 2>/dev/null && pwd -P || true)"
  [[ -n "${linked_real}" && "${linked_real}" == "${desktop_real}" ]]
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

if [[ ! -L "${TARGET}" ]]; then
  echo "微信原路径不是链接，已停止恢复以避免误操作：${TARGET}" >&2
  exit 1
fi

if ! link_points_to_desktop "${TARGET}"; then
  echo "微信原路径链接没有指向桌面“微信下载”，已停止恢复：${TARGET}" >&2
  exit 1
fi

rm -f "${TARGET}"
mv "${DESKTOP_FOLDER}" "${TARGET}"
killall Finder >/dev/null 2>&1 || true

echo "已恢复：微信下载文件夹已移回默认位置。"
echo "恢复路径：${TARGET}"

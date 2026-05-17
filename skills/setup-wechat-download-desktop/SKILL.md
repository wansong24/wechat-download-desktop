---
name: setup-wechat-download-desktop
description: 在 macOS 桌面创建绿色“微信下载”文件夹，并让它直接显示微信下载目录内容。
---

# 微信下载桌面绿色文件夹

当用户想要“桌面有一个绿色微信下载文件夹”“点开直接进微信下载目录”“不要中间再套一层快捷方式”时，使用这个技能。

## 工作方式

运行插件内的安装脚本：

```bash
bash scripts/install_wechat_download_desktop.sh
```

脚本会：

1. 定位 Mac 版微信下载目录，优先使用 `~/Library/Containers/com.tencent.xinWeChat/Data/Documents/xwechat_files/*/msg/file`。
2. 把真实下载目录移动到桌面 `微信下载`。
3. 在微信原路径创建指向桌面文件夹的符号链接。
4. 给桌面文件夹设置绿色文件夹图标和绿色 Finder 标签。

## 恢复

需要恢复默认结构时运行：

```bash
bash scripts/uninstall_wechat_download_desktop.sh
```

## 注意

- 仅支持 macOS。
- 建议先退出微信再运行。
- 不要创建 App 入口；用户要的是一个真实绿色文件夹，且打开后直接看到微信下载内容。

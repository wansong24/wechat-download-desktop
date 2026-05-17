# 微信下载桌面绿色文件夹插件

这是一个给 macOS 使用的小插件，用来把微信下载文件夹整理成桌面上的绿色文件夹入口。

## 它会做什么

- 自动定位当前 Mac 用户的微信下载文件夹，不写死用户名或微信账号目录。
- 在桌面创建或更新 `微信下载` 文件夹。
- 让桌面 `微信下载` 成为真实下载目录，点开后直接看到 `2026-05` 这类月份文件夹。
- 在微信原来的下载路径放回一个系统链接，保证微信仍然能按原路径保存和读取文件。
- 给桌面 `微信下载` 设置绿色文件夹图标和绿色 Finder 标签。

## 使用方法

在插件目录运行：

```bash
bash scripts/install_wechat_download_desktop.sh
```

运行成功后，桌面会出现绿色 `微信下载` 文件夹。以后微信下载的文件会继续出现在这里。

## 注意事项

- 仅支持 macOS。
- 安装时会扫描当前用户的 `~/Library/Containers/com.tencent.xinWeChat/Data/Documents/xwechat_files`，如果有多个微信账号目录，会优先选择最近使用的 `msg/file`。
- 如果自动识别不符合你的实际情况，可以手动指定路径：

```bash
WECHAT_DOWNLOAD_DIR="/你的/微信/msg/file/路径" bash scripts/install_wechat_download_desktop.sh
```

- 脚本会修改本机微信下载目录的位置：真实文件夹会移动到桌面，原路径会变成指向桌面文件夹的链接。
- 如果桌面已经有名为 `微信下载` 的普通文件或文件夹，脚本会尽量保护已有内容；遇到冲突会停止并提示。
- 建议在微信退出时运行，避免微信正在写入文件。

## 恢复方法

如果要恢复到微信默认位置，可以运行：

```bash
bash scripts/uninstall_wechat_download_desktop.sh
```

它会把桌面 `微信下载` 文件夹移回微信原来的目录。

如果安装时使用过 `WECHAT_DOWNLOAD_DIR`，恢复时也使用同一个变量：

```bash
WECHAT_DOWNLOAD_DIR="/你的/微信/msg/file/路径" bash scripts/uninstall_wechat_download_desktop.sh
```

## 隐私说明

插件只在本机移动和链接文件夹，不上传、读取或分析你的微信文件内容。

## License

MIT

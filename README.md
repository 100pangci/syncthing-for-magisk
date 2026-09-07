# Syncthing for Magisk

## 简介

这是一个 Magisk 模块，它允许 Syncthing 在你的安卓设备上作为一个系统服务在后台持续运行。开机后，Syncthing 将自动启动，无需手动打开任何应用。

本模块的核心功能全部由 AI 编写，介意勿用，本人已测试基础功能均正常使用。

## 特性

- **开机自启**: 设备启动后，Syncthing 服务会自动在后台运行。
- **崩溃自动拉起**: 内置监督循环，进程意外退出后会自动重启（通过 Action 按钮停止的除外）。
- **独立身份**: 首次启动时自动为你的设备生成唯一的设备 ID、证书和 API key，模块内不预置任何配置。
- **Action 开关**: 在 Magisk Manager 中点按 Action 按钮即可启动/停止 Syncthing。
- **日志记录**: 运行日志被保存在数据目录中（超过 1 MB 自动截断），方便排查问题。

## 如何安装

1.  下载最新的 `zip` 格式模块文件。
2.  打开 Magisk Manager。
3.  进入 `模块` -> `从本地安装`。
4.  选择你下载的 `zip` 文件。
5.  安装完成后，重启你的设备。

从旧版本升级时，安装脚本会自动把配置从旧的模块目录迁移到新的数据目录，并清理旧版本配置中的遗留问题。

## 如何配置和使用

### 访问 Syncthing Web UI

Syncthing 启动后，你可以在手机上的浏览器中打开 `http://127.0.0.1:8384` 来访问其 Web 管理界面。

**首次使用后请立即在 WebUI 中设置 GUI 用户名和密码**（操作 -> 设置 -> GUI），否则设备上拥有网络权限的任何应用都可能通过 localhost 访问管理界面。

同步的文件夹需要在 WebUI 中手动添加（例如 `/storage/emulated/0/Sync`）。

### 重要文件路径

- **数据目录**: Syncthing 的所有配置（包括密钥和文件夹设置）都保存在这里。该目录位于模块目录之外，因此**模块更新不会丢失配置**。
  `/data/adb/syncthing-for-magisk/config`

- **日志文件**: 如果 Syncthing 无法启动或运行异常，请检查这个文件。
  `/data/adb/syncthing-for-magisk/config/syncthing.log`

- **Syncthing 主程序**:
  `/data/adb/modules/syncthing-for-magisk/bin/syncthing`

- **停止标记**: 通过 Action 按钮停止后，服务监督循环会因为这个标记文件而暂停；重启设备后自动清除。
  `/data/adb/syncthing-for-magisk/syncthing.stop`

### DNS 说明

许多 Android 设备上不存在 `/etc/resolv.conf`，这会导致静态编译的 Go 程序（包括 Syncthing）无法解析域名。本模块通过 Magisk 无损挂载了一份 `resolv.conf`（8.8.8.8 / 1.1.1.1）到 `/system/etc` 来解决这个问题。

## 致谢

- **作者**: ywpc05
- **模块代码部分**: Gemini & Claude (AI)

---

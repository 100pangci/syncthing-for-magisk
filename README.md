# Syncthing for Magisk

---
## 简介

这是一个 Magisk 模块，它允许 Syncthing 在你的安卓设备上作为一个系统服务在后台持续运行。开机后，Syncthing 将自动启动，无需手动打开任何应用。

本模块的核心功能全部由 AI 编写，介意勿用，本人已测试基础功能均正常使用。

## 特性

- **开机自启**: 设备启动后，Syncthing 服务会自动在后台运行。
- **持久运行**: 作为系统服务运行，不容易被系统杀死。
- **两种运行模式**:
    - **用户模式 (User Mode)**: 更安全，只能访问内部存储 (`/sdcard`)。
    - **Root 模式 (Root Mode)**: 权限更高，可以访问包括系统分区在内的整个文件系统。
- **自动化安装**: 安装脚本会自动选择最安全的“用户模式”，除非你手动指定。
- **日志记录**: 运行日志被保存在模块目录中，方便排查问题。

## 如何安装

1.  下载最新的 `zip` 格式模块文件。
2.  打开 Magisk Manager。
3.  进入 `模块` -> `从本地安装`。
4.  选择你下载的 `zip` 文件。
5.  安装过程会自动进行。默认情况下，它将以 **用户模式 (User Mode)** 安装。
6.  安装完成后，重启你的设备。

## 如何配置和使用

### 访问 Syncthing Web UI

Syncthing 启动后，你可以在手机上的浏览器中打开 `http://127.0.0.1:8384` 来访问其 Web 管理界面。


### 如何选择运行模式

模块默认安装为 **用户模式**，这是最安全的选择。如果你需要同步系统文件（例如 `/data/data/` 目录下的应用数据），则需要 **Root 模式**。

**你必须在安装模块之前选择模式**。方法如下：

- **方法一**: 在你的手机内部存储 (`/sdcard`) 的根目录下创建一个名为 `syncthing_mode.txt` 的文件。
    - 如果想使用 **Root 模式**，文件内容写 `root`。
    - 如果想使用 **用户模式**，文件内容写 `user`。
- **方法二**：你可以在安装后直接访问（`/data/adb/modules/syncthing-for-magisk/config`）目录，修改`mode.conf`文件，默认为`user`，你可以将它修改为`root`。

如果你不进行任何操作，模块将永远以 **用户模式** 安装。如果你想从用户模式切换到 Root 模式，你需要先创建上述文件，然后**在 Magisk 中重新安装**这个模块。


### 重要文件路径

- **配置文件目录**: Syncthing 的所有配置（包括密钥和仓库设置）都保存在这里。
  `/data/adb/modules/syncthing-for-magisk/config`

- **日志文件**: 如果 Syncthing 无法启动或运行异常，请检查这个文件。
  `/data/adb/modules/syncthing-for-magisk/config/syncthing.log`

- **Syncthing 主程序**:
  `/data/adb/modules/syncthing-for-magisk/system/bin/syncthing`

## 致谢

- **作者**: ywpc05
- **模块代码部分**: Gemini & Claude (AI)

---

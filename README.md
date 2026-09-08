# Syncthing for Magisk

## 简介

这是一个 Magisk 模块，它允许 Syncthing 在你的安卓设备上作为一个系统服务在后台持续运行。开机后，Syncthing 将自动启动，无需手动打开任何应用。

## 特性

- **开机自启**: 设备启动后，Syncthing 服务会自动在后台运行。
- **崩溃自动拉起**: 内置监督循环，进程意外退出后会自动重启（通过 Action 按钮停止的除外）。
- **自动跟随最新内核**: 构建时由 GitHub Actions 自动下载最新**正式版**（release，不含 rc 预发布）Syncthing 打进 zip，仓库中不保存二进制；模块版本号自动与所打包的内核版本一致。
- **多架构支持**: 一个 zip 内含 arm64-v8a、armeabi-v7a、x86_64、x86 四种二进制，安装时按设备实际 ABI 自动选用，不支持的架构会中止安装。
- **独立身份**: 首次启动时自动为你的设备生成唯一的设备 ID、证书和 API key，模块内不预置任何配置。
- **Action 开关**: 在 Magisk Manager 中点按 Action 按钮即可停止/启动 Syncthing。停止立即生效；启动只是清除停止标记，由开机常驻的监督进程在数秒内拉起（监督进程是唯一的启动者，可避免双实例冲突）。
- **日志记录**: 运行日志被保存在数据目录中（超过 1 MB 自动截断），方便排查问题。

## 下载

- **测试版（pre-release）**: 每次推送/合并到 `main` 分支，GitHub Actions 会自动构建并发布为 pre-release，可在 [Releases](../../releases) 页面获取，标签格式为 `vx.y.z.0-pre.构建号`。
- **正式版**: 推送 `v*` 格式的标签会自动创建正式 Release，并附带模块 zip 与 sha256 校验文件。
- **手动构建**: 在 [Actions](../../actions) 页面手动触发，可指定 Syncthing 版本（如 `v2.1.3`）；留空则使用最新正式版。在 `main` 上触发同样会发布 pre-release。

模块版本号固定为四段：前三段跟随所打包的 Syncthing 内核版本，第四位是模块自身的修订号（例如内核 v2.1.3 → 模块 v2.1.3.0）。zip 内的模块版本号会自动同步为实际打包的内核版本。从旧版本（Syncthing v1.x）升级时，Syncthing v2 会自动迁移配置和数据库，首次启动可能需要重新扫描一遍同步文件夹。

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
  `/data/local/syncthing-for-magisk/config`

- **日志文件**: 如果 Syncthing 无法启动或运行异常，请检查这个文件。
  `/data/local/syncthing-for-magisk/config/syncthing.log`

- **Syncthing 主程序**:
  `/data/adb/modules/syncthing-for-magisk/bin/syncthing`

- **停止标记**: 通过 Action 按钮停止后，服务监督循环会因为这个标记文件而暂停；重启设备后自动清除。
  `/data/local/syncthing-for-magisk/syncthing.stop`

### 权限说明

Syncthing 以 Android 的 `shell` 用户（uid 2000）运行，因此只能访问内部存储（/sdcard）和 SD 卡，无法读写其他应用的私有数据。Android 8.0 及以上通过 `setpriv` 降权运行；更旧的系统缺少 `setpriv`，会回退为以 root 运行。

### DNS 说明

许多 Android 设备上不存在 `/etc/resolv.conf`，这会导致静态编译的 Go 程序（包括 Syncthing）无法解析域名。Syncthing 是纯 Go 静态二进制，解析器**硬编码读取 `/etc/resolv.conf`，没有提供自定义 DNS 服务器的启动参数**（已核对官方源码，serve 的启动选项里没有任何 DNS 相关开关）。因此模块只能通过 Magisk 无损挂载一份 `resolv.conf`（8.8.8.8 / 1.1.1.1）到 `/system/etc` 来解决。

请注意：这份文件主要影响读取它的静态 Go 程序，Android 系统自身的解析流程走 netd/bionic，不受影响；但 Syncthing 的域名解析不会跟随系统配置的私有 DNS/VPN，若所在网络封锁了这两个公共 DNS，可能需要自行修改模块内的 `resolv.conf`。

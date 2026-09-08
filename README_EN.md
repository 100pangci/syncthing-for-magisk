# Syncthing for Magisk

## Introduction

This is a Magisk module that allows Syncthing to run continuously as a service in the background on your Android device. After booting, Syncthing will start automatically, with no need to manually open any app.

## Features

- **Autostart on Boot**: The Syncthing service starts automatically after your device boots up.
- **Crash Recovery**: A supervisor loop restarts Syncthing automatically if it exits unexpectedly (unless you stopped it via the Action button).
- **Tracks the Latest Kernel**: GitHub Actions downloads the latest stable (full release, never a release candidate) Syncthing at build time and packages it into the zip; the binary is not stored in the repository, and the module version automatically matches the packaged kernel.
- **Multi-architecture**: One zip carries binaries for arm64-v8a, armeabi-v7a, x86_64 and x86; the installer picks the binary matching the device ABI and aborts on unsupported architectures.
- **Unique Identity**: On first start, a unique device ID, certificates and API key are generated for your installation. No configuration is shipped inside the module.
- **Action Button**: Stop/start Syncthing by tapping the Action button in the Magisk Manager. Stopping takes effect immediately; starting only clears the stop flag and the boot supervisor picks the process up within a few seconds (the supervisor is the only process that ever launches Syncthing, so two instances can never race each other).
- **Logging**: Runtime logs are saved in the data directory (truncated automatically beyond 1 MB) for easy troubleshooting.

## Downloads

- **Test builds (pre-releases)**: Every push/merge to the `main` branch is automatically built and published as a pre-release on the [Releases](../../releases) page, tagged `vx.y.z.0-pre.<build number>`.
- **Stable releases**: Pushing a `v*` tag creates a stable Release with the module zip and its sha256 checksum.
- **Manual builds**: Trigger manually from the [Actions](../../actions) page, optionally pinning a Syncthing version (e.g. `v2.1.3`); leave empty for the latest stable release. Manual runs on `main` are also published as pre-releases.

The module version always has four components: the first three follow the packaged Syncthing kernel, the fourth is the module's own build number (e.g. kernel v2.1.3 -> module v2.1.3.0). The version inside the zip is automatically synced to the packaged kernel. When upgrading from older builds (Syncthing v1.x), Syncthing v2 migrates the configuration and database automatically; the first start may rescan sync folders once.

## Installation

1.  Download the latest module `zip` file.
2.  Open the Magisk app.
3.  Go to `Modules` -> `Install from storage`.
4.  Select the `zip` file you downloaded.
5.  Reboot your device once the installation is complete.

When upgrading from an older version, the installer automatically migrates your configuration from the old module directory to the new data directory and cleans up leftovers from previous releases.

## Configuration and Usage

### Accessing the Syncthing Web UI

Once Syncthing is running, you can access its web management interface by opening `http://127.0.0.1:8384` in a browser on your phone.

**Right after first start, set a GUI username and password** (Actions -> Settings -> GUI), otherwise any app on the device with network access may reach the admin interface via localhost.

Sync folders need to be added manually in the Web UI (e.g. `/storage/emulated/0/Sync`).

### Key File Paths

- **Data Directory**: All of Syncthing's configuration (including keys and folder settings) is stored here. This directory lives outside the module directory, so **module updates will not wipe your configuration**.
    `/data/local/syncthing-for-magisk/config`

- **Log File**: If Syncthing fails to start or behaves unexpectedly, check this file.
    `/data/local/syncthing-for-magisk/config/syncthing.log`

- **Syncthing Executable**:
    `/data/adb/modules/syncthing-for-magisk/bin/syncthing`

- **Stop Flag**: After stopping via the Action button, the supervisor loop pauses because of this file; it is cleared automatically on reboot.
    `/data/local/syncthing-for-magisk/syncthing.stop`

### Privileges

Syncthing runs as Android's `shell` user (uid 2000), so it only sees internal storage (/sdcard) and SD cards and cannot touch other apps' private data. On Android 8.0+ privileges are dropped with `setpriv`; older systems lack `setpriv` and fall back to running as root.

### DNS Note

Many Android devices lack `/etc/resolv.conf`, which prevents statically-linked Go binaries (including Syncthing) from resolving domain names. Syncthing is a pure-Go static binary whose resolver **hardcodes `/etc/resolv.conf` -- there is no startup option to point it at custom DNS servers** (verified against the official source: none of `serve`'s flags concern DNS). The module therefore has no choice but to ship a `resolv.conf` (8.8.8.8 / 1.1.1.1) that Magisk mounts systemlessly into `/system/etc`.

Note that this file mainly affects static Go binaries that read it; Android's own resolution path (netd/bionic) is unaffected. However, Syncthing's name resolution will not follow system-configured private DNS or VPNs -- if your network blocks both public resolvers, edit the `resolv.conf` shipped in the module.

# Syncthing for Magisk

## Introduction

This is a Magisk module that allows Syncthing to run continuously as a system service in the background on your Android device. After booting, Syncthing will start automatically, with no need to manually open any app.

The core functionality of this module was written by AI. Please use it at your own discretion. I have personally tested the basic features, 和 they are working correctly.

## Features

-   **Autostart on Boot**: The Syncthing service starts automatically after your device boots up.
-   **Persistent Service**: Runs as a system service, making it less likely to be killed by the system's memory management.
-   **Two Operating Modes**:
    -   **User Mode**: Safer, with access limited to internal storage (`/sdcard`).
    -   **Root Mode**: Higher privileges, with access to the entire filesystem, including system partitions.
-   **Automated Setup**: The installation script defaults to the safer "User Mode" unless you specify otherwise.
-   **Logging**: Runtime logs are saved within the module directory for easy troubleshooting.

## Installation

1.  Download the latest module `zip` 文件。
2.  Open the Magisk app.
3.  Go to `Modules` -> `Install from storage`.
4.  Select the `zip` file you downloaded.
5.  The installation will proceed automatically. By default, it will be installed in **User Mode**。
6.  Reboot your device once the installation is complete.

## Configuration and Usage

### Accessing the Syncthing Web UI

Once Syncthing is running, you can access its web management interface by opening `http://127.0.0.1:8384` in a browser on your phone.

### How to Choose the Operating Mode

The module installs in **User Mode** by default, which is the safest option. If you need to sync system files (e.g., app data from the `/data/data/` directory), you will need **Root Mode**。

**You must choose the mode *before* installing the module**. Here's how:

-   **Method 1 (Recommended)**: Create a file named `syncthing_mode.txt` in the root of your internal storage (`/sdcard`).
    -   To use **Root Mode**, write `root` inside the file.
    -   To use **User Mode**, write `user` inside the file.
-   **Method 2 (Post-Install Change)**: After installation, you can inspect the chosen mode by viewing the `/data/adb/modules/syncthing-for-magisk/config/mode.conf` 文件。

If you do not create the `syncthing_mode.txt` file, the module will always install in **User Mode**. If you want to switch from User Mode to Root Mode (or vice-versa), you must first create or edit the `syncthing_mode.txt` file as described above, 和 then **reinstall the module in Magisk**。

### Key File Paths

-   **Configuration Directory**: All of Syncthing's configurations, including keys and repository settings, are stored here.
    `/data/adb/modules/syncthing-for-magisk/config`

-   **Log File**: If Syncthing fails to start or behaves unexpectedly, check this file.
    `/data/adb/modules/syncthing-for-magisk/config/syncthing.log`

-   **Syncthing Executable**:
    `/data/adb/modules/syncthing-for-magisk/system/bin/syncthing`

## Credits

-   **Author**: ywpc05
-   **Module Core Logic**: Gemini & Claude (AI)

---

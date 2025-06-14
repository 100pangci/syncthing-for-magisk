# Syncthing for Magisk

## Introduction

This is a Magisk module that allows Syncthing to run continuously as a system service in the background on your Android device. After booting, Syncthing will start automatically, with no need to manually open any app.

The core functionality of this module was written by AI. Please use it at your own discretion. I have personally tested the basic features, 和 they are working correctly.

## Features

-   **Autostart on Boot**: The Syncthing service starts automatically after your device boots up.
-   **Persistent Service**: Runs as a system service, making it less likely to be killed by the system's memory management.
-   **Automated Setup**: The installation script defaults to the safer "User Mode" unless you specify otherwise.
-   **Logging**: Runtime logs are saved within the module directory for easy troubleshooting.

## Installation

1.  Download the latest module `zip` file。
2.  Open the Magisk app.
3.  Go to `Modules` -> `Install from storage`.
4.  Select the `zip` file you downloaded.
5.  The installation will proceed automatically. By default, it will be installed in **User Mode**。
6.  Reboot your device once the installation is complete.

## Configuration and Usage

### Accessing the Syncthing Web UI

Once Syncthing is running, you can access its web management interface by opening `http://127.0.0.1:8384` in a browser on your phone.

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

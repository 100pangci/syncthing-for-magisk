#!/system/bin/sh
# This script will be executed in recovery mode during module installation

ui_print " "
ui_print "Syncthing for Magisk Installer"
ui_print " "
ui_print "- This module will run Syncthing as the 'shell' user."
ui_print "- It can only access internal storage (/sdcard) and SD cards."
ui_print " "

MODID=syncthing-for-magisk
DATA_DIR=/data/adb/syncthing-for-magisk
CONFIG_DIR="$DATA_DIR/config"

# Syncthing's identity (keys, config, database) lives OUTSIDE the module
# directory, because Magisk wipes the module directory on every update.
mkdir -p "$CONFIG_DIR"

# Migrate config from the old location (inside the module directory)
OLD_CONFIG_DIR="/data/adb/modules/$MODID/config"
if [ -f "$OLD_CONFIG_DIR/config.xml" ] && [ ! -f "$CONFIG_DIR/config.xml" ]; then
  ui_print "- Migrating existing config from module directory..."
  cp -a "$OLD_CONFIG_DIR/." "$CONFIG_DIR/" 2>/dev/null
  ui_print "- Migration done."
fi

# Older versions shipped a config containing a fixed API key and a leftover
# remote device entry. Strip both; the device ID and pairings are preserved,
# and users of very old versions get a fresh random API key.
if [ -f "$CONFIG_DIR/config.xml" ] && grep -q "HDCR34R" "$CONFIG_DIR/config.xml"; then
  ui_print "- Removing leftover default device entry and fixed API key..."
  sed -i '\#<device id="HDCR34R.*</device>#d' "$CONFIG_DIR/config.xml"
  sed -i '\#^    <device id="HDCR34R#,\#^    </device>#d' "$CONFIG_DIR/config.xml"
  NEW_API_KEY=$(od -An -N16 -tx1 /dev/urandom | tr -d ' \n')
  sed -i "s#<apikey>default</apikey>#<apikey>$NEW_API_KEY</apikey>#" "$CONFIG_DIR/config.xml"
fi

set_perm_recursive "$CONFIG_DIR" 2000 2000 0770 0660
ui_print "- Config directory: $CONFIG_DIR"

# /data/adb is 0700 root, which would block uid 2000 from traversing it.
# 0711 allows traversal without listing. service.sh reapplies this each boot.
chmod 0711 /data/adb /data/adb/modules "$DATA_DIR" 2>/dev/null

# Set permissions for Syncthing binary (kept outside system/ so it does not
# get mounted into the real /system)
ui_print "- Setting permissions for Syncthing binary..."
if [ -f "$MODPATH/bin/syncthing" ]; then
  set_perm "$MODPATH/bin/syncthing" 0 0 0755
  chmod 0711 "$MODPATH" "$MODPATH/bin"
else
  abort "! Syncthing binary not found at $MODPATH/bin/syncthing"
fi

ui_print " "
ui_print "Installation complete!"
ui_print " "
ui_print "- On first start a unique configuration is generated automatically."
ui_print "- WebUI: http://127.0.0.1:8384 (set a GUI password after first start!)"
ui_print "- Syncthing will start automatically as user 'shell' after reboot."

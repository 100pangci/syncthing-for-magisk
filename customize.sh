#!/system/bin/sh
# This script will be executed in recovery mode during module installation

MODID=syncthing-for-magisk
DATA_DIR=/data/local/syncthing-for-magisk
CONFIG_DIR="$DATA_DIR/config"

ui_print " "
ui_print "Syncthing for Magisk Installer"
ui_print " "
ui_print "- This module will run Syncthing as the 'shell' user."
ui_print "- It can only access internal storage (/sdcard) and SD cards."
ui_print " "

# --- Architecture detection ---
# The zip ships one binary per Android ABI. Install the matching one and
# discard the rest, so service.sh always finds it at bin/syncthing.
ABI=$(getprop ro.product.cpu.abi)
ABILIST=$(getprop ro.product.cpu.abilist)
ARCH=
for a in "$ABI" ${ABILIST//,/ }; do
  case "$a" in
    arm64-v8a) ARCH=arm64-v8a; break ;;
    armeabi-v7a|armeabi) ARCH=armeabi-v7a; break ;;
    x86_64) ARCH=x86_64; break ;;
    x86) ARCH=x86; break ;;
  esac
done
if [ -z "$ARCH" ]; then
  abort "! Unsupported CPU architecture: $ABI"
fi
ui_print "- Detected architecture: $ARCH"

if [ ! -f "$MODPATH/bin/$ARCH/syncthing" ]; then
  abort "! Syncthing binary missing for architecture $ARCH"
fi
mkdir -p "$MODPATH/bin"
mv -f "$MODPATH/bin/$ARCH/syncthing" "$MODPATH/bin/syncthing" \
  || abort "! Cannot stage the Syncthing binary"
rm -rf "$MODPATH/bin/arm64-v8a" "$MODPATH/bin/armeabi-v7a" \
       "$MODPATH/bin/x86_64" "$MODPATH/bin/x86"
set_perm "$MODPATH/bin/syncthing" 0 0 0755
chmod 0711 "$MODPATH" "$MODPATH/bin"
ui_print "- Syncthing binary installed for $ARCH"

# Syncthing's identity (keys, config, database) lives OUTSIDE the module
# directory, because Magisk wipes the module directory on every update.
# /data/local is used so the unprivileged 'shell' user (uid 2000) can reach
# the data without loosening /data/adb, which is root-only by design.
chmod 0711 /data/local 2>/dev/null
mkdir -p "$CONFIG_DIR"

# Migrate config from older locations when present:
# (1) inside the module directory (very old versions)
# (2) the previous data directory under /data/adb
if [ ! -f "$CONFIG_DIR/config.xml" ]; then
  for OLD in \
    "/data/adb/modules/$MODID/config" \
    "/data/adb/syncthing-for-magisk/config"
  do
    if [ -f "$OLD/config.xml" ]; then
      ui_print "- Migrating existing config from $OLD..."
      cp -a "$OLD/." "$CONFIG_DIR/" 2>/dev/null
      ui_print "- Migration done."
      break
    fi
  done
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

ui_print " "
ui_print "Installation complete!"
ui_print " "
ui_print "- On first start a unique configuration is generated automatically."
ui_print "- WebUI: http://127.0.0.1:8384 (set a GUI password after first start!)"
ui_print "- Syncthing will start automatically as user 'shell' after reboot."

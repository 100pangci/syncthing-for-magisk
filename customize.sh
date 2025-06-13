#!/system/bin/sh
# Do not touch this line
# This script will be executed in recovery mode during module installation

# Load utility functions for UI
. $MODPATH/util_functions.sh

ui_print " "
ui_print "Syncthing for Magisk Installer"
ui_print " "

# --- Simplified mode selection ---
ui_print "Mode Selection:"
ui_print " "
ui_print "  [User Mode] (DEFAULT)"
ui_print "  - Runs as standard 'shell' user."
ui_print "  - Can only access internal storage (/sdcard) and SD cards."
ui_print "  - More secure, recommended for most users."
ui_print " "
ui_print "  [Root Mode]"
ui_print "  - Runs as root."
ui_print "  - Can access the ENTIRE filesystem."
ui_print "  - Less secure, use only if you need to sync system files."
ui_print " "

# Check for mode override file or environment variable
MODE_OVERRIDE=""
if [ -f "/sdcard/syncthing_mode.txt" ]; then
  MODE_OVERRIDE=$(cat "/sdcard/syncthing_mode.txt" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
  ui_print "Found mode override file: /sdcard/syncthing_mode.txt"
elif [ -n "$SYNCTHING_MODE" ]; then
  MODE_OVERRIDE=$(echo "$SYNCTHING_MODE" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
  ui_print "Found environment variable: SYNCTHING_MODE=$SYNCTHING_MODE"
fi

# Determine the selected mode
selected_index=0  # Default to User Mode

case "$MODE_OVERRIDE" in
  "root"|"1")
    selected_index=1
    ui_print "- Override: Root Mode selected."
    ;;
  "user"|"0"|"")
    selected_index=0
    if [ -n "$MODE_OVERRIDE" ]; then
      ui_print "- Override: User Mode selected."
    else
      ui_print "- Default: User Mode selected (safest option)."
    fi
    ;;
  *)
    ui_print "- Invalid override value '$MODE_OVERRIDE', using User Mode."
    selected_index=0
    ;;
esac

# Create config directory and set permissions
CONFIG_DIR="$MODPATH/config"
mkdir -p "$CONFIG_DIR"

if [ $selected_index -eq 0 ]; then
  ui_print "- Configuring User Mode..."
  echo "user" > "$MODPATH/mode.conf"
  set_perm_recursive "$CONFIG_DIR" 2000 2000 0755
  ui_print "- Config directory permissions set for user 'shell' (UID 2000)."
else
  ui_print "- Configuring Root Mode..."
  echo "root" > "$MODPATH/mode.conf"
  set_perm_recursive "$CONFIG_DIR" 0 0 0755
  ui_print "- Config directory permissions set for 'root' (UID 0)."
fi

# Set permissions for Syncthing binary
ui_print "- Setting permissions for Syncthing binary..."
if [ -f "$MODPATH/system/bin/syncthing" ]; then
  set_perm "$MODPATH/system/bin/syncthing" 0 0 0755
  ui_print "- Binary permissions set successfully."
else
  ui_print "! Warning: Syncthing binary not found at $MODPATH/system/bin/syncthing"
fi

# Create installation log
echo "Installation completed at $(date)" > "$MODPATH/install.log"
echo "Selected mode: $(cat "$MODPATH/mode.conf")" >> "$MODPATH/install.log"
echo "Config directory: $CONFIG_DIR" >> "$MODPATH/install.log"

ui_print " "
ui_print "Installation complete!"
ui_print " "
ui_print "Selected mode: $(cat "$MODPATH/mode.conf")"
ui_print " "
ui_print "To change mode in future installations:"
ui_print "- Create /sdcard/syncthing_mode.txt with 'user' or 'root'"
ui_print "- Or set SYNCTHING_MODE environment variable"
ui_print " "
ui_print "Syncthing will start automatically after reboot."
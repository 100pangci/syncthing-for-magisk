#!/system/bin/sh
# Do not touch this line
# This script will be executed in recovery mode during module installation

# Load utility functions for UI - NO LONGER NEEDED
# . $MODPATH/util_functions.sh

ui_print " "
ui_print "Syncthing for Magisk Installer"
ui_print " "
ui_print "- This module will run Syncthing as the 'shell' user."
ui_print "- It can only access internal storage (/sdcard) and SD cards."
ui_print "- This is the standard and most secure configuration."
ui_print " "

# Create config directory and set permissions for User Mode
ui_print "- Configuring for User (shell) Mode..."
CONFIG_DIR="$MODPATH/config"
mkdir -p "$CONFIG_DIR"
set_perm_recursive "$CONFIG_DIR" 2000 2000 0755 0644
ui_print "- Config directory permissions set for user 'shell' (UID 2000)."

# Copy default config if it doesn't exist
ui_print "- Checking for existing configuration..."
# The default config.xml should be placed in the module zip, not in system/etc
# For example, place it in $MODPATH/config.xml.template
if [ -f "$MODPATH/system/etc/config.xml" ]; then
  if [ ! -f "$CONFIG_DIR/config.xml" ]; then
    cp "$MODPATH/system/etc/config.xml" "$CONFIG_DIR/config.xml"
    ui_print "- No existing config found. Deployed default config."
    # Ensure the new config file has the correct permissions
    chown 2000:2000 "$CONFIG_DIR/config.xml"
    chmod 0644 "$CONFIG_DIR/config.xml"
  else
    ui_print "- Existing config.xml found. No changes made."
  fi
else
  ui_print "! Warning: Default config template not found in module."
fi

# Set permissions for Syncthing binary
ui_print "- Setting permissions for Syncthing binary..."
if [ -f "$MODPATH/system/bin/syncthing" ]; then
  set_perm "$MODPATH/system/bin/syncthing" 0 0 0755
  ui_print "- Binary permissions set successfully."
else
  ui_print "! Warning: Syncthing binary not found at $MODPATH/system/bin/syncthing"
  abort "! Aborting installation."
fi

# Create installation log
echo "Installation completed at $(date)" > "$MODPATH/install.log"
echo "Mode: User (shell) only" >> "$MODPATH/install.log"
echo "Config directory: $CONFIG_DIR" >> "$MODPATH/install.log"

ui_print " "
ui_print "Installation complete!"
ui_print " "
ui_print "Syncthing will start automatically as user 'shell' after reboot."

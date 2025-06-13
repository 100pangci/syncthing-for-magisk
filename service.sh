#!/system/bin/sh
# This script will be executed in late_start service mode

# It's good practice to wait for the module's directory to be accessible
# The MODDIR variable is automatically set by Magisk's service script runner
# So, MODDIR=${0%/*} is not strictly necessary but harmless.
# Let's use the one provided by Magisk for robustness.
MODDIR=${MODDIR:-/data/adb/modules/syncthing-for-magisk} # Replace with your module's ID

# Define paths
SYNCTHING_BIN="$MODDIR/system/bin/syncthing"
SYNCTHING_HOME="$MODDIR/config"
CONFIG_FILE="$MODDIR/mode.conf"
LOG_FILE="$SYNCTHING_HOME/syncthing.log"

# --- Start logging to the file from here ---
# This will redirect all stdout and stderr of the script to the log file.
# The 'exec' command replaces the current shell process, saving resources.
exec >> $LOG_FILE 2>&1

# --- Script execution starts here ---

# Wait until the boot process is complete
while [ "$(getprop sys.boot_completed)" != "1" ]; do
  sleep 1
done

# Give it a bit more time for network to be up
sleep 15

# Log the start time
echo "----------------------------------------------------"
echo "Starting Syncthing Service at $(date)"
echo "Module Directory: $MODDIR"

# Read the run mode from the config file, default to 'user' if not found
if [ -f "$CONFIG_FILE" ]; then
  RUN_MODE=$(cat "$CONFIG_FILE")
else
  RUN_MODE="user"
  echo "Warning: mode.conf not found. Defaulting to 'user' mode."
fi

echo "Run mode: '$RUN_MODE'"

# Prepare the command arguments
SYNCTHING_ARGS="-no-browser -home=$SYNCTHING_HOME -logfile=- -no-restart"
# Note: -logfile=- sends logs to stdout, which we've already redirected to our main log file.
# This is cleaner than syncthing managing its own log file.

# Execute Syncthing based on the chosen mode
if [ "$RUN_MODE" = "root" ]; then
  echo "Executing Syncthing as root..."
  # 'exec' will replace the shell process with the syncthing process
  exec $SYNCTHING_BIN $SYNCTHING_ARGS
else
  echo "Executing Syncthing as user 'shell'..."
  # 'exec' will replace the 'su' subshell process
  exec su -c "$SYNCTHING_BIN $SYNCTHING_ARGS" shell
fi

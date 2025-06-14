#!/system/bin/sh
# This script will be executed in late_start service mode

MODDIR=${MODDIR:-/data/adb/modules/syncthing-for-magisk} # Fallback for testing

# Define paths
SYNCTHING_BIN="$MODDIR/system/bin/syncthing"
SYNCTHING_HOME="$MODDIR/config"
LOG_FILE="$SYNCTHING_HOME/syncthing.log"

# Redirect all stdout and stderr of the script to the log file.
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
echo "Run mode: User (shell) - This is the only mode available."

# Prepare the command arguments
SYNCTHING_ARGS="-no-browser -home=$SYNCTHING_HOME -logfile=- -no-restart"
# Note: -logfile=- sends logs to stdout, which we've already redirected to our main log file.

# Execute Syncthing as user 'shell'
echo "Executing Syncthing as user 'shell'..."
# 'exec' will replace the 'su' subshell process
# Added STDNSRESOLVER environment variable to specify a reliable DNS server for the shell user
exec su -c "HOME=$SYNCTHING_HOME STDNSRESOLVER=8.8.8.8:53 $SYNCTHING_BIN $SYNCTHING_ARGS" shell

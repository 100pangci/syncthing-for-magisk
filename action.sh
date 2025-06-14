#!/system/bin/sh
# This script will be executed when you tap the button in Magisk Manager

# --- Basic Setup ---
MODDIR=${MODDIR:-/data/adb/modules/syncthing-for-magisk}

# Define paths
SYNCTHING_BIN="$MODDIR/system/bin/syncthing"
SYNCTHING_HOME="$MODDIR/config"
LOG_FILE="$SYNCTHING_HOME/syncthing.log"

# --- Core Toggle Logic ---

# Check if the syncthing process is running
if ps -A | grep -q '[s]yncthing'; then
  # --- STOP SYNCTHING ---
  echo "Syncthing is running. Stopping it..."
  killall syncthing
  sleep 1 # Give it a moment to terminate
  echo "Syncthing stopped."
else
  # --- START SYNCTHING ---
  echo "Syncthing is not running. Starting it..."
  echo "Starting in User (shell) mode."

  # Prepare command arguments
  # We explicitly set -logfile to the file for clean output in Magisk Manager.
  SYNCTHING_ARGS="-no-browser -home=$SYNCTHING_HOME -logfile=$LOG_FILE -no-restart"

  # Execute Syncthing as user 'shell' in the background
  echo "Executing Syncthing as user 'shell' in the background..."
  su -c "HOME=$SYNCTHING_HOME STDNSRESOLVER=8.8.8.8:53 $SYNCTHING_BIN $SYNCTHING_ARGS" shell &

  sleep 1 # Give it a moment to start
  echo "Syncthing start command issued."
fi

echo "Action complete."

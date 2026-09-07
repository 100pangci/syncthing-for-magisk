#!/system/bin/sh
# This script will be executed when you tap the Action button in Magisk Manager

MODDIR=${MODDIR:-/data/adb/modules/syncthing-for-magisk}
DATA_DIR=/data/adb/syncthing-for-magisk
SYNCTHING_BIN="$MODDIR/bin/syncthing"
SYNCTHING_HOME="$DATA_DIR/config"
LOG_FILE="$SYNCTHING_HOME/syncthing.log"
STOP_FLAG="$DATA_DIR/syncthing.stop"

# Make sure the 'shell' user can reach the binary and the config directory
chmod 0711 /data/adb /data/adb/modules 2>/dev/null
chmod 0711 "$MODDIR" "$MODDIR/bin" "$DATA_DIR" 2>/dev/null
chmod 0755 "$SYNCTHING_BIN" 2>/dev/null
mkdir -p "$SYNCTHING_HOME"
chown 2000:2000 "$SYNCTHING_HOME" 2>/dev/null
chmod 0770 "$SYNCTHING_HOME" 2>/dev/null

# Only match processes launched from OUR binary, so an instance of the
# Syncthing Android app is never killed by mistake
our_pids() {
  for pid in $(pidof syncthing 2>/dev/null); do
    [ "$(readlink "/proc/$pid/exe" 2>/dev/null)" = "$SYNCTHING_BIN" ] && echo "$pid"
  done
}

PIDS=$(our_pids)

if [ -n "$PIDS" ]; then
  # --- STOP SYNCTHING ---
  echo "Syncthing is running (pid:$PIDS). Stopping it..."
  # Set the flag first so the service.sh supervisor loop does not respawn
  touch "$STOP_FLAG"
  kill $PIDS 2>/dev/null
  i=0
  while [ -n "$(our_pids)" ] && [ "$i" -lt 10 ]; do
    sleep 1
    i=$((i + 1))
  done
  if [ -n "$(our_pids)" ]; then
    kill -9 $PIDS 2>/dev/null
    echo "Syncthing force killed."
  else
    echo "Syncthing stopped."
  fi
else
  # --- START SYNCTHING ---
  echo "Syncthing is not running. Starting it as user 'shell'..."
  rm -f "$STOP_FLAG"

  # First run: generate a fresh unique configuration
  if [ ! -f "$SYNCTHING_HOME/config.xml" ]; then
    echo "No config found. Generating a fresh configuration..."
    su -c "exec env HOME='$SYNCTHING_HOME' '$SYNCTHING_BIN' generate --home='$SYNCTHING_HOME' --no-default-folder" shell
  fi

  touch "$LOG_FILE"
  chown 2000:2000 "$LOG_FILE" 2>/dev/null
  chmod 0660 "$LOG_FILE" 2>/dev/null

  su -c "exec env HOME='$SYNCTHING_HOME' '$SYNCTHING_BIN' -no-browser -home='$SYNCTHING_HOME' -logfile='$LOG_FILE'" shell &

  sleep 2
  PIDS=$(our_pids)
  if [ -n "$PIDS" ]; then
    echo "Syncthing started (pid:$PIDS). WebUI: http://127.0.0.1:8384"
  else
    echo "Syncthing failed to start. Check $LOG_FILE"
  fi
fi

echo "Action complete."

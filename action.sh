#!/system/bin/sh
# This script will be executed when you tap the Action button in Magisk Manager

MODDIR=${MODDIR:-${0%/*}}
DATA_DIR=/data/local/syncthing-for-magisk
SYNCTHING_BIN="$MODDIR/bin/syncthing"
SYNCTHING_HOME="$DATA_DIR/config"
LOG_FILE="$SYNCTHING_HOME/syncthing.log"
STOP_FLAG="$DATA_DIR/syncthing.stop"

# Make sure the 'shell' user can reach the binary and the config directory
chmod 0711 /data/local 2>/dev/null
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
  # Re-read the PIDs: the process may have exited and its PID could be reused
  PIDS=$(our_pids)
  if [ -n "$PIDS" ]; then
    kill -9 $PIDS 2>/dev/null
    echo "Syncthing force killed."
  else
    echo "Syncthing stopped."
  fi
else
  # --- START SYNCTHING ---
  # Syncthing is only ever launched by the boot supervisor in service.sh;
  # starting it from here too could race with the supervisor and spawn two
  # instances fighting over the same config/database. Clearing the flag makes
  # the supervisor pick the process up within a few seconds.
  echo "Syncthing is not running. Requesting start..."
  rm -f "$STOP_FLAG"
  echo "Start requested. The service supervisor will launch Syncthing within"
  echo "a few seconds. Progress is logged to: $LOG_FILE"
fi

echo "Action complete."

#!/system/bin/sh
# This script will be executed in late_start service mode

MODDIR=${MODDIR:-${0%/*}}
DATA_DIR=/data/adb/syncthing-for-magisk
SYNCTHING_BIN="$MODDIR/bin/syncthing"
SYNCTHING_HOME="$DATA_DIR/config"
LOG_FILE="$SYNCTHING_HOME/syncthing.log"
STOP_FLAG="$DATA_DIR/syncthing.stop"

# --- Permissions ---
# Magisk keeps /data/adb at 0700 root, which would prevent the unprivileged
# 'shell' user (uid 2000) from reaching anything inside it. 0711 grants
# traversal without listing; the config directory itself stays 0770.
chmod 0711 /data/adb /data/adb/modules 2>/dev/null
chmod 0711 "$MODDIR" "$MODDIR/bin" "$DATA_DIR" 2>/dev/null
chmod 0755 "$SYNCTHING_BIN" 2>/dev/null

mkdir -p "$SYNCTHING_HOME"
chown 2000:2000 "$SYNCTHING_HOME"
chmod 0770 "$SYNCTHING_HOME"

# Rotate the log if it grew beyond 1 MB, keeping the last 256 KB
if [ -f "$LOG_FILE" ] && [ "$(wc -c < "$LOG_FILE")" -gt 1048576 ]; then
  tail -c 262144 "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
fi
touch "$LOG_FILE"
chown 2000:2000 "$LOG_FILE"
chmod 0660 "$LOG_FILE"

# Redirect all stdout and stderr of this script (and Syncthing's) to the log
exec >> "$LOG_FILE" 2>&1

echo "----------------------------------------------------"
echo "Syncthing service starting at $(date)"
echo "Module directory: $MODDIR"
echo "Config directory: $SYNCTHING_HOME"

# Wait until the boot process is complete
while [ "$(getprop sys.boot_completed)" != "1" ]; do
  sleep 1
done

# Give it a bit more time for network to be up
sleep 15

# A fresh boot always clears the manual stop flag: autostart wins on reboot
rm -f "$STOP_FLAG"

# First run: generate a unique configuration (device ID, certificates and API
# key) for this installation. Nothing personal is shipped inside the module.
# Syncthing v2's generate subcommand creates the identity and initial config.
if [ ! -f "$SYNCTHING_HOME/config.xml" ]; then
  echo "No config found. Generating a fresh configuration as user 'shell'..."
  su -c "exec env HOME='$SYNCTHING_HOME' '$SYNCTHING_BIN' generate --home='$SYNCTHING_HOME'" shell
  echo "Config generation exit status: $?"
fi

# --- Helpers ---
# Only match processes launched from OUR binary, so an instance of the
# Syncthing Android app is never mistaken for this module's service
our_pids() {
  for pid in $(pidof syncthing 2>/dev/null); do
    [ "$(readlink "/proc/$pid/exe" 2>/dev/null)" = "$SYNCTHING_BIN" ] && echo "$pid"
  done
}

# Supervisor loop: keep Syncthing alive across crashes. Stopping is done via
# the Action button, which sets the stop flag that pauses this loop.
while :; do
  if [ ! -x "$SYNCTHING_BIN" ]; then
    echo "Binary missing, supervisor exiting at $(date)"
    break
  fi
  if [ -f "$STOP_FLAG" ]; then
    sleep 10
    continue
  fi
  if [ -n "$(our_pids)" ]; then
    # Started manually via the Action button; do not double-start
    sleep 10
    continue
  fi
  echo "Starting Syncthing as user 'shell' at $(date)"
  # Use v2's long option names. --log-file=- sends Syncthing's own log to
  # stdout, which is already redirected to the module log above. The service
  # supervisor owns retries, so --no-restart makes Syncthing's monitor return
  # after a child failure instead of retrying internally.
  su -c "exec env HOME='$SYNCTHING_HOME' '$SYNCTHING_BIN' serve --no-browser --no-restart --no-upgrade --home='$SYNCTHING_HOME' --log-file=-" shell
  echo "Syncthing exited with status $? at $(date)"
  sleep 5
done

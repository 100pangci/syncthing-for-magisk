#!/system/bin/sh
# Simplified utility functions - no key detection, just auto-selection

# Simple function that always returns timeout to trigger auto-selection
get_key() {
  # Just sleep for a short time and return timeout
  sleep 0.5
  echo "TIMEOUT"
}

# Simplified selection function with immediate auto-selection
select_option() {
  local prompt="$1"
  local result_var_name="$2"
  shift 2

  local num_options=$#
  local current_selection=0
  
  ui_print " "
  ui_print "$prompt"
  ui_print " "
  ui_print "  Auto-selecting first option (User Mode - Recommended)"
  ui_print " "

  local i=0
  for option in "$@"; do
    if [ "$i" -eq "$current_selection" ]; then
      ui_print "  -> $option (AUTO-SELECTED)"
    else
      ui_print "     $option"
    fi
    i=$((i + 1))
  done
  
  ui_print " "
  ui_print "  Using safe default in 3 seconds..."
  
  # Give user a moment to see the selection
  sleep 3
  
  # Always return 0 (first option - User Mode)
  eval "$result_var_name=0"
}
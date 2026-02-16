#!/bin/bash

# add this to the crontab - Runs every 5min, you EDL updates every 5 min.
# */5 * * * * /opt/pan-edl-list/list-updater.sh >> /var/log/palo_edl_update.log 2>&1

# sudo systemctl daemon-reload
# sudo systemctl enable --now txtserver.service

# make sure you have permissions setup correctly....

set -euo pipefail

LOG_FILE="/var/log/paloalto.log"
EDL_FILE="/opt/pan-edl-list/palo-edl01.txt"
STATE_FILE="/var/tmp/palo_edl_update.state"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log "Run started"

# Ensure EDL file exists
mkdir -p "$(dirname "$EDL_FILE")"
touch "$EDL_FILE"

is_rfc1918() {
  local ip="$1"
  local o1 o2
  IFS='.' read -r o1 o2 _ _ <<<"$ip" || return 0

  # 10.0.0.0/8
  [[ "$o1" == "10" ]] && return 0
  # 192.168.0.0/16
  [[ "$o1" == "192" && "$o2" == "168" ]] && return 0
  # 172.16.0.0 - 172.31.0.0
  if [[ "$o1" == "172" ]]; then
    if [[ "$o2" =~ ^[0-9]+$ ]] && (( o2 >= 16 && o2 <= 31 )); then
      return 0
    fi
  fi

  return 1
}

# Track inode+byte offset so we only process new log content (handles rotation)
cur_inode="$(stat -c %i "$LOG_FILE" 2>/dev/null || echo 0)"
cur_size="$(stat -c %s "$LOG_FILE" 2>/dev/null || echo 0)"

last_inode=0
last_pos=0
if [[ -f "$STATE_FILE" ]]; then
  read -r last_inode last_pos < "$STATE_FILE" || true
fi

# If log rotated/truncated, reset
if [[ "$cur_inode" != "$last_inode" ]] || (( cur_size < last_pos )); then
  last_pos=0
fi

# Read only new bytes
new_data="$(dd if="$LOG_FILE" bs=1 skip="$last_pos" 2>/dev/null || true)"

# Update state immediately to current end-of-file (so we don't reprocess if script is interrupted)
echo "$cur_inode $cur_size" > "$STATE_FILE"

# Process new lines
while IFS= read -r line; do
  # Extract username like: user 'PoopBodega'
  user="$(grep -oP "user '\K[^']+" <<<"$line" 2>/dev/null || true)"
  [[ -z "$user" ]] && continue
  [[ "$user" == "Pooper" ]] && continue

  # Extract IP after "From:" and strip trailing dot if present
  ip="$(grep -oP "From:\s*\K([0-9]{1,3}\.){3}[0-9]{1,3}(?=\.|,|\"| )" <<<"$line" 2>/dev/null || true)"
  [[ -z "$ip" ]] && continue

  # Skip RFC1918
  if is_rfc1918 "$ip"; then
    continue
  fi

  # Add only if not already present
  if ! grep -Fxq "$ip" "$EDL_FILE"; then
    echo "$ip" >> "$EDL_FILE"
    log "Added: $ip"
  fi
done <<<"$new_data"

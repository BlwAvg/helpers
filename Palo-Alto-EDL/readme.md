# Palo Alto EDL Auto-Updater

## Overview

Bash script that:

- Parses `/var/log/paloalto.log`
- Extracts IP addresses from `From:` field
- Removes trailing dots
- Skips:
  - RFC1918 addresses (10/8, 172.16–31/12, 192.168/16)
  - Defined username
- Appends non-duplicate public IPs to:
  `/opt/pan-edl-list/palo-edl01.txt`
- Processes only new log entries (state-tracked)
- Designed to run five minutes via cron

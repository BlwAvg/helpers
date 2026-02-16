# Palo Alto EDL Auto-Updater

## Overview

This project automatically updates a Palo Alto Networks External Dynamic List (EDL) based on authentication failure logs.

---

## Step 1: Configure Syslog on Palo Alto

Configure your Palo Alto firewall to send syslog entries for the authentication events you want to track.

Example filters:

* `(eventid eq auth-fail)`
* `(status eq failure)`

Adjust the filter as needed for your environment.

---

## Step 2: Parse Logs with Bash Script

The script performs the following actions:

* Parses `/var/log/paloalto.log`

* Extracts IP addresses from the `From:` field

* Removes trailing dots from IP addresses

* Skips:

  * RFC1918 private IP ranges:

    * `10.0.0.0/8`
    * `172.16.0.0/12`
    * `192.168.0.0/16`
  * A defined username (if configured in the script)

* Appends non-duplicate public IP addresses to:

  ```
  /opt/pan-edl-list/palo-edl01.txt
  ```

* Tracks state so only new log entries are processed

---

## Step 3: Schedule with Cron

Palo Alto devices poll EDLs at a minimum interval of 5 minutes. Configure cron to match this interval:

```bash
*/5 * * * * /opt/pan-edl-list/list-updater.sh >> /var/log/palo_edl_update.log 2>&1
```

---

## Step 4: Host the EDL File

Set up a lightweight web server to serve the EDL file.

Example approach:

* Use a simple Python HTTP server
* Run it as a `systemd` service

The server should expose the directory containing:

```
/opt/pan-edl-list/palo-edl01.txt
```

---

## Step 5: Configure Palo Alto EDL

Point your Palo Alto firewall to the hosted EDL file:

```
http://YOUR-SERVER-IP:8080/palo-edl01.txt
```

Ensure the EDL object on the firewall is configured to poll every 5 minutes.

---

## ⚠️ Disclaimer

If you use this production, you are an idiot!

# Dynamic DNS Updater with Cloudflare

This repository provides a simple Linux appliance that updates multiple DNS entries using Cloudflare. It consists of scripts that automate the process and configurations that must be customized for your domains.

## 📂 Directory Structure
```
/               # The main script is here
|-- /scripts    # Main scripts that update DNS records
|-- /configs    # Configuration files (must be modified with your information)
|-- /logs       # Logs will be stored here
```

## 🔧 Setup Instructions

### 1️⃣ Modify Configuration Files
- Update the configuration files in the `/configs` directory with your domain details.
- Ensure the scripts in `/scripts` match your domain names. Replace placeholders like `domain1`, `domain2`, `domain3` with actual domain names.

### 2️⃣ Set Permissions
- Make the scripts executable:
  ```bash
  chmod +x /opt/dynamic_dns/scripts/*
  ```
- Restrict access to configuration files for security:
  ```bash
  chmod 600 /opt/dynamic_dns/configs/*
  ```

### 3️⃣ Create the Systemd Service and Timer

#### **Service File** (`/etc/systemd/system/dynamic-dns.service`)
Create and edit the following file:
```ini
[Unit]
Description=Dynamic DNS Updater
After=network-online.target

[Service]
ExecStart=/bin/bash /opt/dynamic_dns/master_updater.sh
Restart=always
User=root

[Install]
WantedBy=multi-user.target
```

#### **Timer File** (`/etc/systemd/system/dynamic-dns.timer`)
Create and edit the following file:
```ini
[Unit]
Description=Timer for Dynamic DNS Updater
After=network-online.target

[Timer]
OnBootSec=0min
OnUnitActiveSec=5min
Unit=dynamic-dns.service

[Install]
WantedBy=timers.target
```

### 4️⃣ Enable and Start the Service
Reload systemd and enable the service and timer:
```bash
sudo systemctl daemon-reload
sudo systemctl enable dynamic-dns.service
sudo systemctl start dynamic-dns.service
sudo systemctl enable dynamic-dns.timer
sudo systemctl start dynamic-dns.timer
```

### 5️⃣ Check Service Status
Verify if the service is running correctly:
```bash
sudo systemctl status dynamic-dns.service
sudo systemctl status dynamic-dns.timer
```

## 📝 Notes
- The main script `master_updater.sh` should be placed in `/opt/dynamic_dns/` and be executable.
- Ensure your Cloudflare API credentials are correctly set in the `/configs` directory.
- Logs will be generated in `/logs/` for troubleshooting.

## 🚀 Enjoy automated DNS updates with Cloudflare!

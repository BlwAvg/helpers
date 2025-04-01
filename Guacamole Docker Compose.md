# Guacamole Docker and Database Initialization
- **I dont know what I am doing.** Use this at your own risk.
- Dont forget to append `/guacamole` to your URL like this: `http://serverhere.com/guacamole` 
- Defualt creds are `guacadmin`

1. Docker Compose
2. DB Initalization Script
3. Nginx Proxy Manager (NPM) advanced configuration options

## 1. Docker Compose Config
```
services:
  guacamole-db:
    image: mysql:9.2.0
    container_name: guacamole-db
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: **ROOT_PASSWORD_HERE**
      MYSQL_DATABASE: guacamole_db
      MYSQL_USER: guacamole_user
      MYSQL_PASSWORD: **MYSQL_PASSWORD_HERE**
      TZ: America/**TIME_ZONE_HERE**
    volumes:
      - **Stoage/Location/HERE**:/var/lib/mysql

  guacd:
    image: guacamole/guacd:latest
    container_name: guacd
    restart: unless-stopped
    volumes:
      - **Stoage/Location/HERE**:/drive
      - **Stoage/Location/HERE**:/record
    environment:
      TZ: **TIME_ZONE_HERE**

  guacamole:
    image: guacamole/guacamole:latest
    container_name: guacamole
    restart: unless-stopped
    depends_on:
      - guacd
      - guacamole-db
    environment:
      GUACD_HOSTNAME: guacd
      MYSQL_HOSTNAME: guacamole-db
      MYSQL_DATABASE: guacamole_db
      MYSQL_USER: guacamole_user
      MYSQL_PASSWORD: **MYSQL_PASSWORD_HERE**
      TZ: America/**TIME_ZONE_HERE**
    ports:
      - **INBOUND_PORT_HERE**:8080
```


## 2. DB Initialization Script
I store the `init-guacamole-db.sh` in my local storage for the docker container. Dont for get to add add execute permissiosn `sudo chmod +x init-guacamole-db.sh`

```bash
#!/bin/bash
# init-guacamole-db.sh

# === CONFIGURABLE VARIABLES ===
GUAC_VERSION="1.5.4" # If you upgrade Guacamole, change the GUAC_VERSION.
DOWNLOAD_DIR="/tmp/guacamole-init"
MYSQL_CONTAINER="guacamole-db"
MYSQL_DB="guacamole_db"
MYSQL_ROOT_PASSWORD="netlab12"
GUACAMOLE_CONTAINER="guacamole"

# =============================
# Ensure MySQL Container Is Running
# =============================
echo "🔍 Checking MySQL container status..."

MYSQL_STATUS=$(docker inspect -f '{{.State.Status}}' "$MYSQL_CONTAINER" 2>/dev/null)

if [ "$MYSQL_STATUS" != "running" ]; then
  echo "🚀 Starting MySQL container: $MYSQL_CONTAINER"
  docker start "$MYSQL_CONTAINER"
  sleep 5
else
  echo "✅ MySQL container is already running."
fi

# === DOWNLOAD JDBC AUTH MODULE ===
mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR" || exit 1

echo "🔽 Downloading Guacamole JDBC module version $GUAC_VERSION..."
wget -q "https://downloads.apache.org/guacamole/${GUAC_VERSION}/binary/guacamole-auth-jdbc-${GUAC_VERSION}.tar.gz"

echo "📦 Extracting..."
tar -xzf "guacamole-auth-jdbc-${GUAC_VERSION}.tar.gz"

# === COPY SQL INIT SCRIPT INTO CONTAINER ===
SCHEMA_FILE="guacamole-auth-jdbc-${GUAC_VERSION}/mysql/schema/001-create-schema.sql"

if [[ ! -f "$SCHEMA_FILE" ]]; then
    echo "❌ Could not find schema file at $SCHEMA_FILE"
    exit 1
fi

echo "📁 Copying schema into MySQL container..."
docker cp "$SCHEMA_FILE" "$MYSQL_CONTAINER:/tmp/"

# === RUN INIT SCRIPT INSIDE MYSQL CONTAINER ===
echo "⚙️ Initializing Guacamole database schema..."
docker exec -i "$MYSQL_CONTAINER" sh -c "mysql -u root -p$MYSQL_ROOT_PASSWORD $MYSQL_DB < /tmp/001-create-schema.sql"

# === RESTART GUACAMOLE CONTAINER ===
echo "🔄 Restarting Guacamole container..."
docker restart "$GUACAMOLE_CONTAINER"

echo "✅ Guacamole DB initialization complete. Visit http://localhost:9080/guacamole"
```

## 3. NPM Configuration Options
redirect - This just works, use this.
```
location = / {
  return 301 /guacamole;
}
```

rewrite - You want to use just use the base domain. You picky degerate.
```
location / {
  rewrite ^/$ /guacamole/ redirect;
}
```

full proxy - You are nerd. Why are you useing this repo?
```
location / {
  proxy_pass http://<guacamole_ip>:9080/guacamole/;
  proxy_set_header Host $host;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto $scheme;
}
```


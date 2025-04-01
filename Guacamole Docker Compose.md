# Guacamole Docker and Database Initialization
- **I dont know what I am doing.** Use this at your own risk.
- Dont forget to append `/guacamole` to your URL like this: `http://serverhere.com/guacamole` 
- Defualt creds are `guacadmin`

1. Docker Compose
2. DB Initialization Script - This can nuke your DB into oblivion.
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
      - **Storage/Location/HERE**:/var/lib/mysql

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
- I store the `init-guacamole-db.sh` in my local storage for the docker container. '
- Don’t for get to add execute permissions `sudo chmod +x init-guacamole-db.sh`

```bash
#!/bin/bash

# =============================
# Configuration Variables
# =============================
WORKDIR="/tmp/guac-init"
GUAC_IMAGE="guacamole/guacamole"
MYSQL_CONTAINER="guacamole-db"
MYSQL_ROOT_PASSWORD="**MYSQL_PASSWORD_HERE**"
MYSQL_DATABASE="guacamole_db"
GUACAMOLE_CONTAINER="guacamole"

# =============================
# Helper: Ensure Container Is Running
# =============================
check_and_start_container() {
  local name="$1"
  local status
  status=$(docker inspect -f '{{.State.Status}}' "$name" 2>/dev/null)

  if [ "$status" == "running" ]; then
    echo "✅ $name is running"
  elif [ "$status" == "exited" ] || [ "$status" == "created" ]; then
    echo "🚀 Starting container: $name"
    docker start "$name"
    sleep 5
  else
    echo "❌ Container '$name' does not exist or failed to start"
    exit 1
  fi
}

# =============================
# Start Script
# =============================
echo "🔍 Checking container statuses..."
check_and_start_container "$MYSQL_CONTAINER"
check_and_start_container "$GUACAMOLE_CONTAINER"
echo "-----------------------------------"
echo "-----------------------------------"
# =============================
# Generate initdb.sql
# =============================
mkdir -p "$WORKDIR"
cd "$WORKDIR" || exit 1

echo "🛠 Generating schema from $GUAC_IMAGE..."
docker run --rm "$GUAC_IMAGE" /opt/guacamole/bin/initdb.sh --mysql > "$WORKDIR/initdb.sql"

if [ ! -s "$WORKDIR/initdb.sql" ]; then
  echo "❌ Failed to generate init script"
  exit 1
fi

# =============================
# Check if any tables exist
# =============================
echo "🔎 Checking if any tables exist in $MYSQL_DATABASE..."
HAS_TABLES=$(docker exec -i "$MYSQL_CONTAINER" sh -c \
  "mysql -u root -p${MYSQL_ROOT_PASSWORD} -sse \
   'SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=\"${MYSQL_DATABASE}\";'")

if [[ "$HAS_TABLES" -gt 0 ]]; then
  echo ""
  echo ""
  echo ""
  echo "READ THIS IDIOT"
  echo "******************************************************************"
  echo "💣 WARNING: The database '$MYSQL_DATABASE' already contains data."
  echo "If you continue, EVERYTHING in this database will be DESTROYED:"
  echo "❌ ALL TABLES"
  echo "❌ ALL DATA"
  echo "❌ EVEN NON-GUACAMOLE TABLES"
  echo "******************************************************************"
  echo ""
  read -p "⚠️  Are you SURE you want to nuke the entire database? This cannot be undone. [y/N]: " confirm
  case "$confirm" in
    [yY][eE][sS]|[yY])
      echo "🔥 Nuking database '$MYSQL_DATABASE'..."
      docker exec -i "$MYSQL_CONTAINER" sh -c \
        "mysql -u root -p${MYSQL_ROOT_PASSWORD} -e \
         'DROP DATABASE IF EXISTS \`${MYSQL_DATABASE}\`; CREATE DATABASE \`${MYSQL_DATABASE}\`;'"
      ;;
    *)
      echo "❌ Cancelled. Database was not touched."
      exit 0
      ;;
  esac
fi

echo "-----------------------------------"
echo "-----------------------------------"

# =============================
# Copy and Run Init SQL
# =============================
echo "📁 Copying init script to $MYSQL_CONTAINER..."
docker cp "$WORKDIR/initdb.sql" "$MYSQL_CONTAINER:/tmp/initdb.sql"

echo "⚙️ Initializing schema in '$MYSQL_DATABASE'..."
docker exec -i "$MYSQL_CONTAINER" sh -c \
  "mysql -u root -p${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE} < /tmp/initdb.sql"

if [ $? -ne 0 ]; then
  echo "❌ Failed to execute schema SQL"
  exit 1
fi

echo "-----------------------------------"
echo "-----------------------------------"

# =============================
# Restart Guacamole
# =============================
echo "🔄 Restarting $GUACAMOLE_CONTAINER..."
docker restart "$GUACAMOLE_CONTAINER"

echo ""
echo "✅ Guacamole has been initialized!"
echo "🔐 Login at: http://<your-host>:8080/guacamole - Use the IP and port from the compose file."
echo "   Username: guacadmin"
echo "   Password: guacadmin"
echo " *****CHANGE YOU DEFAULT PASSWORD*****"

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

full proxy - You are nerd. Why are you using this repo?
```
location / {
  proxy_pass http://<guacamole_ip>:9080/guacamole/;
  proxy_set_header Host $host;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto $scheme;
}
```

#!/bin/bash

set -e

# 🔧 Configurable settings
NUM_UPDATES=5
KASM_DIR="/opt/kasm"
BACKUP_DIR="/opt/kasm_backups"
TMP_DIR="/tmp/kasm_update"
BASE_URL="https://kasm-static-content.s3.amazonaws.com"

mkdir -p "$BACKUP_DIR" "$TMP_DIR"

# 🔍 Get current version from symlink
if [[ -L "$KASM_DIR/current" ]]; then
    CURRENT_VERSION=$(basename "$(readlink -f "$KASM_DIR/current")")
    echo "🔎 Current Kasm version: $CURRENT_VERSION"
else
    echo "❌ Could not determine current version."
    exit 1
fi

# 🌐 Get latest releases
echo "🌐 Fetching latest Kasm releases..."
RELEASES=$(curl -s "$BASE_URL" | grep -oP 'kasm_release_\d+\.\d+\.\d+\.\w+\.tar\.gz' | sort -u | sort -Vr | head -n "$NUM_UPDATES")

if [ -z "$RELEASES" ]; then
    echo "🚫 No releases found."
    exit 1
fi

# 📋 Show releases line by line
echo "📦 Most recent Kasm releases:"
i=1
declare -A OPTIONS
while IFS= read -r REL; do
    echo " [$i] $REL"
    OPTIONS[$i]="$REL"
    ((i++))
done <<< "$RELEASES"

# 🧠 Prompt for selection
while true; do
    read -rp "➡️ Select a release to install [1-${#OPTIONS[@]}]: " CHOICE
    SELECTED="${OPTIONS[$CHOICE]}"
    if [[ -n "$SELECTED" ]]; then
        echo "✔ Selected: $SELECTED"
        break
    else
        echo "❌ Invalid selection."
    fi
done

# Extract version from selected filename
SELECTED_VERSION=$(echo "$SELECTED" | sed -E 's/kasm_release_([^.]+.[^.]+.[^.]+.[^.]+).tar.gz/\1/')

# 🛑 Confirm update
echo ""
read -rp "⚠️  Confirm update from $CURRENT_VERSION to $SELECTED_VERSION? (y/N): " CONFIRM
if [[ "$CONFIRM" != [yY] ]]; then
    echo "❌ Update canceled."
    exit 0
fi

# 📥 Download
URL="$BASE_URL/$SELECTED"
FILENAME="$TMP_DIR/$SELECTED"

echo "⬇️ Downloading $SELECTED..."
curl -# -o "$FILENAME" "$URL"

# 💾 Backup current
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="$BACKUP_DIR/kasm_backup_$TIMESTAMP"
echo "📁 Backing up current version to $BACKUP_PATH..."
cp -r "$KASM_DIR" "$BACKUP_PATH"

# 🧹 Delete older backups (keep most recent only)
echo "🧹 Cleaning up old backups..."
ls -dt $BACKUP_DIR/kasm_backup_* 2>/dev/null | tail -n +2 | xargs rm -rf || true

# 📦 Extract and update
echo "📦 Extracting $SELECTED..."
tar -xzf "$FILENAME" -C "$TMP_DIR"

UPDATE_DIR=$(find "$TMP_DIR" -maxdepth 1 -type d -name "kasm_release_*")
cd "$UPDATE_DIR" || exit 1

echo "🚀 Running update.sh..."
./update.sh

# 🧽 Clean-up
echo "🧽 Cleaning up..."
rm -rf "$TMP_DIR"
docker image prune -af

echo "✅ Kasm update to $SELECTED_VERSION complete!"

#!/usr/bin/env bash
source "$(dirname "$0")/../config/backup.conf"

SOURCE_DIR="$1"
DEST_DIR="$2"
CUSTOM_NAME="$3"

if [[ ! -w "$DEST_DIR" ]]; then
    write_log "ERROR" "Arsip gagal: Direktori tujuan '$DEST_DIR' tidak memiliki izin tulis (read-only)."
    exit 3
fi

TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
ARCHIVE_NAME="${CUSTOM_NAME:-backup_${TIMESTAMP}}.tar.gz"
ARCHIVE_PATH="$DEST_DIR/$ARCHIVE_NAME"

tar -czf "$ARCHIVE_PATH" -C "$SOURCE_DIR" . 2>/dev/null
TAR_STATUS=$?

if [[ $TAR_STATUS -ne 0 || ! -f "$ARCHIVE_PATH" ]]; then
    write_log "ERROR" "Arsip gagal: Perintah tar gagal membuat '$ARCHIVE_PATH'."
    exit 3
fi

chmod 640 "$ARCHIVE_PATH"

ITEM_LOGGED=0
for entry in $(tar -tzf "$ARCHIVE_PATH"); do
    ((ITEM_LOGGED++))
done

write_log "INFO" "Arsip sukses: '$ARCHIVE_PATH' terbentuk ($ITEM_LOGGED entri, permission 640)."
echo "$ARCHIVE_PATH"
exit 0
#!/usr/bin/env bash
# Member 4 Responsibility: Data Recovery (Restore) to Test Directory
source "$(dirname "$0")/../config/backup.conf"

ARCHIVE_PATH="$1"
RESTORE_DIR="${2:-$DEFAULT_RESTORE}"
SCRIPT_DIR="$(dirname "$0")"

if [[ -z "$ARCHIVE_PATH" || ! -f "$ARCHIVE_PATH" ]]; then
    write_log "ERROR" "Restore failed: Archive file '$ARCHIVE_PATH' not found."
    exit 5
fi

# Mandatory integrity verification before running restore
"$SCRIPT_DIR/03_verify.sh" check "$ARCHIVE_PATH"
if [[ $? -ne 0 ]]; then
    write_log "ERROR" "Restore ABORTED: Archive '$ARCHIVE_PATH' is corrupted or failed checksum verification."
    exit 5
fi

mkdir -p "$RESTORE_DIR"
tar -xzf "$ARCHIVE_PATH" -C "$RESTORE_DIR" 2>/dev/null
if [[ $? -ne 0 ]]; then
    write_log "ERROR" "Restore failed: Error occurred while extracting '$ARCHIVE_PATH'."
    exit 5
fi

# Count successfully restored files
RESTORED_COUNT=0
for f in "$RESTORE_DIR"/*; do
    [[ -e "$f" ]] && ((RESTORED_COUNT++))
done

write_log "INFO" "Restore succeeded: $RESTORED_COUNT item(s) successfully restored to '$RESTORE_DIR'."
exit 0

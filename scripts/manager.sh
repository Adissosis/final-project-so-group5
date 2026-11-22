#!/usr/bin/env bash
source "$(dirname "$0")/../config/backup.conf"

SOURCE_DIR="${1:-$DEFAULT_SOURCE}"
DEST_DIR="${2:-$DEFAULT_DEST}"
SIMULATE_DELAY="${3:-0}" 
SCRIPT_DIR="$(dirname "$0")"

exec 200>"$LOCK_FILE"
flock -n 200
if [[ $? -ne 0 ]]; then
    write_log "ERROR" "Lock Conflict: Another backup process is already running! Duplicate execution rejected."
    exit 6
fi

write_log "INFO" "Lock acquired (PID: $$). Starting automated backup pipeline..."

if [[ "$SIMULATE_DELAY" -gt 0 ]]; then
    write_log "INFO" "Simulating workload for ${SIMULATE_DELAY} seconds..."
    sleep "$SIMULATE_DELAY"
fi

"$SCRIPT_DIR/01_validate.sh" "$SOURCE_DIR" "$DEST_DIR"
STATUS_VAL=$?
[[ $STATUS_VAL -ne 0 ]] && exit $STATUS_VAL

ARCHIVE_CREATED=$("$SCRIPT_DIR/02_archive.sh" "$SOURCE_DIR" "$DEST_DIR" | tail -n 1)
STATUS_ARC=$?
[[ $STATUS_ARC -ne 0 ]] && exit $STATUS_ARC

"$SCRIPT_DIR/03_verify.sh" generate "$ARCHIVE_CREATED" || exit 4
"$SCRIPT_DIR/03_verify.sh" check "$ARCHIVE_CREATED"
STATUS_VER=$?
[[ $STATUS_VER -ne 0 ]] && exit $STATUS_VER

mkdir -p "$(dirname "$REPORT_FILE")"
HASH_INFO=$(awk '{print $1}' "${ARCHIVE_CREATED}.sha256")

cat << EOF > "$REPORT_FILE"
=========================================================
LINUX AUTOMATED BACKUP & VERIFICATION REPORT (TOPIC 5A)
=========================================================
Execution Time      : $(date '+%Y-%m-%d %H:%M:%S')
Executing User      : $USER (PID: $$)
Source Directory    : $SOURCE_DIR
Archive Name        : $(basename "$ARCHIVE_CREATED")
Archive Size        : $(du -h "$ARCHIVE_CREATED" | awk '{print $1}')
SHA256 Checksum     : $HASH_INFO
Verification Status : PASSED VERIFICATION (EXIT STATUS 0)
=========================================================
Archive History in Destination Directory:
EOF

for arc in "$DEST_DIR"/*.tar.gz; do
    if [[ -f "$arc" ]]; then
        echo "- $(basename "$arc") ($(du -h "$arc" | awk '{print $1}'))" >> "$REPORT_FILE"
    fi
done

write_log "INFO" "Report successfully updated at '$REPORT_FILE'. Backup pipeline finished."
exit 0

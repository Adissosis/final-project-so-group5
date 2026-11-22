#!/usr/bin/env bash
source "$(dirname "$0")/../config/backup.conf"

MODE="$1"          
ARCHIVE_PATH="$2"
CHECKSUM_FILE="${ARCHIVE_PATH}.sha256"

if [[ ! -f "$ARCHIVE_PATH" ]]; then
    write_log "ERROR" "Verifikasi gagal: Berkas arsip '$ARCHIVE_PATH' tidak ditemukan."
    exit 4
fi

case "$MODE" in
    generate)
        sha256sum "$ARCHIVE_PATH" > "$CHECKSUM_FILE"
        if [[ $? -eq 0 ]]; then
            chmod 640 "$CHECKSUM_FILE"
            HASH_VAL=$(awk '{print $1}' "$CHECKSUM_FILE")
            write_log "INFO" "Checksum dibuat: $CHECKSUM_FILE (SHA256: $HASH_VAL)"
            exit 0
        else
            write_log "ERROR" "Gagal membuat berkas checksum untuk '$ARCHIVE_PATH'."
            exit 4
        fi
        ;;
    check)
        if [[ ! -f "$CHECKSUM_FILE" ]]; then
            write_log "ERROR" "Verifikasi gagal: Berkas checksum '$CHECKSUM_FILE' tidak ditemukan."
            exit 4
        fi
        sha256sum -c "$CHECKSUM_FILE" --status
        if [[ $? -eq 0 ]]; then
            write_log "INFO" "Verifikasi integritas LOLOS untuk '$ARCHIVE_PATH'."
            exit 0
        else
            write_log "ERROR" "Verifikasi integritas GAGAL! Checksum '$ARCHIVE_PATH' tidak cocok (berkas berubah/rusak)."
            exit 4
        fi
        ;;
    *)
        echo "Penggunaan: $0 <generate|check> <path_arsip>"
        exit 4
        ;;
esac
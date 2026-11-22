#!/usr/bin/env bash
source "$(dirname "$0")/../config/backup.conf"

SOURCE_DIR="$1"
DEST_DIR="$2"

if [[ -z "$SOURCE_DIR" || -z "$DEST_DIR" ]]; then
    write_log "ERROR" "Validasi gagal: Parameter sumber atau tujuan kosong."
    echo "Penggunaan: $0 <direktori_sumber> <direktori_tujuan>"
    exit 2
fi

if [[ ! -d "$SOURCE_DIR" || ! -r "$SOURCE_DIR" ]]; then
    write_log "ERROR" "Validasi gagal: Direktori sumber '$SOURCE_DIR' tidak ditemukan atau tidak memiliki izin baca."
    exit 2
fi

FILE_COUNT=0
for item in "$SOURCE_DIR"/*; do
    if [[ -e "$item" ]]; then
        ((FILE_COUNT++))
    fi
done

if [[ "$FILE_COUNT" -eq 0 ]]; then
    write_log "ERROR" "Validasi gagal: Direktori sumber '$SOURCE_DIR' kosong (0 berkas)."
    exit 2
fi

if [[ ! -d "$DEST_DIR" ]]; then
    mkdir -p "$DEST_DIR" 2>/dev/null
    if [[ $? -ne 0 ]]; then
        write_log "ERROR" "Validasi gagal: Tidak dapat membuat direktori tujuan '$DEST_DIR'."
        exit 2
    fi
fi

write_log "INFO" "Validasi sukses: Sumber '$SOURCE_DIR' memiliki $FILE_COUNT item."
exit 0
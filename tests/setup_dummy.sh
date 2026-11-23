#!/usr/bin/env bash
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DUMMY_DIR="$PROJECT_ROOT/tests/data_dummy"

mkdir -p "$DUMMY_DIR"
echo "Dokumen Keuangan Dummy - Unit Kerja A" > "$DUMMY_DIR/laporan_keuangan.txt"
echo "Catatan Rapat Operasional Dummy - 2026" > "$DUMMY_DIR/notulen_rapat.txt"
echo "Daftar Inventaris Dummy - 100 Item" > "$DUMMY_DIR/inventaris.csv"

rm -rf /tmp/uji_5a_kosong
mkdir -p /tmp/uji_5a_kosong

rm -rf /tmp/uji_5a_readonly
mkdir -p /tmp/uji_5a_readonly
chmod 555 /tmp/uji_5a_readonly

echo "[OK] Data dummy siap:"
echo "  - Sumber valid    : $DUMMY_DIR (3 berkas)"
echo "  - Sumber kosong   : /tmp/uji_5a_kosong"
echo "  - Tujuan readonly : /tmp/uji_5a_readonly"
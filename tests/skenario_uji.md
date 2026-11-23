# 1. UJI POSITIF UTAMA (Backup -> Checksum -> Log -> Laporan)
./scripts/05_manager.sh
echo "Exit status backup: $?"

# 2. UJI POSITIF RESTORE (Memulihkan arsip terbaru ke restore_test/)
ARSIP_TERBARU=$(ls -t backups/*.tar.gz | head -n 1)
./scripts/04_restore.sh "$ARSIP_TERBARU"
echo "Exit status restore: $?"
ls -la restore_test/

# 3. UJI NEGATIF CEPAT (Untuk memastikan exit status error bekerja)
./scripts/01_validate.sh /tmp/uji_5a_kosong backups
echo "Exit status Anggota 1 (harus 2): $?"

./scripts/02_archive.sh tests/data_dummy /tmp/uji_5a_readonly
echo "Exit status Anggota 2 (harus 3): $?"
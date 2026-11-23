# 1. UJI POSITIF UTAMA (Backup -> Checksum -> Log -> Laporan)
```bash
./scripts/05_manager.sh
echo "Exit status backup: $?"
```

Hasil yang diharapkan:
1. Muncul log [INFO] rangkaian backup selesai dan Exit status backup: 0.
2. Terbentuk berkas arsip .tar.gz dan .sha256 di folder backups/.
3. Berkas logs/backup.log dan output/laporan.txt terbentuk dengan status PASSED VERIFICATION (EXIT STATUS 0).

# 2. UJI POSITIF RESTORE (Memulihkan arsip terbaru ke restore_test/)
```bash
ARSIP_TERBARU=$(ls -t backups/*.tar.gz | head -n 1)
./scripts/04_restore.sh "$ARSIP_TERBARU"
echo "Exit status restore: $?"
ls -la restore_test/
```

Hasil yang diharapkan:
1. Pra-verifikasi checksum dinyatakan lolos dan muncul Exit status restore: 0.
2. Ketiga berkas dummy (inventaris.csv, laporan_keuangan.txt, notulen_rapat.txt) berhasil diekstrak kembali ke folder restore_test/.

# 3. UJI NEGATIF CEPAT (Untuk memastikan exit status error bekerja)
```bash
./scripts/01_validate.sh /tmp/uji_5a_kosong backups
echo "Exit status Anggota 1 (harus 2): $?"
```

Hasil yang diharapkan:
1. Proses ditolak dengan pesan [ERROR] Validasi gagal: Direktori sumber '/tmp/uji_5a_kosong' kosong (0 berkas).
2. Mengembalikan nilai Exit status Anggota 1 (harus 2): 2.

```bash
./scripts/02_archive.sh tests/data_dummy /tmp/uji_5a_readonly
echo "Exit status Anggota 2 (harus 3): $?"
```

Hasil yang diharapkan:
1. Proses ditolak dengan pesan [ERROR] Arsip gagal: Direktori tujuan '/tmp/uji_5a_readonly' tidak memiliki izin tulis (read-only).
2. Tidak ada arsip yang terbentuk dan mengembalikan nilai Exit status Anggota 2 (harus 3): 3.
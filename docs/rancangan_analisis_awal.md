# Rancangan Sistem & Analisis Awal Konsep Sistem Operasi (Topik 5A)

## 1. Spesifikasi Lingkungan VM Linux
- **Sistem Operasi:** [Isi hasil perintah `lsb_release -d`, contoh: Ubuntu 24.04 LTS]
- **Kernel Linux:** [Isi hasil perintah `uname -r`]
- **Alokasi Hardware VM:** [Contoh: 2 vCPU, 4 GB RAM, 25 GB Storage]

## 2. Arsitektur & Alur Kerja Sistem
```text
[User Operator]
       │
       ▼
[05_manager.sh] ──(1. flock -n /tmp/backup_5a.lock)──► Tolak jika ada proses ganda (exit 6)
       │
       ├──► [01_validate.sh]  : Validasi parameter, direktori sumber & tujuan (exit 0 / 2)
       ├──► [02_archive.sh]   : Kompresi tar.gz ber-timestamp + chmod 640 (exit 0 / 3)
       ├──► [03_verify.sh]    : Generate & cek integritas sha256sum (exit 0 / 4)
       └──► [output/laporan.txt & logs/backup.log]
                    │
                    ▼ (Bind Mount Read-Only)
            [Docker Container: alpine:3.20] ──► Baca sukses (exit 0) / Tulis ditolak (exit 1)

[Pemulihan Data]
[04_restore.sh] ──► Panggil [03_verify.sh check] ──► Jika valid, ekstrak ke restore_test/ (exit 0 / 5)
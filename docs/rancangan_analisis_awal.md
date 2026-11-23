# Rancangan Sistem & Analisis Awal Konsep Sistem Operasi (Topik 5A)

## 1. Spesifikasi Lingkungan VM Linux
- **Sistem Operasi:** Ubuntu Desktop 26.04 LTS
- **Kernel Linux:** 7.0.0-38-generic
- **Alokasi Hardware VM:** 2 vCPU, 6 GB RAM

## 2. Arsitektur & Alur Kerja Sistem

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

## 3. Rancangan User, Group, & Matriks Hak Akses (Proteksi)
Sistem dirancang agar tidak dijalankan seluruhnya menggunakan akun `root`. Matriks hak akses:

| Akun / Grup | Peran | Direktori Sumber | Direktori Backup (`backups/`) | Arsip `.tar.gz` (`chmod 640`) | Direktori Laporan (`output/`) |
| :--- | :--- | :---: | :---: | :---: | :---: |
| `operator_backup` (Owner) | Menjalankan backup & restore | Read (`r-x`) | Read/Write (`rwx`) | Read/Write (`rw-`) | Read/Write (`rwx`) |
| Grup `backup_grp` | Auditor / pembaca internal | Read (`r-x`) | Read (`r-x`) | Read (`r--`) | Read (`r-x`) |
| `user_tamu` (Others) | Pengguna luar (uji negatif) | Ditolak (`---`) | Ditolak (`---`) | Ditolak (`---`) | Ditolak (`---`) |
| Docker (`alpine:3.20`) | Pembaca laporan via container | Tidak di-mount | Tidak di-mount | Tidak di-mount | **Read-Only** (`bind,readonly`) |

## 4. Draf Analisis Awal Konsep Sistem Operasi
1. **Sistem Berkas & Struktur Direktori (Adis Fawaz Guspandi):**
   Validasi pada `01_validate.sh` memeriksa eksistensi direktori sumber, izin baca (*read permission*), dan menghitung jumlah berkas sebelum operasi pengarsipan dimulai agar tidak memproses direktori kosong atau ilegal (`exit 2`).
2. **Operasi I/O & Proteksi Berkas (Hafiz Muhammad Shahzaib):**
   Pembuatan arsip pada `02_archive.sh` memanfaatkan `tar -czf` untuk membaca aliran data berkas (*sequential I/O*) lalu mengompresinya. Proteksi diterapkan melalui pemeriksaan izin tulis direktori tujuan (`exit 3` jika *read-only*) dan pengaturan `chmod 640` pada arsip yang terbentuk.
3. **Integritas Sistem Berkas & Pembacaan Blok Data (Zaidan Rasyid Prihantoro):**
   Verifikasi pada `03_verify.sh` menggunakan algoritma `sha256sum` yang membaca seluruh blok byte arsip. Perubahan sekecil 1 byte pada arsip akan menghasilkan nilai *hash* berbeda dan langsung memicu kegagalan verifikasi (`exit 4`).
4. **Konsistensi Data & Siklus Hidup Proses (Edwardus Jonathan Immanuel):**
   Pemulihan pada `04_restore.sh` menjalankan pra-verifikasi integritas sebagai *child process* sebelum ekstraksi. Jika arsip rusak, pemulihan dibatalkan (`exit 5`) sehingga mencegah kerusakan data di direktori tujuan.
5. **Sinkronisasi, Analisis Deadlock, & Sumber Daya CPU/Memori (Kenny Tanna Haholongan Pandia):**
   Direktori `backups/` dan berkas `output/laporan.txt` adalah *critical section*. Mekanisme `flock -n` pada `/tmp/backup_5a.lock` mencegah *race condition* akibat eksekusi ganda (`exit 6`). Sistem bebas *deadlock* karena hanya mengunci satu sumber daya secara *non-blocking* (tidak memenuhi syarat *Hold and Wait* maupun *Circular Wait*). Uji beban CPU/Memori (2 ukuran beban) dan isolasi mount Docker *read-only* akan dilengkapi pada tahap H-7.
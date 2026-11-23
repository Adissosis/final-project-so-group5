# Sistem Otomasi Backup dan Pemulihan Data Linux (Topik 5A)

Proyek Akhir Terintegrasi MK Sistem Operasi & Praktikum Sistem Operasi — S1 Sistem Informasi, FIK UPN Veteran Jakarta.

## Identitas Kelompok
- **Kelas & Kelompok:** PBI - Kelompok 05
- **Pilihan Proyek:** 5A — Sistem Otomasi Backup dan Pemulihan Data Linux (5 Mahasiswa)
- **Lingkungan VM Linux:** Ubuntu Desktop 26.04 LTS, 2 vCPU, 6 GB RAM

## Pembagian Tanggung Jawab, Skenario (+/-), & Analisis SO

| No | Nama & NIM | File Script | Tanggung Jawab Teknis | Skenario Positif (+) | Skenario Negatif (-) | Fokus Analisis Teori SO |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | Adis Fawaz Guspandi 2510512055 | `scripts/01_validate.sh` | Validasi sumber & parameter | Sumber valid diterima (`exit 0`) | Sumber tidak ada/kosong ditolak (`exit 2`) | Sistem Berkas & Struktur Direktori |
| 2 | Hafiz Muhammad Shahzaib 2510512901 | `scripts/02_archive.sh` | Pembuatan arsip `.tar.gz` | Arsip terbentuk & isi sesuai (`exit 0`) | Direktori tujuan *read-only* gagal (`exit 3`) | Operasi I/O & Proteksi/Permission |
| 3 | Zaidan Rasyid Prihantoro 2510512088 | `scripts/03_verify.sh` | Verifikasi integritas (`sha256sum`) | Arsip asli lolos verifikasi (`exit 0`) | Arsip diubah terdeteksi beda *checksum* (`exit 4`) | Integritas Sistem Berkas & Blok Data |
| 4 | Edwardus Jonathan Immanuel 2510512113 | `scripts/04_restore.sh` | Pemulihan data (*restore*) | Data pulih identik ke direktori uji (`exit 0`) | Arsip rusak ditolak sebelum *restore* (`exit 5`) | Konsistensi Data & Siklus Hidup Proses |
| 5 | Kenny Tanna Haholongan Pandia 2510512027 | `scripts/05_manager.sh` | Lock (`flock`), log, laporan, & Docker | Container membaca `laporan.txt` (`exit 0`) | Eksekusi ganda ditolak (`exit 6`) & tulis via mount RO ditolak (`exit 1`) | Sinkronisasi (*Critical Section*), *Deadlock*, & CPU/Memori |

## Struktur Repository
- `config/` : Konfigurasi path dan fungsi log standar (`backup.conf`)
- `scripts/` : Modul shell script proyek (01–05)
- `tests/` : Skenario pengujian & generator data dummy *(tahap H-14)*
- `docs/` : Rancangan awal & laporan utama teori SO *(tahap H-14)*
- `evidence/` : Bukti pengujian terminal terpilih *(tahap H-14/H-7)*

## Cara Menjalankan (Ringkas)
1. Clone repository dan berikan izin eksekusi:
   ```bash
   git clone https://github.com/Adissosis/final-project-so-group5.git
   cd final-project-so-group5
   chmod +x scripts/*.sh

2. Siapkan data dummy dan jalankan rangkaian backup utama:
   ./tests/setup_dummy.sh
   ./scripts/05_manager.sh

3. Pulihkan (restore) arsip terbaru ke direktori uji:

   ./scripts/04_restore.sh "$(ls -t backups/*.tar.gz | head -n 1)"
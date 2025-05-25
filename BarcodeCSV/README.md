
# Barcode CSV Realtime Google Sheets Sync

Sistem otomatisasi pemindaian barcode batang dengan visualisasi data **secara real-time** langsung ke **Google Sheets**. Dibuat untuk mempermudah proses stok opname dan pengelolaan data produk dari sistem lama yang masih bersifat manual dan offline.

---

## Studi Kasus (Masalah)

1. Scanner barcode manual hanya menyimpan data secara lokal saat **stok opname**.
2. Data harus **dipindahkan manual** dari perangkat scanner ke komputer.
3. Data hasil scan masih dalam format yang **kurang rapi**.
4. Tampilan realtime hanya tersedia di layar kecil perangkat scanner, sehingga **tidak nyaman digunakan**.
5. Data **tidak dapat dibagikan secara online** (non-shareable / live collaborative).

---

## Tujuan Proyek

Membuat sistem yang dapat:
- Memproses barcode secara otomatis dari scanner.
- Mencocokkan data dengan file CSV lokal.
- Menampilkan hasil scan **langsung di Google Sheets** secara real-time.
- Menggunakan antarmuka terminal sederhana (menu angka).

---

## UI / Tampilan

- Antarmuka berbasis **Command Line Interface (CLI)**.
- Navigasi dilakukan menggunakan **angka dan enter**.
- Dapat dijalankan melalui:
  - CMD (Windows)
  - Terminal (macOS / Linux)

---

## Cara Kerja Sistem (Sisi Pengguna)

1. Siapkan **file CSV** yang berisi database produk dari sistem stok yang sudah ada.
2. Hubungkan **scanner barcode batang** ke laptop via **Bluetooth** atau **wireless**.
3. Buka Google Sheets yang sudah dikonfigurasi.
4. Jalankan aplikasi melalui terminal/CMD.
5. Navigasi menu dan pilih opsi “Mulai Scan”.
6. Setiap barcode yang dipindai akan **langsung muncul di Google Sheets** secara realtime.

---

## Cara Kerja Sistem (Sisi Developer)

### 1. Bahasa Pemrograman & Library
- **Swift (opsional)**:
  - `SwiftCSV`, `CSV`, `CodableCSV`
- **Python (utama)**:
  - `gspread` – untuk menghubungkan dengan Google Sheets
  - `csv`, `json` – untuk membaca dan mencocokkan data lokal

### 2. Setup Google Sheets API
- Daftar ke **Google Cloud Console** dan aktifkan **Google Sheets API v4**.
- Unduh dan simpan file `credentials.json`.
- Buat Google Sheet dan **bagikan ke email service account** dari `credentials.json` dengan akses **Editor**.

### 3. Setup & Jalankan Aplikasi
1. Siapkan file CSV sebagai referensi database produk.
2. Buat header di Google Sheets sesuai dengan file CSV.
3. Jalankan aplikasi:
   ```bash
   python3 main.py

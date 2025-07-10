#  DompetKu - Aplikasi Pencatat Keuangan Pribadi 💰

Aplikasi mobile sederhana yang dibuat menggunakan Flutter untuk membantu melacak pemasukan dan pengeluaran keuangan pribadi. Aplikasi ini terhubung dengan Firebase Firestore sebagai database real-time dan menampilkan visualisasi data yang interaktif.

Proyek ini dibuat sebagai bagian dari proses belajar pengembangan aplikasi mobile dengan Flutter.

## ✨ Tangkapan Layar (Screenshots)

| Halaman Hari Ini | Halaman Riwayat & Grafik |
|:---:|:---:|:---:|
| ![Halaman Hari Ini](https://github.com/user-attachments/assets/3cf0e973-ce27-47e2-a3ea-c3ad0cef1151) | ![Halaman Riwayat & Grafik](https://github.com/user-attachments/assets/bce7ae5d-3316-49a5-8f86-21ae0fbab71f) |
| Form Tambah/Edit | Detail Riwayat |
|:---:|:---:|
| ![Form](https://github.com/user-attachments/assets/99cb5812-bdcd-4600-9b5a-8e540acd7066) | ![Detail Riwayat](https://github.com/user-attachments/assets/138d61eb-cfff-4aff-9636-fc7a9922d125) |

## 🚀 Fitur Utama

- **📊 Dashboard Real-time:** Menampilkan ringkasan sisa uang total dan aktivitas keuangan (pemasukan, pengeluaran, saldo) khusus untuk hari ini.
- **📈 Grafik Interaktif:** Visualisasi tren pemasukan & pengeluaran dalam rentang waktu 7 atau 30 hari terakhir menggunakan line chart yang modern.
- **📜 Riwayat Transaksi:** Menampilkan semua histori transaksi yang dikelompokkan per hari dengan ringkasan harian yang bisa di-expand/collapse untuk melihat detail.
- **➕ Tambah Transaksi:** Form input yang mudah digunakan untuk mencatat pemasukan atau pengeluaran baru.
- **✏️ Edit & Hapus Transaksi:** Mengelola data transaksi dengan mudah (tap untuk edit, swipe untuk hapus).
- **🗂️ Kategori Dinamis:** Pilihan kategori umum (Makanan, Transportasi, dll.) dengan opsi untuk menambah kategori kustom saat input data.

## 🛠️ Teknologi & Package yang Digunakan

- **Framework:** Flutter
- **Database:** Google Firebase (Cloud Firestore)
- **State Management:** StatefulWidget
- **Charting:** [fl_chart](https://pub.dev/packages/fl_chart)
- **Formatting:** [intl](https://pub.dev/packages/intl)

## ⚙️ Cara Menjalankan Proyek

1.  **Clone repository ini:**
    ```bash
    git clone [https://github.com/arielyosua/DompetKu.git](https://github.com/arielyosua/DompetKu.git)
    ```
2.  **Pindah ke direktori proyek:**
    ```bash
    cd DompetKu
    ```
3.  **Setup Firebase:**
    Pastikan Anda sudah memiliki file `firebase_options.dart` yang terkonfigurasi dengan proyek Firebase Anda. Ikuti petunjuk dari [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup).

4.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
5.  **Jalankan aplikasi:**
    ```bash
    flutter run
    ```

## 🗺️ Rencana Pengembangan (Roadmap)

Beberapa fitur yang direncanakan untuk pengembangan selanjutnya:
- [ ] Fitur Filter & Pencarian di halaman Riwayat.
- [ ] Fitur Ekspor data ke format CSV/PDF.
- [ ] Notifikasi harian untuk mengingatkan input transaksi.
- [ ] Tema Terang & Gelap (Light & Dark Mode).

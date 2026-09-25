# CleanGo

CleanGo adalah aplikasi mobile berbasis Flutter untuk membantu pelanggan
menemukan dan memesan layanan kebersihan, seperti *deep cleaning*, cuci AC,
pembersihan sofa dan kasur, layanan setrika, serta pembersihan kantor.

Aplikasi ini dirancang agar pelanggan dapat melihat layanan dan harga, memilih
jadwal, melakukan pemesanan, serta memantau status pesanan. Pengembangannya
dilakukan secara bertahap berdasarkan
[desain CleanGo di Figma](https://www.figma.com/design/ymMzgCxXWLUncDBzi1e4Oq/Cleango?node-id=0-1&t=kUGEigke0uE9bbdr-1).

## Status pengembangan

Implementasi saat ini berfokus pada fondasi project dan slicing halaman Beranda.
Data layanan masih berupa data lokal dan navigasi menuju halaman lain belum
diaktifkan.

Bagian yang sudah tersedia:

- Tema aplikasi dan tipografi Plus Jakarta Sans.
- Header pengguna, lokasi, kolom pencarian, dan banner promosi.
- Kategori layanan berbasis data lokal.
- Kartu layanan populer dengan horizontal scrolling.
- Bottom navigation dan tombol chatbot sebagai reusable widget.
- Layout responsif untuk berbagai ukuran layar mobile.

## Teknologi

- Flutter dan Dart.
- Material Design.
- `flutter_svg` untuk aset ikon SVG.
- Plus Jakarta Sans sebagai font utama.

## Struktur project

```text
cleango_app/
|-- android/                         # Konfigurasi dan runner Android
|-- ios/                             # Konfigurasi dan runner iOS
|-- linux/                           # Konfigurasi dan runner Linux
|-- macos/                           # Konfigurasi dan runner macOS
|-- web/                             # Konfigurasi aplikasi web
|-- windows/                         # Konfigurasi dan runner Windows
|
|-- assets/
|   |-- fonts/
|   |   |-- OFL.txt
|   |   |-- PlusJakartaSans-Regular.ttf
|   |   |-- PlusJakartaSans-Medium.ttf
|   |   |-- PlusJakartaSans-SemiBold.ttf
|   |   `-- PlusJakartaSans-Bold.ttf
|   |-- icons/
|   |   |-- ac_installation.svg
|   |   |-- ac_wash.svg
|   |   |-- add.svg
|   |   |-- clock.svg
|   |   |-- daily_cleaning.svg
|   |   |-- deep_cleaning.svg
|   |   |-- home.svg
|   |   |-- ironing.svg
|   |   |-- location.svg
|   |   |-- messages.svg
|   |   |-- monthly_cleaning.svg
|   |   |-- notification.svg
|   |   |-- office.svg
|   |   |-- orders.svg
|   |   |-- pandy.svg
|   |   |-- profile.svg
|   |   |-- search.svg
|   |   |-- services.svg
|   |   |-- sofa_mattress.svg
|   |   `-- star.svg
|   `-- images/
|       |-- ac_service.jpeg
|       |-- deep_cleaning.jpeg
|       |-- promo_banner.png
|       |-- sofa_cleaning.jpeg
|       `-- user_profile.jpeg
|
|-- lib/
|   |-- main.dart                    # Entry point aplikasi
|   |-- app.dart                     # Konfigurasi utama MaterialApp
|   |-- core/
|   |   `-- theme/
|   |       `-- app_theme.dart       # Warna, tipografi, dan tema global
|   |-- features/
|   |   `-- home/
|   |       `-- presentation/
|   |           |-- pages/
|   |           |   `-- home_page.dart
|   |           `-- widgets/
|   |               |-- popular_service_card.dart
|   |               `-- service_category_item.dart
|   `-- shared/
|       `-- widgets/
|           |-- bottom_navigation.dart
|           `-- chatbot_button.dart
|
|-- .gitignore                       # File yang tidak dilacak Git
|-- .metadata                        # Metadata project Flutter
|-- analysis_options.yaml            # Konfigurasi lint dan analyzer
|-- pubspec.yaml                     # Dependency, aset, font, dan metadata
|-- pubspec.lock                     # Versi dependency yang digunakan
`-- README.md                        # Dokumentasi project
```

Folder `.dart_tool/` dan `build/` dihasilkan otomatis oleh Flutter. Folder
konfigurasi IDE seperti `.idea/` juga bukan tempat menyimpan implementasi
aplikasi.

## Aturan penempatan kode

- Kode khusus fitur disimpan di dalam `features/<nama_fitur>/`.
- Halaman ditempatkan di `presentation/pages/`.
- Widget yang hanya digunakan satu fitur ditempatkan di
  `presentation/widgets/` milik fitur tersebut.
- Widget yang dapat digunakan oleh beberapa halaman ditempatkan di
  `shared/widgets/`.
- Tema, warna, dan konfigurasi global ditempatkan di `core/`.
- Folder baru dibuat ketika sudah mempunyai tanggung jawab yang jelas.

## Menjalankan aplikasi

Pastikan Flutter SDK dan perangkat atau emulator sudah tersedia.

```bash
flutter pub get
flutter run
```

## Pemeriksaan kualitas

```bash
dart format .
flutter analyze
```

## Pengembangan berikutnya

Tahap berikutnya dapat mencakup halaman daftar dan detail layanan, autentikasi,
booking, alamat, pembayaran, status pesanan, serta integrasi API. Routing, model
data, dan state management sebaiknya ditambahkan ketika kebutuhan fitur tersebut
sudah mulai diimplementasikan.

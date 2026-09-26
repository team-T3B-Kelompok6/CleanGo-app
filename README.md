# CleanGo

CleanGo adalah aplikasi mobile berbasis Flutter untuk membantu pelanggan
menemukan dan memesan layanan kebersihan, seperti *deep cleaning*, cuci AC,
pembersihan sofa dan kasur, layanan setrika, serta pembersihan kantor.

Aplikasi ini dirancang agar pelanggan dapat melihat layanan dan harga, memilih
jadwal, melakukan pemesanan, serta memantau status pesanan secara real-time.

Pengembangannya dilakukan sesuai pada design CleanGo di Figma:
[Link Desain Figma](https://www.figma.com/design/ymMzgCxXWLUncDBzi1e4Oq/Cleango?node-id=0-1&t=4yxoYg0SISypIbv1-1)


## Struktur project

```text
cleango_app/
├── android/                              # Konfigurasi dan runner Android
├── ios/                                  # Konfigurasi dan runner iOS
├── linux/                                # Konfigurasi dan runner Linux
├── macos/                                # Konfigurasi dan runner macOS
├── web/                                  # Bootstrap, manifest, dan ikon Flutter Web
├── windows/                              # Konfigurasi dan runner Windows
│
├── assets/
│   ├── fonts/                            # Font Plus Jakarta Sans dan lisensinya
│   │   ├── OFL.txt
│   │   ├── PlusJakartaSans-Regular.ttf
│   │   ├── PlusJakartaSans-Medium.ttf
│   │   ├── PlusJakartaSans-SemiBold.ttf
│   │   └── PlusJakartaSans-Bold.ttf
│   ├── icons/                            # Ikon SVG untuk navigasi dan komponen UI
│   │   ├── ac_installation.svg
│   │   ├── ac_wash.svg
│   │   ├── add.svg
│   │   ├── back.svg
│   │   ├── clock.svg
│   │   ├── daily_cleaning.svg
│   │   ├── deep_cleaning.svg
│   │   ├── detail_back.svg
│   │   ├── detail_check.svg
│   │   ├── detail_chevron.svg
│   │   ├── detail_rating_star.svg
│   │   ├── detail_review_star.svg
│   │   ├── fogging.svg
│   │   ├── home.svg
│   │   ├── ironing.svg
│   │   ├── location.svg
│   │   ├── messages.svg
│   │   ├── monthly_cleaning.svg
│   │   ├── nav_home_inactive.svg
│   │   ├── nav_messages_inactive.svg
│   │   ├── nav_orders_inactive.svg
│   │   ├── nav_profile_inactive.svg
│   │   ├── nav_services_active.svg
│   │   ├── notification.svg
│   │   ├── office.svg
│   │   ├── orders.svg
│   │   ├── pandy.svg
│   │   ├── pandy_compact.svg
│   │   ├── profile.svg
│   │   ├── rating_star.svg
│   │   ├── search.svg
│   │   ├── service_clock.svg
│   │   ├── service_search.svg
│   │   ├── services.svg
│   │   ├── sofa_mattress.svg
│   │   ├── sort.svg
│   │   └── star.svg
│   └── images/                           # Foto layanan, promo, dan profil pengguna
│       ├── ac_service.jpeg
│       ├── deep_cleaning.jpeg
│       ├── promo_banner.png
│       ├── service_ac_care.jpeg
│       ├── service_daily_cleaning.jpeg
│       ├── service_deep_cleaning.jpeg
│       ├── service_detail_hero.jpeg
│       ├── service_office.jpeg
│       ├── service_sofa_mattress.jpeg
│       ├── sofa_cleaning.jpeg
│       └── user_profile.jpeg
│
├── lib/
│   ├── main.dart                         # Entry point aplikasi
│   ├── app.dart                          # MaterialApp dan registrasi Provider
│   │
│   ├── core/                             # Konfigurasi yang digunakan seluruh aplikasi
│   │   ├── constants/
│   │   │   └── app_routes.dart           # Konstanta nama route
│   │   └── theme/
│   │       └── app_theme.dart            # Warna, tipografi, dan tema global
│   │
│   ├── features/                         # Modul berdasarkan fitur aplikasi
│   │   ├── home/
│   │   │   ├── data/
│   │   │   │   └── home_data.dart       # Data lokal kategori, promo, dan layanan populer
│   │   │   ├── domain/
│   │   │   │   └── models/
│   │   │   │       ├── popular_service_model.dart
│   │   │   │       └── service_category_model.dart
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       │   └── home_page.dart
│   │   │       └── widgets/
│   │   │           ├── popular_service_card.dart
│   │   │           └── service_category_item.dart
│   │   │
│   │   ├── service/
│   │   │   ├── data/
│   │   │   │   └── service_data.dart    # Sumber data lokal seluruh layanan
│   │   │   ├── domain/
│   │   │   │   └── models/
│   │   │   │       └── service_model.dart
│   │   │   └── presentation/
│   │   │       ├── controllers/
│   │   │       │   └── service_controller.dart # Filter, pencarian, dan layanan terpilih
│   │   │       ├── pages/
│   │   │       │   ├── service_list_page.dart
│   │   │       │   └── service_detail_page.dart
│   │   │       └── widgets/
│   │   │           └── service_card.dart
│   │   │
│   │   └── booking/
│   │       └── presentation/
│   │           ├── controllers/
│   │           │   └── booking_controller.dart # State layanan, jadwal, alamat, dan catatan
│   │           ├── pages/
│   │           │   └── booking_page.dart
│   │           └── widgets/
│   │               └── booking_widgets.dart     # Kalender, pilihan jam, dan kartu alamat
│   │
│   └── shared/                           # Komponen yang dipakai oleh beberapa fitur
│       └── widgets/
│           ├── bottom_navigation.dart
│           └── chatbot_button.dart
│
├── .gitignore                            # Daftar file yang tidak dilacak Git
├── .metadata                             # Metadata project Flutter
├── analysis_options.yaml                 # Aturan lint dan static analysis
├── pubspec.yaml                          # Dependency, aset, font, dan metadata project
├── pubspec.lock                          # Versi dependency yang terkunci
└── README.md                             # Dokumentasi project
```


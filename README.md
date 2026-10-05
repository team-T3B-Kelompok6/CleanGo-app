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
│   ├── fonts/                            # Font Inter dan lisensinya
│   │   ├── Inter-OFL.txt
│   │   ├── Inter-Regular.ttf
│   │   ├── Inter-Medium.ttf
│   │   ├── Inter-SemiBold.ttf
│   │   ├── Inter-Bold.ttf
│   │   └── Inter-ExtraBold.ttf
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
│   │   ├── boo.svg
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
│       ├── cleaner_siti.jpeg                 # Foto potret profil cleaner Siti Rahmawati
│       ├── deep_cleaning.jpeg
│       ├── malang_map_route.jpeg             # Ilustrasi rute peta Malang City Point - Sigura Gura
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
│   ├── features/                         # Modul berdasarkan fitur aplikasi (Clean Architecture)
│   │   ├── address/                      # Fitur Alamat Pembersihan & Tersimpan
│   │   │   ├── domain/
│   │   │   │   └── models/
│   │   │   │       └── address_model.dart           # Model entitas alamat & mapper CleaningAddress
│   │   │   ├── controllers/
│   │   │   │   └── address_controller.dart          # Global state provider (tambah, edit, hapus, set utama)
│   │   │   ├── pages/
│   │   │   │   ├── address_list_page.dart           # Layar daftar alamat & pemilihan alamat booking
│   │   │   │   ├── add_address_page.dart            # Layar tambah alamat baru
│   │   │   │   └── edit_address_page.dart           # Layar edit & hapus alamat
│   │   │   └── widgets/
│   │   │       ├── address_card.dart                # Kartu alamat responsif dengan badge & status
│   │   │       └── delete_address_dialog.dart       # Modal konfirmasi hapus alamat
│   │   │
│   │   ├── auth/                         # Fitur Autentikasi Pengguna
│   │   │   ├── data/
│   │   │   │   └── dummy_auth_service.dart          # Layanan simulasi login dan registrasi
│   │   │   ├── pages/
│   │   │   │   ├── login_page.dart                  # Halaman masuk akun
│   │   │   │   └── register_page.dart               # Halaman pendaftaran akun baru
│   │   │   └── widgets/
│   │   │       ├── auth_social_buttons.dart         # Tombol masuk sosial (Google & Apple)
│   │   │       └── auth_text_field.dart             # Komponen input form autentikasi
│   │   │
│   │   ├── booking/                      # Fitur Penjadwalan & Pemesanan Layanan
│   │   │   ├── controllers/
│   │   │   │   └── booking_controller.dart          # State layanan, jadwal, alamat, dan catatan
│   │   │   ├── pages/
│   │   │   │   └── booking_page.dart                # Halaman booking dengan CustomScrollView
│   │   │   └── widgets/
│   │   │       └── booking_widgets.dart             # Kalender, pemilih jam, dan kartu alamat
│   │   │
│   │   ├── chatbot/                      # Fitur Asisten Interaktif AI
│   │   │   └── pages/
│   │   │       └── chatbot_page.dart                # Halaman interaksi asisten chatbot
│   │   │
│   │   ├── checkout/                     # Fitur Pembayaran & Konfirmasi Pesanan
│   │   │   ├── domain/
│   │   │   │   └── models/
│   │   │   │       └── payment_method_model.dart    # Model metode pembayaran (QRIS, VA, Transfer)
│   │   │   ├── controllers/
│   │   │   │   └── checkout_controller.dart         # Kalkulasi promo, biaya platform, dan total bayar
│   │   │   ├── pages/
│   │   │   │   ├── checkout_page.dart               # Halaman rincian checkout pengerjaan
│   │   │   │   ├── payment_method_page.dart         # Layar pemilihan metode pembayaran
│   │   │   │   └── payment_page.dart                # Layar instruksi & status pembayaran
│   │   │   └── widgets/
│   │   │       ├── order_confirmation_dialog.dart
│   │   │       └── payment_method_icon.dart
│   │   │
│   │   ├── home/                         # Fitur Beranda & Penemuan Layanan
│   │   │   ├── data/
│   │   │   │   └── home_data.dart                   # Data dummy kategori, banner promo, & layanan populer
│   │   │   ├── domain/
│   │   │   │   └── models/
│   │   │   │       ├── popular_service_model.dart
│   │   │   │       └── service_category_model.dart
│   │   │   ├── pages/
│   │   │   │   └── home_page.dart                   # Halaman beranda utama
│   │   │   └── widgets/
│   │   │       ├── popular_service_card.dart
│   │   │       └── service_category_item.dart
│   │   │
│   │   ├── message/                      # Fitur Notifikasi & Pesanan Real-time
│   │   │   ├── data/
│   │   │   │   └── message_data.dart                # Data notifikasi status cleaner & promo
│   │   │   ├── domain/
│   │   │   │   └── models/
│   │   │   │       └── message_notification_model.dart
│   │   │   └── pages/
│   │   │       └── messages_page.dart               # Halaman notifikasi pesan dan status cleaner
│   │   │
│   │   ├── order/                        # Fitur Manajemen Pesanan Pelanggan
│   │   │   ├── data/
│   │   │   │   └── order_data.dart                  # Data pesanan aktif, terjadwal, dan riwayat
│   │   │   ├── domain/
│   │   │   │   └── models/
│   │   │   │       └── order_model.dart             # Model status pesanan, tahapan layanan, ulasan, & rating
│   │   │   ├── controllers/
│   │   │   │   └── order_controller.dart            # Global state provider tahapan pesanan & review
│   │   │   ├── pages/
│   │   │   │   ├── orders_page.dart                 # Halaman pesanan terjadwal & riwayat selesai
│   │   │   │   ├── order_status_page.dart           # Layar status pesanan interaktif (5 tahapan & live map)
│   │   │   │   └── review_rating_page.dart          # Layar ulasan & rating bintang pengalaman pengerjaan
│   │   │   └── widgets/
│   │   │       └── order_tracking_map.dart          # Komponen peta rute Malang City Point - Sigura Gura
│   │   │
│   │   ├── profile/                      # Fitur Pengaturan Akun & Profil Pengguna
│   │   │   ├── models/
│   │   │   │   └── user_profile_model.dart          # Model entitas profil pengguna & kata sandi
│   │   │   ├── controllers/
│   │   │   │   ├── profile_controller.dart          # Global state provider profil & kata sandi akun
│   │   │   │   └── change_password_controller.dart  # State provider validasi & kekuatan kata sandi
│   │   │   └── pages/
│   │   │       ├── profile_page.dart                # Halaman profil akun & menu pengaturan
│   │   │       ├── personal_data_page.dart          # Layar Data Diri (form identitas, gender, tgl lahir)
│   │   │       └── change_password_page.dart        # Layar Ubah Kata Sandi (validasi & indikator kekuatan)
│   │   │
│   │   ├── support/                      # Fitur Pusat Bantuan & FAQ (Customer Service)
│   │   │   ├── data/
│   │   │   │   └── faq_data.dart                    # Data inisial FAQ populer & kontak CS
│   │   │   ├── models/
│   │   │   │   └── faq_item_model.dart              # Model entitas item FAQ & status ekspansi
│   │   │   ├── controllers/
│   │   │   │   └── support_controller.dart          # Global state provider FAQ (pencarian & accordion)
│   │   │   └── pages/
│   │   │       └── help_center_page.dart            # Layar Pusat Bantuan & FAQ
│   │   │
│   │   └── service/                      # Fitur Katalog Layanan Kebersihan
│   │       ├── data/
│   │       │   └── service_data.dart                # Sumber data katalog lengkap layanan
│   │       ├── domain/
│   │       │   └── models/
│   │       │       └── service_model.dart
│   │       ├── controllers/
│   │       │   ├── service_controller.dart          # Filter kategori & pencarian layanan
│   │       │   └── service_sort.dart                # Pengurutan harga, rating, & popularitas
│   │       ├── pages/
│   │       │   ├── service_list_page.dart           # Katalog pencarian & filter layanan
│   │       │   ├── service_detail_page.dart         # Informasi detail layanan & paket pengerjaan
│   │       │   └── all_reviews_page.dart            # Halaman ulasan & testimoni pelanggan
│   │       └── widgets/
│   │           ├── service_card.dart
│   │           └── review_card.dart
│   │
│   └── shared/                           # Komponen global lintas modul
│       └── widgets/
│           ├── bottom_navigation.dart               # Navigasi bawah 5 menu utama
│           ├── chatbot_button.dart                  # Floating Action Button Chatbot
│           └── chatbot_icon.dart                    # Desain vektor ikon chatbot
│
├── test/                                 # Pengujian otomatis (Unit & Widget Test - 38 Tests)
│   └── features/
│       ├── address/
│       │   └── address_controller_test.dart         # Unit test AddressController & AddressModel
│       ├── order/
│       │   └── order_controller_test.dart           # Unit test OrderController & Pemetaan Reorder
│       ├── profile/
│       │   ├── profile_controller_test.dart         # Unit test ProfileController & UserProfileModel
│       │   └── change_password_controller_test.dart # Unit test validasi & kekuatan kata sandi
│       └── support/
│           └── support_controller_test.dart         # Unit test SupportController & FAQ accordion
│
├── .gitignore                            # Daftar file yang tidak dilacak Git
├── .metadata                             # Metadata project Flutter
├── analysis_options.yaml                 # Aturan lint dan static analysis
├── pubspec.yaml                          # Dependency, aset, font, dan metadata project
├── pubspec.lock                          # Versi dependency yang terkunci
└── README.md                             # Dokumentasi project
```


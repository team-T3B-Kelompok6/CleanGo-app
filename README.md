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
|   |   |-- back.svg
|   |   |-- clock.svg
|   |   |-- daily_cleaning.svg
|   |   |-- deep_cleaning.svg
|   |   |-- fogging.svg
|   |   |-- home.svg
|   |   |-- ironing.svg
|   |   |-- location.svg
|   |   |-- messages.svg
|   |   |-- monthly_cleaning.svg
|   |   |-- nav_home_inactive.svg
|   |   |-- nav_messages_inactive.svg
|   |   |-- nav_orders_inactive.svg
|   |   |-- nav_profile_inactive.svg
|   |   |-- nav_services_active.svg
|   |   |-- notification.svg
|   |   |-- office.svg
|   |   |-- orders.svg
|   |   |-- pandy_compact.svg
|   |   |-- pandy.svg
|   |   |-- profile.svg
|   |   |-- rating_star.svg
|   |   |-- search.svg
|   |   |-- service_clock.svg
|   |   |-- service_search.svg
|   |   |-- services.svg
|   |   |-- sofa_mattress.svg
|   |   |-- sort.svg
|   |   `-- star.svg
|   `-- images/
|       |-- ac_service.jpeg
|       |-- deep_cleaning.jpeg
|       |-- promo_banner.png
|       |-- service_ac_care.jpeg
|       |-- service_daily_cleaning.jpeg
|       |-- service_deep_cleaning.jpeg
|       |-- service_office.jpeg
|       |-- service_sofa_mattress.jpeg
|       |-- sofa_cleaning.jpeg
|       `-- user_profile.jpeg
|
|-- lib/
|   |-- main.dart                    # Entry point aplikasi
|   |-- app.dart                     # Konfigurasi utama MaterialApp
|   |-- core/
|   |   |-- constants/
|   |   |   `-- app_routes.dart      # Nama route aplikasi
|   |   `-- theme/
|   |       `-- app_theme.dart       # Warna, tipografi, dan tema global
|   |-- features/
|   |   |-- home/
|   |   |   |-- data/
|   |   |   |   `-- home_data.dart
|   |   |   |-- domain/
|   |   |   |   `-- models/
|   |   |   |       |-- popular_service_model.dart
|   |   |   |       `-- service_category_model.dart
|   |   |   `-- presentation/
|   |   |       |-- pages/
|   |   |       |   `-- home_page.dart
|   |   |       `-- widgets/
|   |   |           |-- popular_service_card.dart
|   |   |           `-- service_category_item.dart
|   |   `-- service/
|   |       |-- data/
|   |       |   `-- service_data.dart
|   |       |-- domain/
|   |       |   `-- models/
|   |       |       `-- service_model.dart
|   |       `-- presentation/
|   |           |-- controllers/
|   |           |   `-- service_controller.dart
|   |           |-- pages/
|   |           |   |-- service_detail_page.dart
|   |           |   `-- service_list_page.dart
|   |           `-- widgets/
|   |               `-- service_card.dart
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



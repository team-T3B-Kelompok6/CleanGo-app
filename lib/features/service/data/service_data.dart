import '../domain/models/service_model.dart';

abstract final class ServiceData {
  static const List<String> filters = [
    'Semua',
    'Rumah',
    'Kantor',
    'Sofa',
    'AC',
  ];

  static const List<ServiceModel> services = [
    ServiceModel(
      id: 'deep-cleaning',
      title: 'Deep Cleaning',
      description: 'Pembersihan menyeluruh kerak debu dan kotoran mendalam',
      duration: '±2–3 jam',
      price: 'Rp150.000',
      category: 'Rumah',
      imagePath: 'assets/images/service_deep_cleaning.jpeg',
      badge: 'Terlaris',
      detail: ServiceDetailModel(
        heroImagePath: 'assets/images/service_detail_hero.jpeg',
        description:
            'Layanan pembersihan mendalam yang menyasar noda membandel, '
            'debu di tempat tersembunyi, serta sanitasi penuh untuk seluruh '
            'ruangan agar kembali segar, sehat, dan higienis.',
        rating: '4.8',
        reviewCount: '230 ulasan',
        benefits: [
          'Pembersihan debu & kerak menyeluruh',
          'Area dapur & disinfeksi kamar mandi',
          'Pembersihan jendela, kusen & kaca dalam',
          'Furnitur dilap, disedot & dirapikan',
        ],
        reviews: [
          ServiceReviewModel(
            name: 'Budi Santoso',
            comment: 'Hasil bersih memuaskan dan pengerjaan cepat.',
            rating: 5,
          ),
          ServiceReviewModel(
            name: 'Siti Rahma',
            comment: 'Pembersih sangat detail di bagian kamar mandi. Hebat!',
            rating: 5,
          ),
        ],
      ),
    ),
    ServiceModel(
      id: 'ac-care',
      title: 'Cuci & Perawatan AC',
      description: 'Cuci filter, blower, dan cek tekanan freon',
      duration: '±1–1,5 jam',
      price: 'Rp75.000',
      category: 'AC',
      imagePath: 'assets/images/service_ac_care.jpeg',
      rating: '4.9',
    ),
    ServiceModel(
      id: 'sofa-mattress',
      title: 'Cuci Sofa & Kasur',
      description: 'Sedot debu tungau dan cuci noda basah',
      duration: '±1,5–2 jam',
      price: 'Rp120.000',
      category: 'Sofa',
      imagePath: 'assets/images/service_sofa_mattress.jpeg',
    ),
    ServiceModel(
      id: 'office-cleaning',
      title: 'Cleaning Kantor & Usaha',
      description: 'Sanitasi ruang kerja meja dan area bersama',
      duration: '±2–4 jam',
      price: 'Rp250.000',
      category: 'Kantor',
      imagePath: 'assets/images/service_office.jpeg',
    ),
    ServiceModel(
      id: 'daily-cleaning',
      title: 'Cleaning Harian (Reguler)',
      description: 'Menyapu, mengepel, dan merapikan ruangan harian',
      duration: '±2 jam',
      price: 'Rp85.000',
      category: 'Rumah',
      imagePath: 'assets/images/service_daily_cleaning.jpeg',
    ),
  ];
}

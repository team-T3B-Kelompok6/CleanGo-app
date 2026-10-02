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
      popularity: 95,
      releaseOrder: 3,
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
        satisfactionPercentage: 98,
        benefits: [
          'Pembersihan debu & kerak menyeluruh',
          'Area dapur & disinfeksi kamar mandi',
          'Pembersihan jendela, kusen & kaca dalam',
          'Furnitur dilap, disedot & dirapikan',
        ],
        reviews: [
          ServiceReviewModel(
            name: 'Budi Santoso',
            comment:
                'Hasil bersih memuaskan dan pengerjaan cepat. Petugas sangat '
                'teliti membersihkan sudut-sudut yang susah dijangkau.',
            rating: 5,
            date: '2 hari lalu',
            imagePaths: ['assets/images/service_detail_hero.jpeg'],
          ),
          ServiceReviewModel(
            name: 'Siti Rahma',
            comment:
                'Pembersih sangat detail di bagian kamar mandi dan dapur. '
                'Kerak-kerak membandel hilang semua. Hebat!',
            rating: 5,
            date: '4 hari lalu',
            imagePaths: [
              'assets/images/service_daily_cleaning.jpeg',
              'assets/images/deep_cleaning.jpeg',
            ],
          ),
          ServiceReviewModel(
            name: 'Krisna Pratama',
            comment:
                'Pelayanan sangat profesional, tepat waktu, dan stafnya ramah '
                'sekali. Ruangan jadi wangi dan segar.',
            rating: 5,
            date: '1 minggu lalu',
          ),
          ServiceReviewModel(
            name: 'Dewi Lestari',
            comment:
                'Pengerjaan rapi dan bersih. Sedikit terlambat 5 menit karena '
                'hujan deras, tapi hasil kerjanya memuaskan.',
            rating: 4,
            date: '2 minggu lalu',
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
      popularity: 82,
      releaseOrder: 5,
      imagePath: 'assets/images/service_ac_care.jpeg',
      rating: '4.9',
      detail: ServiceDetailModel(
        heroImagePath: 'assets/images/service_ac_care.jpeg',
        description:
            'Layanan perawatan AC menyeluruh yang membersihkan filter, '
            'evaporator, blower, dan saluran pembuangan sekaligus memeriksa '
            'tekanan freon agar udara kembali sejuk, bersih, dan hemat energi.',
        rating: '4.9',
        reviewCount: '184 ulasan',
        satisfactionPercentage: 99,
        benefits: [
          'Pembersihan filter, evaporator & blower',
          'Pengecekan tekanan dan kondisi freon',
          'Pembersihan saluran pembuangan air',
          'Pemeriksaan fungsi dan suhu AC',
        ],
        reviews: [
          ServiceReviewModel(
            name: 'Andi Wijaya',
            comment:
                'AC kembali dingin dan tidak berisik. Teknisi juga menjelaskan '
                'kondisi unit dengan sangat jelas.',
            rating: 5,
            date: '1 hari lalu',
          ),
          ServiceReviewModel(
            name: 'Maya Putri',
            comment:
                'Pengerjaan cepat, rapi, dan area di bawah AC tetap bersih '
                'setelah proses pencucian selesai.',
            rating: 5,
            date: '3 hari lalu',
          ),
          ServiceReviewModel(
            name: 'Rizky Hidayat',
            comment:
                'Teknisi datang tepat waktu dan AC kamar sekarang jauh lebih '
                'sejuk. Sangat memuaskan.',
            rating: 5,
            date: '1 minggu lalu',
          ),
          ServiceReviewModel(
            name: 'Nadia Sari',
            comment:
                'Hasilnya bagus dan udara tidak lagi berbau. Prosesnya sedikit '
                'lebih lama, tetapi tetap rapi.',
            rating: 4,
            date: '2 minggu lalu',
          ),
        ],
      ),
    ),
    ServiceModel(
      id: 'sofa-mattress',
      title: 'Cuci Sofa & Kasur',
      description: 'Sedot debu tungau dan cuci noda basah',
      duration: '±1,5–2 jam',
      price: 'Rp120.000',
      category: 'Sofa',
      popularity: 86,
      releaseOrder: 2,
      imagePath: 'assets/images/service_sofa_mattress.jpeg',
      rating: '4.8',
      detail: ServiceDetailModel(
        heroImagePath: 'assets/images/service_sofa_mattress.jpeg',
        description:
            'Layanan pencucian sofa dan kasur menggunakan proses vakum dan '
            'ekstraksi untuk mengangkat debu, tungau, bau, serta noda membandel '
            'tanpa merusak warna dan tekstur kain.',
        rating: '4.8',
        reviewCount: '156 ulasan',
        satisfactionPercentage: 97,
        benefits: [
          'Vakum debu dan tungau secara menyeluruh',
          'Pembersihan noda dengan metode ekstraksi',
          'Pengurangan bau pada permukaan kain',
          'Finishing rapi sesuai jenis material',
        ],
        reviews: [
          ServiceReviewModel(
            name: 'Rina Kurnia',
            comment:
                'Sofa yang sebelumnya kusam kembali bersih dan wanginya tidak '
                'menyengat. Hasilnya sangat bagus.',
            rating: 5,
            date: '2 hari lalu',
          ),
          ServiceReviewModel(
            name: 'Fajar Nugroho',
            comment:
                'Noda minuman di kasur berhasil dibersihkan. Petugas bekerja '
                'teliti dan menjaga lantai tetap kering.',
            rating: 5,
            date: '5 hari lalu',
          ),
          ServiceReviewModel(
            name: 'Ayu Permata',
            comment:
                'Proses pengerjaan rapi dan sofa terasa lebih segar. Penjelasan '
                'cara pengeringannya juga mudah dipahami.',
            rating: 5,
            date: '1 minggu lalu',
          ),
          ServiceReviewModel(
            name: 'Dimas Saputra',
            comment:
                'Secara keseluruhan hasilnya bersih. Waktu pengeringan sedikit '
                'lebih lama karena cuaca mendung.',
            rating: 4,
            date: '3 minggu lalu',
          ),
        ],
      ),
    ),
    ServiceModel(
      id: 'office-cleaning',
      title: 'Cleaning Kantor & Usaha',
      description: 'Sanitasi ruang kerja meja dan area bersama',
      duration: '±2–4 jam',
      price: 'Rp250.000',
      category: 'Kantor',
      popularity: 78,
      releaseOrder: 4,
      imagePath: 'assets/images/service_office.jpeg',
      rating: '4.9',
      detail: ServiceDetailModel(
        heroImagePath: 'assets/images/service_office.jpeg',
        description:
            'Layanan kebersihan untuk kantor dan ruang usaha yang mencakup '
            'area kerja, meja, lantai, kaca, serta ruang bersama agar lingkungan '
            'tetap rapi, higienis, dan nyaman digunakan.',
        rating: '4.9',
        reviewCount: '92 ulasan',
        satisfactionPercentage: 99,
        benefits: [
          'Pembersihan meja dan area kerja',
          'Vakum serta pel lantai seluruh ruangan',
          'Pembersihan kaca dan area bersama',
          'Sanitasi titik sentuh yang sering digunakan',
        ],
        reviews: [
          ServiceReviewModel(
            name: 'Yusuf Maulana',
            comment:
                'Tim bekerja teratur tanpa mengganggu aktivitas kantor. Semua '
                'meja dan lantai terlihat bersih.',
            rating: 5,
            date: '3 hari lalu',
          ),
          ServiceReviewModel(
            name: 'Nina Amelia',
            comment:
                'Ruang kerja menjadi jauh lebih rapi dan segar. Tim datang '
                'tepat waktu sesuai jadwal.',
            rating: 5,
            date: '6 hari lalu',
          ),
          ServiceReviewModel(
            name: 'Bagas Pratama',
            comment:
                'Pembersihan area bersama sangat detail dan perlengkapan kantor '
                'ditata kembali dengan baik.',
            rating: 5,
            date: '2 minggu lalu',
          ),
          ServiceReviewModel(
            name: 'Lina Hartati',
            comment:
                'Hasil pengerjaan memuaskan. Ada satu bagian kaca yang sempat '
                'terlewat, tetapi langsung dibersihkan setelah diberi tahu.',
            rating: 4,
            date: '1 bulan lalu',
          ),
        ],
      ),
    ),
    ServiceModel(
      id: 'daily-cleaning',
      title: 'Cleaning Harian (Reguler)',
      description: 'Menyapu, mengepel, dan merapikan ruangan harian',
      duration: '±2 jam',
      price: 'Rp85.000',
      category: 'Rumah',
      popularity: 90,
      releaseOrder: 1,
      imagePath: 'assets/images/service_daily_cleaning.jpeg',
      rating: '4.7',
      detail: ServiceDetailModel(
        heroImagePath: 'assets/images/service_daily_cleaning.jpeg',
        description:
            'Layanan kebersihan rutin untuk menjaga rumah tetap nyaman melalui '
            'kegiatan menyapu, mengepel, membersihkan debu, dan merapikan area '
            'utama sesuai kebutuhan harian.',
        rating: '4.7',
        reviewCount: '318 ulasan',
        satisfactionPercentage: 96,
        benefits: [
          'Menyapu dan mengepel lantai',
          'Membersihkan debu pada permukaan furnitur',
          'Merapikan kamar dan area keluarga',
          'Membersihkan dapur serta kamar mandi ringan',
        ],
        reviews: [
          ServiceReviewModel(
            name: 'Putri Ananda',
            comment:
                'Petugas bekerja cekatan dan rumah langsung terasa lebih rapi. '
                'Cocok untuk kebutuhan rutin mingguan.',
            rating: 5,
            date: '1 hari lalu',
          ),
          ServiceReviewModel(
            name: 'Hendra Gunawan',
            comment:
                'Semua area utama dibersihkan sesuai permintaan. Petugasnya '
                'ramah dan datang tepat waktu.',
            rating: 5,
            date: '4 hari lalu',
          ),
          ServiceReviewModel(
            name: 'Selvi Maharani',
            comment:
                'Dapur dan ruang keluarga menjadi bersih. Pengerjaan juga '
                'selesai sesuai estimasi waktu.',
            rating: 5,
            date: '1 minggu lalu',
          ),
          ServiceReviewModel(
            name: 'Arif Setiawan',
            comment:
                'Hasilnya rapi dan cukup menyeluruh. Beberapa sudut kecil perlu '
                'diingatkan, tetapi langsung ditangani.',
            rating: 4,
            date: '2 minggu lalu',
          ),
        ],
      ),
    ),
  ];
}
